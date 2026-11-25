import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/gradient_button.dart';
import '../../../../common_widget/payment_status_badge.dart';
import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../model/checkout_model.dart';
import '../../model/payment_status.dart';

/// Outcome of a payment attempt, as decided by the backend.
class PaymentResultData {
  final PaymentStatus status;

  /// Latest `GET /checkout/payment` (or verify) answer, when there is one.
  final CheckoutModel? payment;

  /// Optional override of the message (e.g. for wholesale orders).
  final String? message;

  const PaymentResultData(this.status, {this.payment, this.message});
}

/// What the user chose on the result screen.
enum PaymentResultAction { done, retry, checkAgain, back }

/// Full-screen payment result: success, failed, cancelled, pending /
/// processing — with the details and the next actions for each.
class PaymentResultScreen extends StatelessWidget {
  final PaymentResultData result;
  final String amountText;

  /// Retrying is offered only where a new attempt makes sense.
  final bool canRetry;

  const PaymentResultScreen({
    super.key,
    required this.result,
    required this.amountText,
    this.canRetry = true,
  });

  static Future<PaymentResultAction> open(
    BuildContext context, {
    required PaymentResultData result,
    required String amountText,
    bool canRetry = true,
  }) async {
    final action = await Navigator.push<PaymentResultAction>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PaymentResultScreen(result: result, amountText: amountText, canRetry: canRetry),
      ),
    );
    return action ?? PaymentResultAction.back;
  }

  ({String title, String message, Color color, IconData icon}) get _content {
    final custom = result.message;
    return switch (result.status) {
      PaymentStatus.paid => (
          title: 'Payment successful',
          message: custom ?? 'Your payment was confirmed by SSLCommerz. Thank you!',
          color: PaymentStatus.paid.color,
          icon: Icons.check_rounded,
        ),
      PaymentStatus.failed => (
          title: 'Payment failed',
          message: custom ?? 'The payment did not go through and no money was taken. You can try again.',
          color: PaymentStatus.failed.color,
          icon: Icons.close_rounded,
        ),
      PaymentStatus.cancelled => (
          title: 'Payment cancelled',
          message: custom ?? 'You left the payment before finishing. Nothing was charged.',
          color: PaymentStatus.cancelled.color,
          icon: Icons.block_rounded,
        ),
      PaymentStatus.refunded || PaymentStatus.partiallyRefunded => (
          title: 'Payment refunded',
          message: custom ?? 'This payment was refunded.',
          color: PaymentStatus.refunded.color,
          icon: Icons.undo_rounded,
        ),
      _ => (
          title: 'Payment pending',
          message: custom ??
              'We have not received a confirmation yet. If you paid, it will be confirmed shortly — do not pay again.',
          color: PaymentStatus.pending.color,
          icon: Icons.hourglass_top_rounded,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final content = _content;
    final status = result.status;
    final isPaid = status == PaymentStatus.paid;
    final isRetryable = canRetry && (status == PaymentStatus.failed || status == PaymentStatus.cancelled);
    final isPending = !status.isFinal;
    final reference = result.payment?.reference;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, isPaid ? PaymentResultAction.done : PaymentResultAction.back);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColorsTheme.background(context),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    children: [
                      _Illustration(color: content.color, icon: content.icon),
                      UIHelper.verticalSpace(22.h),
                      Text(
                        content.title.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                      UIHelper.verticalSpace(8.h),
                      Text(
                        content.message.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.5,
                          color: AppColorsTheme.textMutedColor(context),
                        ),
                      ),
                      UIHelper.verticalSpace(22.h),
                      _DetailsCard(
                        rows: [
                          ('Amount'.tr, Text(
                            result.payment?.amountText ?? amountText,
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                          )),
                          ('Payment method'.tr, Text(
                            'SSLCommerz',
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          )),
                          ('Status'.tr, PaymentStatusBadge(rawStatus: result.payment?.status ?? status.label)),
                          if (reference != null)
                            ('Reference'.tr, SelectableText(
                              reference,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColorsTheme.textMainColor(context),
                              ),
                            )),
                        ],
                      ),
                      UIHelper.verticalSpace(26.h),
                      if (isPaid)
                        GradientButton(
                          label: 'Continue'.tr,
                          trailingIcon: Icons.arrow_forward_rounded,
                          onPressed: () => Navigator.pop(context, PaymentResultAction.done),
                        )
                      else if (isRetryable)
                        GradientButton(
                          label: 'Try again'.tr,
                          trailingIcon: Icons.refresh_rounded,
                          onPressed: () => Navigator.pop(context, PaymentResultAction.retry),
                        )
                      else if (isPending && canRetry)
                        GradientButton(
                          label: 'Check status again'.tr,
                          trailingIcon: Icons.refresh_rounded,
                          onPressed: () => Navigator.pop(context, PaymentResultAction.checkAgain),
                        ),
                      if (!isPaid) ...[
                        UIHelper.verticalSpace(10.h),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, PaymentResultAction.back),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColorsTheme.textMainColor(context),
                              side: BorderSide(color: AppColorsTheme.borderColor(context)),
                              minimumSize: Size(0, 50.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
                            ),
                            child: Text('Back'.tr, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Large status illustration: soft halo, ring, gradient disc with the icon.
class _Illustration extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _Illustration({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        width: 132.w,
        height: 132.w,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.08)),
        child: Center(
          child: Container(
            width: 102.w,
            height: 102.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.14)),
            child: Center(
              child: Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [color, Color.lerp(color, Colors.black, 0.18)!]),
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 16.r, offset: const Offset(0, 6))],
                ),
                child: Icon(icon, size: 38.sp, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final List<(String, Widget)> rows;

  const _DetailsCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColorsTheme.borderColor(context)),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                children: [
                  Text(rows[i].$1, style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context))),
                  UIHelper.horizontalSpace(12.w),
                  Expanded(child: Align(alignment: Alignment.centerRight, child: rows[i].$2)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
