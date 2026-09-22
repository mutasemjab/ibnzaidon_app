import 'dart:async';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:ibnzaidon/core/error/failure.dart';
import 'package:ibnzaidon/features/courses/domain/services/store_purchase_gateway.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// `in_app_purchase` (StoreKit 2) implementation. iOS only.
class StoreKitPurchaseGateway implements StorePurchaseGateway {
  StoreKitPurchaseGateway(this._iap);

  final InAppPurchase _iap;

  @override
  bool get isSupported => Platform.isIOS;

  @override
  Stream<StorePurchaseUpdate> get updates {
    if (!isSupported) return const Stream.empty();
    return _iap.purchaseStream.expand(
      (details) => details.map(_toUpdate),
    );
  }

  StorePurchaseUpdate _toUpdate(PurchaseDetails details) {
    final status = switch (details.status) {
      PurchaseStatus.pending => StorePurchaseStatus.pending,
      PurchaseStatus.purchased => StorePurchaseStatus.purchased,
      PurchaseStatus.restored => StorePurchaseStatus.restored,
      PurchaseStatus.canceled => StorePurchaseStatus.canceled,
      PurchaseStatus.error => StorePurchaseStatus.error,
    };
    return StorePurchaseUpdate(
      status: status,
      productId: details.productID,
      transactionId: details.purchaseID,
      signedTransaction: details.verificationData.serverVerificationData,
      transactionDate: details.transactionDate,
      errorMessage: details.error?.message,
      handle: details,
    );
  }

  @override
  Future<bool> isAvailable() async => isSupported && await _iap.isAvailable();

  @override
  Future<Either<Failure, Unit>> buy({
    required String productId,
    String? appAccountToken,
  }) async {
    try {
      final response = await _iap.queryProductDetails({productId});
      if (response.productDetails.isEmpty) {
        return const Left(NotFoundFailure());
      }
      final param = PurchaseParam(
        productDetails: response.productDetails.first,
        applicationUserName: appAccountToken,
      );
      final started = await _iap.buyNonConsumable(purchaseParam: param);
      return started ? const Right(unit) : const Left(UnknownFailure());
    } on Object {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<void> restore() => _iap.restorePurchases();

  @override
  Future<void> complete(StorePurchaseUpdate update) async {
    final handle = update.handle;
    if (handle is PurchaseDetails && handle.pendingCompletePurchase) {
      await _iap.completePurchase(handle);
    }
  }
}

/// Used on platforms without a store flow (Android, tests).
class NoStorePurchaseGateway implements StorePurchaseGateway {
  const NoStorePurchaseGateway();

  @override
  bool get isSupported => false;

  @override
  Stream<StorePurchaseUpdate> get updates => const Stream.empty();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<Either<Failure, Unit>> buy({
    required String productId,
    String? appAccountToken,
  }) async => const Left(UnknownFailure());

  @override
  Future<void> restore() async {}

  @override
  Future<void> complete(StorePurchaseUpdate update) async {}
}
