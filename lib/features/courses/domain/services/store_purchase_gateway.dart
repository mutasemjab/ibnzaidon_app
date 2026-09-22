import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';

enum StorePurchaseStatus { pending, purchased, restored, canceled, error }

/// A store transaction update. [handle] is the opaque platform object needed
/// to finish the transaction *after* the backend confirms it.
class StorePurchaseUpdate extends Equatable {
  const StorePurchaseUpdate({
    required this.status,
    required this.productId,
    this.transactionId,
    this.signedTransaction,
    this.transactionDate,
    this.errorMessage,
    this.handle,
  });

  final StorePurchaseStatus status;
  final String productId;
  final String? transactionId;
  final String? signedTransaction;
  final String? transactionDate;
  final String? errorMessage;
  final Object? handle;

  @override
  List<Object?> get props => [
    status,
    productId,
    transactionId,
    signedTransaction,
    transactionDate,
    errorMessage,
  ];
}

/// Store access abstraction (StoreKit 2 on iOS). Android has no store
/// purchase flow: [isSupported] is false and the UI falls back to cards.
abstract interface class StorePurchaseGateway {
  bool get isSupported;
  Stream<StorePurchaseUpdate> get updates;
  Future<bool> isAvailable();

  /// Starts a purchase. Success/failure/pending arrive through [updates].
  Future<Either<Failure, Unit>> buy({
    required String productId,
    String? appAccountToken,
  });

  Future<void> restore();

  /// Must only be called after the backend confirmed the transaction.
  Future<void> complete(StorePurchaseUpdate update);
}
