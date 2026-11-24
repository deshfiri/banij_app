import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../common_widget/gradient_button.dart';
import '../../../../../constants/color.dart';
import '../../../../../helpers/toast.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/dashboard_provider.dart';
import '../../../data/sslcommerz_service.dart';
import '../../../model/checkout_model.dart';
import '../../../model/sslcommerz_models.dart';
import 'sslcommerz_widgets.dart';
import '../../sslcommerz_payment_screen.dart';

/// Package payment with SSLCommerz:
/// 1. `POST /checkout` → `redirect_url` (the SSLCommerz session page),
/// 2. pay on [SslCommerzPaymentScreen] (in-app web view),
/// 3. `POST /checkout/payment/verify` (no body) so a payer who paid is not
///    left waiting for the gateway's notification,
/// 4. poll `GET /checkout/payment` while `is_open` is true.
abstract final class CheckoutPaymentFlow {
  /// Runs the whole flow. Returns true once the payment is confirmed paid.
  static Future<bool> run(BuildContext context, DashboardProvider provider, {String? coupon}) async {
    final url = await provider.startCheckoutPayment(coupon: coupon);
    if (url == null || !context.mounted) return false;
    if (url.isEmpty) return true; // Already settled, nothing to pay.

    final result = await SslCommerzPaymentScreen.open(context, url);
    if (!context.mounted) return false;
    if (result.outcome == GatewayOutcome.cancelled) {
      ToastUtil.showErrorMessage('Payment cancelled');
      return false;
    }

    final paid = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PaymentWaitingDialog(
        provider: provider,
        paymentUrl: url,
        gatewayFailed: result.outcome == GatewayOutcome.failed,
      ),
    );
    return paid ?? false;
  }

  /// Wholesale order: after `POST /wholesale/checkout/confirmation` returned
  /// an SSLCommerz [paymentUrl], pays it in the in-app screen. Returns true
  /// when SSLCommerz redirected to the success URL (the order is settled on
  /// the server by the gateway's notification).
  static Future<bool> payWholesaleOrder(BuildContext context, String paymentUrl) async {
    final result = await SslCommerzPaymentScreen.open(context, paymentUrl);
    switch (result.outcome) {
      case GatewayOutcome.success:
        return true;
      case GatewayOutcome.cancelled:
        ToastUtil.showErrorMessage('Payment cancelled. Your order is saved — you can pay it from Orders.');
        return false;
      case GatewayOutcome.failed:
        ToastUtil.showErrorMessage('Payment failed. Your order is saved — you can pay it from Orders.');
        return false;
      case GatewayOutcome.unknown:
        ToastUtil.showErrorMessage('Payment not confirmed yet. Check the order status in Orders.');
        return false;
    }
  }

  /// Direct SSLCommerz payment (when the backend returns no payment link)
  /// through the official `flutter_sslcommerz` SDK and its native payment UI.
  /// Returns the paid transaction, or null (with a message) otherwise.
  static Future<SslCommerzTransaction?> payDirectWithSslCommerz(
    BuildContext context,
    SslCommerzPaymentRequest request,
  ) async {
    SslCommerzTransaction transaction;
    try {
      transaction = await SslCommerzService.instance.payWithSdk(request);
    } catch (e) {
      debugPrint('SSLCommerz SDK error: $e');
      ToastUtil.showErrorMessage('Could not open SSLCommerz. Please try again.');
      return null;
    }
    if (transaction.isPaid) return transaction;

    final status = transaction.status?.toUpperCase() ?? '';
    if (status == 'CLOSED' || status == 'CANCELLED') {
      ToastUtil.showErrorMessage('Payment cancelled. Your order is saved — you can pay it from Orders.');
      return null;
    }
    if (transaction.isFailed) {
      ToastUtil.showErrorMessage('Payment failed. Your order is saved — you can pay it from Orders.');
      return null;
    }

    // Unclear result from the SDK: ask SSLCommerz about the transaction.
    if (!context.mounted) return null;
    final checked = await SslCommerzVerifyDialog.show(context, request.transactionId);
    if (checked != null && checked.isPaid) return checked;
    ToastUtil.showErrorMessage('Payment not confirmed yet. Check the order status in Orders.');
    return null;
  }

  /// Opens the payment page in the phone's browser (fallback from the dialog).
  static Future<bool> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    try {
      if (await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) return true;
    } catch (_) {}
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}

