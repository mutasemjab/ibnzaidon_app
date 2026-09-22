import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:ibnzaidon/core/config/app_config.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/courses/domain/entities/course_content.dart';
import 'package:ibnzaidon/features/courses/domain/services/store_purchase_gateway.dart';
import 'package:ibnzaidon/features/courses/domain/usecases/courses_usecases.dart';

enum PurchaseStatus {
  idle,
  purchasing,
  pending,
  verifying,
  success,
  failure,
  cancelled,
}

final class PurchaseState extends Equatable {
  const PurchaseState({
    this.status = PurchaseStatus.idle,
    this.courseId,
    this.failure,
    this.canRetryVerification = false,
  });

  final PurchaseStatus status;
  final int? courseId;
  final Failure? failure;

  /// A paid transaction exists in the store but the backend has not
  /// confirmed it yet. It is never completed until it is.
  final bool canRetryVerification;

  bool get isBusy =>
      status == PurchaseStatus.purchasing || status == PurchaseStatus.verifying;

  @override
  List<Object?> get props => [status, courseId, failure, canRetryVerification];
}

sealed class PurchaseEvent extends Equatable {
  const PurchaseEvent();

  @override
  List<Object?> get props => [];
}

final class PurchaseRequested extends PurchaseEvent {
  const PurchaseRequested(this.courseId);

  final int courseId;

  @override
  List<Object?> get props => [courseId];
}

final class PurchaseRestoreRequested extends PurchaseEvent {
  const PurchaseRestoreRequested();
}

final class PurchaseVerificationRetried extends PurchaseEvent {
  const PurchaseVerificationRetried();
}

final class _StoreUpdateReceived extends PurchaseEvent {
  const _StoreUpdateReceived(this.update);

  final StorePurchaseUpdate update;

  @override
  List<Object?> get props => [update];
}

/// App-wide (StoreKit can deliver unfinished transactions at launch).
/// A transaction is completed **only after** the backend confirms it.
class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  PurchaseBloc({
    required StorePurchaseGateway gateway,
    required VerifyApplePurchaseUseCase verifyPurchase,
    required AppConfig config,
    required String? Function() appAccountToken,
  }) : _gateway = gateway,
       _verifyPurchase = verifyPurchase,
       _config = config,
       _appAccountToken = appAccountToken,
       super(const PurchaseState()) {
    on<PurchaseRequested>(_onRequested, transformer: droppable());
    on<PurchaseRestoreRequested>(_onRestore, transformer: droppable());
    on<_StoreUpdateReceived>(_onUpdate, transformer: sequential());
    on<PurchaseVerificationRetried>(_onRetry, transformer: droppable());
    _subscription = _gateway.updates.listen(
      (update) => add(_StoreUpdateReceived(update)),
    );
  }

  final StorePurchaseGateway _gateway;
  final VerifyApplePurchaseUseCase _verifyPurchase;
  final AppConfig _config;
  final String? Function() _appAccountToken;
  late final StreamSubscription<StorePurchaseUpdate> _subscription;
  final List<StorePurchaseUpdate> _unverified = [];

  bool get isSupported => _gateway.isSupported;

  int? _courseIdOf(String productId) {
    final prefix = _config.applePurchaseProductPrefix;
    if (!productId.startsWith(prefix)) return null;
    return int.tryParse(productId.substring(prefix.length));
  }

  Future<void> _onRequested(
    PurchaseRequested event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(
      PurchaseState(
        status: PurchaseStatus.purchasing,
        courseId: event.courseId,
      ),
    );
    final result = await _gateway.buy(
      productId: _config.appleProductId(event.courseId),
      appAccountToken: _appAccountToken(),
    );
    result.fold(
      (failure) => emit(
        PurchaseState(
          status: PurchaseStatus.failure,
          courseId: event.courseId,
          failure: failure,
        ),
      ),
      (_) {},
    );
  }

  Future<void> _onRestore(
    PurchaseRestoreRequested event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(const PurchaseState(status: PurchaseStatus.purchasing));
    await _gateway.restore();
    if (state.status == PurchaseStatus.purchasing) {
      emit(const PurchaseState());
    }
  }

  Future<void> _onUpdate(
    _StoreUpdateReceived event,
    Emitter<PurchaseState> emit,
  ) async {
    final update = event.update;
    final courseId = _courseIdOf(update.productId);
    switch (update.status) {
      case StorePurchaseStatus.pending:
        emit(PurchaseState(status: PurchaseStatus.pending, courseId: courseId));
      case StorePurchaseStatus.canceled:
        await _gateway.complete(update);
        emit(
          PurchaseState(status: PurchaseStatus.cancelled, courseId: courseId),
        );
      case StorePurchaseStatus.error:
        await _gateway.complete(update);
        emit(
          PurchaseState(
            status: PurchaseStatus.failure,
            courseId: courseId,
            failure: const UnknownFailure(),
          ),
        );
      case StorePurchaseStatus.purchased:
      case StorePurchaseStatus.restored:
        await _verify(update, courseId, emit);
    }
  }

  Future<void> _onRetry(
    PurchaseVerificationRetried event,
    Emitter<PurchaseState> emit,
  ) async {
    final pending = List<StorePurchaseUpdate>.of(_unverified);
    for (final update in pending) {
      await _verify(update, _courseIdOf(update.productId), emit);
    }
  }

  Future<void> _verify(
    StorePurchaseUpdate update,
    int? courseId,
    Emitter<PurchaseState> emit,
  ) async {
    final token = _appAccountToken();
    final transactionId = update.transactionId;
    final signed = update.signedTransaction;
    if (courseId == null ||
        token == null ||
        transactionId == null ||
        signed == null ||
        signed.isEmpty) {
      // Not verifiable right now (signed out / unknown product). Leave the
      // transaction open so the store re-delivers it later.
      return;
    }
    emit(PurchaseState(status: PurchaseStatus.verifying, courseId: courseId));
    final result = await _verifyPurchase(
      ApplePurchaseProof(
        courseId: courseId,
        productId: update.productId,
        transactionId: transactionId,
        signedTransaction: signed,
        purchaseToken: token,
        transactionDate: update.transactionDate,
      ),
    );
    await result.fold(
      (failure) async {
        if (!_unverified.contains(update)) _unverified.add(update);
        emit(
          PurchaseState(
            status: PurchaseStatus.failure,
            courseId: courseId,
            failure: failure,
            canRetryVerification: true,
          ),
        );
      },
      (verification) async {
        _unverified.remove(update);
        await _gateway.complete(update);
        emit(
          PurchaseState(status: PurchaseStatus.success, courseId: courseId),
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
