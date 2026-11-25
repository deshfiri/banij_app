import 'package:flutter/material.dart';

import '../../../../../providers/dashboard_provider.dart';
import '../../../model/payment_status.dart';
import '../../payment/payment_processing_screen.dart';
import '../../payment/payment_result_screen.dart';
import '../../sslcommerz_payment_screen.dart';

/// SSLCommerz payment flows. The backend owns the SSLCommerz store and
/// session; the app only opens the hosted page and reads the backend's
/// status. No store credentials and no direct SSLCommerz API calls here.
abstract final class CheckoutPaymentFlow {
  /// Package activation payment (the `/checkout` APIs):
  ///
  /// 1. `POST /checkout {gateway: "sslcommerz", coupon}` → `redirect_url`
  /// 2. SSLCommerz's official hosted checkout in [SslCommerzPaymentScreen]
  /// 3. [PaymentProcessingScreen]: `POST /checkout/payment/verify`, then
  ///    `GET /checkout/payment` while `is_open`
  /// 4. [PaymentResultScreen] — success / failed / cancelled / pending,
  ///    with Try again (new attempt) and Check status again.
  ///
  /// Returns true only when the backend reports the payment as paid.
  static Future<bool> runActivationPayment(
    BuildContext context,
    DashboardProvider provider, {
    String? coupon,
    required String amountText,
  }) async {
    attempt:
    while (true) {
      final url = await provider.startCheckoutPayment(coupon: coupon);
      if (url == null || !context.mounted) return false; // Error already shown.

      PaymentResultData result;
      if (url.isEmpty) {
        // Nothing to open: the backend says it is already settled.
        result = const PaymentResultData(PaymentStatus.paid);
      } else {
        final gateway = await SslCommerzPaymentScreen.open(context, url);
        if (!context.mounted) return false;
        result = await PaymentProcessingScreen.open(
          context,
          provider: provider,
          paymentUrl: url,
          gatewayOutcome: gateway.outcome,
        );
      }

      while (true) {
        if (!context.mounted) return false;
        final action = await PaymentResultScreen.open(context, result: result, amountText: amountText);
        if (!context.mounted) return false;
        switch (action) {
          case PaymentResultAction.done:
            return result.status == PaymentStatus.paid;
          case PaymentResultAction.retry:
            continue attempt;
          case PaymentResultAction.checkAgain:
            result = await PaymentProcessingScreen.open(
              context,
              provider: provider,
              paymentUrl: url.isEmpty ? null : url,
              gatewayOutcome: GatewayOutcome.unknown,
            );
          case PaymentResultAction.back:
            return false;
        }
      }
    }
  }

  /// Resumes a payment left open (app closed, or user left the processing
  /// screen): re-checks `GET /checkout/payment` and shows the result.
  static Future<bool> resumeActivationPayment(
    BuildContext context,
    DashboardProvider provider, {
    required String amountText,
  }) async {
    var result = await PaymentProcessingScreen.open(
      context,
      provider: provider,
      gatewayOutcome: GatewayOutcome.unknown,
    );
    while (true) {
      if (!context.mounted) return false;
      final action = await PaymentResultScreen.open(context, result: result, amountText: amountText, canRetry: false);
      if (!context.mounted) return false;
      if (action != PaymentResultAction.checkAgain) return result.status == PaymentStatus.paid;
      result = await PaymentProcessingScreen.open(context, provider: provider, gatewayOutcome: GatewayOutcome.unknown);
    }
  }

  /// Wholesale order paid on an SSLCommerz page the backend returned from
  /// `POST /wholesale/checkout/confirmation`.
  ///
  /// There is no backend status/verify API for order payments yet, so the
  /// app never claims "paid": a successful redirect is shown as
  /// "processing", and the order's real `payment_state` appears in Orders.
  static Future<void> payWholesaleOrder(BuildContext context, String paymentUrl, {required String amountText}) async {
    final gateway = await SslCommerzPaymentScreen.open(context, paymentUrl);
    if (!context.mounted) return;
    final result = switch (gateway.outcome) {
      GatewayOutcome.cancelled => const PaymentResultData(
          PaymentStatus.cancelled,
          message: 'You left the payment before finishing. Your order is saved — you can pay it later.',
        ),
      GatewayOutcome.failed => const PaymentResultData(
          PaymentStatus.failed,
          message: 'The payment did not go through. Your order is saved — you can pay it later.',
        ),
      _ => const PaymentResultData(
          PaymentStatus.processing,
          message: 'Your payment was submitted. The order will show as paid once SSLCommerz confirms it — check Orders.',
        ),
    };
    await PaymentResultScreen.open(context, result: result, amountText: amountText, canRetry: false);
  }
}
