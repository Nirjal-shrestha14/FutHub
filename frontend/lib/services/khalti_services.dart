import 'package:flutter/material.dart';
import 'package:khalti_flutter/khalti_flutter.dart';

class KhaltiRepository {
  Future<void> makePayment({
    required BuildContext context,
    required int amount,
    required String productIdentity,
    required String productName,
    required Function(PaymentSuccessModel) onSuccess,
    required Function(PaymentFailureModel) onFailure,
    required Function() onCancel,
  }) async {
    await KhaltiScope.of(context).pay(
      config: PaymentConfig(
        amount: amount,
        productIdentity: productIdentity,
        productName: productName,
        mobileReadOnly: false,
      ),
      preferences: [PaymentPreference.khalti],
      onSuccess: onSuccess,
      onFailure: onFailure,
      onCancel: onCancel,
    );
  }
}