/// "Waiting for payment" dialog. Checks the status every few seconds and
/// right away when the user comes back from the gateway; closes with `true`
/// when paid and `false` when failed or cancelled.
class _PaymentWaitingDialog extends StatefulWidget {
  final DashboardProvider provider;
  final String paymentUrl;

  /// SSLCommerz redirected to the fail URL (still verified, in case the
  /// backend sees it differently).
  final bool gatewayFailed;

  const _PaymentWaitingDialog({required this.provider, required this.paymentUrl, this.gatewayFailed = false});

  @override
  State<_PaymentWaitingDialog> createState() => _PaymentWaitingDialogState();
}

class _PaymentWaitingDialogState extends State<_PaymentWaitingDialog> with WidgetsBindingObserver {
  static const _interval = Duration(seconds: 4);
  static const _maxWait = Duration(minutes: 5);

  Timer? _timer;
  bool _checking = false;
  bool _timedOut = false;
  String? _statusText;
  final DateTime _startedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _verifyThenPoll());
  }

  /// Asks the backend to check with SSLCommerz once, then keeps polling.
  Future<void> _verifyThenPoll() async {
    if (!mounted) return;
    setState(() => _checking = true);
    final verified = await widget.provider.verifyCheckoutPayment();
    if (!mounted) return;
    setState(() => _checking = false);
    if (_finishWith(verified)) return;
    if (widget.gatewayFailed && verified != null && !verified.isPaid) {
      ToastUtil.showErrorMessage(verified.message ?? 'Payment was not completed');
      Navigator.pop(context, false);
      return;
    }
    await _check();
    if (mounted) _timer ??= Timer.periodic(_interval, (_) => _check());
  }

  /// Closes the dialog when [result] is final. Returns true if it closed.
  bool _finishWith(CheckoutModel? result) {
    if (result == null || !mounted) return false;
    if (result.status != null) setState(() => _statusText = result.status);
    if (result.isPaid) {
      _timer?.cancel();
      Navigator.pop(context, true);
      return true;
    }
    // Failed, or the attempt closed (is_open false) without being paid.
    if (result.isFinal) {
      _timer?.cancel();
      ToastUtil.showErrorMessage(result.message ?? 'Payment was not completed');
      Navigator.pop(context, false);
      return true;
    }
    return false; // Still open or reconciling: keep polling.
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    if (_checking || !mounted) return;
    if (DateTime.now().difference(_startedAt) > _maxWait) {
      _timer?.cancel();
      setState(() => _timedOut = true);
      return;
    }
    setState(() => _checking = true);
    final CheckoutModel? result = await widget.provider.fetchCheckoutPaymentStatus();
    if (!mounted) return;
    setState(() => _checking = false);
    _finishWith(result);
  }

  void _checkAgain() {
    if (_timedOut) {
      setState(() => _timedOut = false);
      _timer?.cancel();
      _timer = Timer.periodic(_interval, (_) => _check());
    }
    _check();
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColorsTheme.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 18.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(color: primaryOrange.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: _timedOut
                    ? Icon(Icons.hourglass_bottom_rounded, size: 34.sp, color: primaryOrange)
                    : SizedBox.square(
                        dimension: 34.sp,
                        child: const CircularProgressIndicator(strokeWidth: 3, color: primaryOrange),
                      ),
              ),
              UIHelper.verticalSpace(16.h),
              Text(
                (_timedOut ? 'Still waiting for payment' : 'Waiting for payment').tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
              UIHelper.verticalSpace(6.h),
              Text(
                'Complete the payment in the gateway page. We will confirm it automatically when you come back.'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5.sp, height: 1.4, color: muted),
              ),
              if (_statusText != null) ...[
                UIHelper.verticalSpace(10.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColorsTheme.innerCardBg(context),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${'Status'.tr}: $_statusText',
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: muted),
                  ),
                ),
              ],
              UIHelper.verticalSpace(18.h),
              GradientButton(
                label: 'I have paid — check now'.tr,
                trailingIcon: Icons.refresh_rounded,
                height: 48.h,
                isLoading: _checking,
                onPressed: _checkAgain,
              ),
              UIHelper.verticalSpace(8.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => CheckoutPaymentFlow._open(widget.paymentUrl),
                      icon: Icon(Icons.open_in_new_rounded, size: 16.sp),
                      label: Text(
                        'Open payment page'.tr,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                      ),
                      style: TextButton.styleFrom(foregroundColor: primaryOrange),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(foregroundColor: muted),
                      child: Text(
                        'Cancel'.tr,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
