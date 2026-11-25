import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/hero_page_header.dart';
import '../../../../common_widget/payment_status_badge.dart';
import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/dashboard_provider.dart';
import '../../model/checkout_model.dart';
import '../../model/payment_status.dart';
import '../sslcommerz_payment_screen.dart';
import 'payment_result_screen.dart';

/// "Confirming your payment" screen shown after SSLCommerz.
///
/// The app never decides the outcome itself: it asks the backend to check
/// with the gateway (`POST /checkout/payment/verify`), then polls
/// `GET /checkout/payment` while `is_open` is true. It also re-checks when
/// the app returns to the foreground. Pops with a [PaymentResultData].
class PaymentProcessingScreen extends StatefulWidget {
  final DashboardProvider provider;

  /// Gateway page, to reopen if the user left it early. Null when resuming.
  final String? paymentUrl;

  /// What the gateway redirect suggested (only a hint; the backend decides).
  final GatewayOutcome gatewayOutcome;

  const PaymentProcessingScreen({
    super.key,
    required this.provider,
    required this.gatewayOutcome,
    this.paymentUrl,
  });

  static Future<PaymentResultData> open(
    BuildContext context, {
    required DashboardProvider provider,
    required GatewayOutcome gatewayOutcome,
    String? paymentUrl,
  }) async {
    final result = await Navigator.push<PaymentResultData>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentProcessingScreen(
          provider: provider,
          gatewayOutcome: gatewayOutcome,
          paymentUrl: paymentUrl,
        ),
      ),
    );
    return result ?? const PaymentResultData(PaymentStatus.pending);
  }

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const _interval = Duration(seconds: 4);
  static const _maxWait = Duration(minutes: 5);

  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
  Timer? _timer;
  bool _checking = false;
  bool _done = false;
  bool _timedOut = false;
  CheckoutModel? _latest;
  late DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _start() async {
    // Ask the gateway right away unless the payer cancelled on SSLCommerz.
    if (widget.gatewayOutcome != GatewayOutcome.cancelled) {
      setState(() => _checking = true);
      final verified = await widget.provider.verifyCheckoutPayment();
      if (!mounted) return;
      setState(() => _checking = false);
      if (_handle(verified)) return;
    }
    await _check();
    if (!mounted || _done) return;
    // Cancelled on the gateway and still not paid: report it as cancelled.
    if (widget.gatewayOutcome == GatewayOutcome.cancelled) {
      _finish(PaymentResultData(PaymentStatus.cancelled, payment: _latest));
      return;
    }
    _timer = Timer.periodic(_interval, (_) => _check());
  }

  Future<void> _check() async {
    if (_checking || _done || !mounted) return;
    if (DateTime.now().difference(_startedAt) > _maxWait) {
      _timer?.cancel();
      setState(() => _timedOut = true);
      return;
    }
    setState(() => _checking = true);
    final result = await widget.provider.fetchCheckoutPaymentStatus();
    if (!mounted) return;
    setState(() => _checking = false);
    _handle(result);
  }

  /// Finishes when the backend reports a final state. Returns true if done.
  bool _handle(CheckoutModel? result) {
    if (result == null || !mounted) return false;
    setState(() => _latest = result);
    final status = result.paymentStatus;
    if (status.isFinal || result.isFinal) {
      _finish(PaymentResultData(status.isFinal ? status : PaymentStatus.failed, payment: result));
      return true;
    }
    return false;
  }

  void _finish(PaymentResultData data) {
    if (_done) return;
    _done = true;
    _timer?.cancel();
    Navigator.pop(context, data);
  }

  void _checkAgain() {
    if (_timedOut) {
      _startedAt = DateTime.now();
      setState(() => _timedOut = false);
      _timer?.cancel();
      _timer = Timer.periodic(_interval, (_) => _check());
    }
    _check();
  }

  Future<void> _reopenGateway() async {
    final url = widget.paymentUrl;
    if (url == null) return;
    await SslCommerzPaymentScreen.open(context, url);
    if (mounted) _checkAgain();
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    final status = _latest?.paymentStatus ?? PaymentStatus.processing;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish(PaymentResultData(PaymentStatus.pending, payment: _latest));
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColorsTheme.background(context),
          body: Column(
            children: [
              HeroPageHeader(
                title: 'Payment'.tr,
                subtitle: 'Secured by SSLCommerz'.tr,
                onBack: () => _finish(PaymentResultData(PaymentStatus.pending, payment: _latest)),
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.w),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                          children: [
                            // Pulsing processing illustration.
                            ScaleTransition(
                              scale: Tween(begin: 0.92, end: 1.06).animate(
                                CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                              ),
                              child: Container(
                                width: 120.w,
                                height: 120.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryOrange.withValues(alpha: 0.1),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 84.w,
                                    height: 84.w,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(colors: [primaryOrange, secondaryOrange]),
                                    ),
                                    child: Icon(
                                      _timedOut ? Icons.hourglass_bottom_rounded : Icons.shield_rounded,
                                      color: Colors.white,
                                      size: 40.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            UIHelper.verticalSpace(22.h),
                            Text(
                              (_timedOut ? 'Still confirming your payment' : 'Confirming your payment').tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 19.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColorsTheme.textMainColor(context),
                              ),
                            ),
                            UIHelper.verticalSpace(8.h),
                            Text(
                              'We are checking with SSLCommerz. This usually takes a few seconds — please keep the app open.'
                                  .tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12.5.sp, height: 1.5, color: muted),
                            ),
                            UIHelper.verticalSpace(18.h),
                            PaymentStatusBadge(rawStatus: _latest?.status ?? status.label),
                            UIHelper.verticalSpace(22.h),
                            _Steps(gatewayDone: true, confirming: !_timedOut),
                            UIHelper.verticalSpace(26.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _checking ? null : _checkAgain,
                                icon: _checking
                                    ? SizedBox.square(
                                        dimension: 16.sp,
                                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Icon(Icons.refresh_rounded, size: 18.sp),
                                label: Text(
                                  'Check status now'.tr,
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryOrange,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: primaryOrange.withValues(alpha: 0.6),
                                  disabledForegroundColor: Colors.white,
                                  elevation: 0,
                                  minimumSize: Size(0, 50.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                                ),
                              ),
                            ),
                            if (widget.paymentUrl != null) ...[
                              UIHelper.verticalSpace(8.h),
                              TextButton.icon(
                                onPressed: _reopenGateway,
                                icon: Icon(Icons.open_in_new_rounded, size: 16.sp),
                                label: Text('Reopen payment page'.tr),
                                style: TextButton.styleFrom(foregroundColor: primaryOrange),
                              ),
                            ],
                            TextButton(
                              onPressed: () => _finish(PaymentResultData(PaymentStatus.pending, payment: _latest)),
                              style: TextButton.styleFrom(foregroundColor: muted),
                              child: Text("I'll check later".tr),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three-step progress: submitted on SSLCommerz → confirming → activated.
class _Steps extends StatelessWidget {
  final bool gatewayDone;
  final bool confirming;

  const _Steps({required this.gatewayDone, required this.confirming});

  @override
  Widget build(BuildContext context) {
    Widget step(String label, {required bool done, required bool active}) {
      final color = done ? const Color(0xFF10B981) : (active ? primaryOrange : AppColorsTheme.textMutedColor(context));
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 22.sp,
              child: active && !done
                  ? CircularProgressIndicator(strokeWidth: 2.2, color: color)
                  : Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: color, size: 22.sp),
            ),
            UIHelper.horizontalSpace(12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: done || active ? FontWeight.w700 : FontWeight.w500,
                  color: done || active ? AppColorsTheme.textMainColor(context) : AppColorsTheme.textMutedColor(context),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Column(
        children: [
          step('Payment submitted on SSLCommerz'.tr, done: gatewayDone, active: false),
          step('Confirming with the gateway'.tr, done: false, active: confirming),
          step('Order / package updated'.tr, done: false, active: false),
        ],
      ),
    );
  }
}
