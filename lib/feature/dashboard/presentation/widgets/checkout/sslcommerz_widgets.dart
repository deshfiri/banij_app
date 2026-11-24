import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../common_widget/gradient_button.dart';
import '../../../../../constants/color.dart';
import '../../../../../constants/sslcommerz_config.dart';
import '../../../../../helpers/all_routes.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../data/sslcommerz_service.dart';
import '../../../model/sslcommerz_models.dart';

const Color _sslBlue = Color(0xFF1E4E9C);
const Color _green = Color(0xFF10B981);

/// Payment methods SSLCommerz offers on its page (shown as chips).
const _methods = <(IconData, String, Color)>[
  (Icons.account_balance_wallet_rounded, 'bKash', Color(0xFFE2136E)),
  (Icons.mobile_friendly_rounded, 'Nagad', Color(0xFFEC1C24)),
  (Icons.phone_android_rounded, 'Rocket', Color(0xFF8C3494)),
  (Icons.credit_card_rounded, 'Visa', Color(0xFF1A1F71)),
  (Icons.credit_card_rounded, 'Mastercard', Color(0xFFEB001B)),
  (Icons.credit_card_rounded, 'AMEX', Color(0xFF2E77BC)),
  (Icons.account_balance_rounded, 'Net banking', Color(0xFF0F766E)),
];

// -----------------------------------------------------------------------------
// 1. Review sheet
// -----------------------------------------------------------------------------

/// "Pay with SSLCommerz" review sheet: amount, accepted methods, Pay button.
/// Returns true when the user taps Pay.
class SslCommerzReviewSheet extends StatelessWidget {
  final String amountText;
  final String? description;

  const SslCommerzReviewSheet({super.key, required this.amountText, this.description});

  static Future<bool> show(BuildContext context, {required String amountText, String? description}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28.r))),
      builder: (_) => SslCommerzReviewSheet(amountText: amountText, description: description),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42.w,
                    height: 4.5.h,
                    decoration: BoxDecoration(color: muted.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
                UIHelper.verticalSpace(16.h),
                // Brand header.
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: _sslBlue.withValues(alpha: isDark ? 0.25 : 0.1),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(Icons.verified_user_rounded, color: isDark ? Colors.lightBlueAccent : _sslBlue, size: 24.sp),
                    ),
                    UIHelper.horizontalSpace(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pay with SSLCommerz'.tr,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                          Text(
                            'Bangladesh\'s secure payment gateway'.tr,
                            style: TextStyle(fontSize: 11.5.sp, color: muted),
                          ),
                        ],
                      ),
                    ),
                    if (SslCommerzConfig.directSandboxEnabled) const _SandboxBadge(),
                  ],
                ),
                UIHelper.verticalSpace(18.h),
                // Amount.
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColorsTheme.heroGradient(context),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AMOUNT TO PAY'.tr,
                        style: TextStyle(
                          fontSize: 10.sp,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      UIHelper.verticalSpace(2.h),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          amountText,
                          style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                      if (description != null) ...[
                        UIHelper.verticalSpace(2.h),
                        Text(
                          description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ],
                    ],
                  ),
                ),
                UIHelper.verticalSpace(16.h),
                Text(
                  'Choose any of these on the next page'.tr,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColorsTheme.textMainColor(context)),
                ),
                UIHelper.verticalSpace(10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [for (final (icon, label, color) in _methods) _MethodChip(icon: icon, label: label, color: color)],
                ),
                UIHelper.verticalSpace(18.h),
                GradientButton(
                  label: '${'Pay'.tr} $amountText',
                  trailingIcon: Icons.lock_rounded,
                  onPressed: () => Navigator.pop(context, true),
                ),
                UIHelper.verticalSpace(10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 13.sp, color: muted),
                    UIHelper.horizontalSpace(4.w),
                    Flexible(
                      child: Text(
                        'Your card and wallet details are entered on SSLCommerz, never in this app.'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10.5.sp, color: muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SandboxBadge extends StatelessWidget {
  const _SandboxBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
      ),
      child: Text(
        'SANDBOX',
        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 0.6, color: const Color(0xFFF59E0B)),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MethodChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.innerCardBg(context),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          UIHelper.horizontalSpace(5.w),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColorsTheme.textMainColor(context)),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. Verify dialog
// -----------------------------------------------------------------------------

/// Looks the transaction up with SSLCommerz until it is VALID or clearly
/// failed (a few tries over ~20 s). Returns the transaction, or null.
class SslCommerzVerifyDialog extends StatefulWidget {
  final String transactionId;

  const SslCommerzVerifyDialog({super.key, required this.transactionId});

  static Future<SslCommerzTransaction?> show(BuildContext context, String transactionId) {
    return showDialog<SslCommerzTransaction?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SslCommerzVerifyDialog(transactionId: transactionId),
    );
  }

  @override
  State<SslCommerzVerifyDialog> createState() => _SslCommerzVerifyDialogState();
}

class _SslCommerzVerifyDialogState extends State<SslCommerzVerifyDialog> {
  static const _maxTries = 6;
  SslCommerzTransaction? _last;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    for (var i = 0; i < _maxTries && mounted; i++) {
      final tx = await SslCommerzService.instance.findTransaction(widget.transactionId);
      if (!mounted) return;
      _last = tx ?? _last;
      if (tx != null && (tx.isPaid || tx.isFailed)) break;
      await Future.delayed(const Duration(seconds: 3));
    }
    if (mounted) Navigator.pop(context, _last);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColorsTheme.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(22.w, 26.h, 22.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 46.sp,
                child: const CircularProgressIndicator(strokeWidth: 3.5, color: primaryOrange),
              ),
              UIHelper.verticalSpace(18.h),
              Text(
                'Confirming your payment'.tr,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColorsTheme.textMainColor(context)),
              ),
              UIHelper.verticalSpace(6.h),
              Text(
                'Checking with SSLCommerz. Please don\'t close the app.'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. Receipt
// -----------------------------------------------------------------------------

/// "Payment Successful" receipt with the SSLCommerz transaction details.
class SslCommerzReceiptDialog extends StatelessWidget {
  final SslCommerzTransaction transaction;
  final String amountText;

  const SslCommerzReceiptDialog({super.key, required this.transaction, required this.amountText});

  static Future<void> show(BuildContext context, {required SslCommerzTransaction transaction, required String amountText}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SslCommerzReceiptDialog(transaction: transaction, amountText: amountText),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('Amount paid'.tr, amountText),
      if (transaction.methodLabel != null) ('Paid with'.tr, transaction.methodLabel!),
      if (transaction.transactionId != null) ('Transaction ID'.tr, transaction.transactionId!),
      if (transaction.bankTransactionId != null) ('Bank reference'.tr, transaction.bankTransactionId!),
      if (transaction.tranDate != null) ('Date'.tr, transaction.tranDate!),
    ];

    return Dialog(
      backgroundColor: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: EdgeInsets.fromLTRB(22.w, 26.h, 22.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(color: _green.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [_green, Color(0xFF059669)]),
                  ),
                  child: Icon(Icons.check_rounded, size: 34.sp, color: Colors.white),
                ),
              ),
              UIHelper.verticalSpace(16.h),
              Text(
                'Payment Successful'.tr,
                style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w900, color: AppColorsTheme.textMainColor(context)),
              ),
              UIHelper.verticalSpace(4.h),
              Text(
                'Your order has been placed and paid.'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
              ),
              UIHelper.verticalSpace(16.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColorsTheme.innerCardBg(context),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < rows.length; i++) ...[
                      if (i > 0) Divider(height: 1, color: AppColorsTheme.borderColor(context)),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 9.h),
                        child: Row(
                          children: [
                            Text(rows[i].$1, style: TextStyle(fontSize: 11.5.sp, color: AppColorsTheme.textMutedColor(context))),
                            UIHelper.horizontalSpace(12.w),
                            Expanded(
                              child: Text(
                                rows[i].$2,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: i == 0 ? primaryOrange : AppColorsTheme.textMainColor(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              UIHelper.verticalSpace(18.h),
              GradientButton(
                label: 'Back to Dashboard'.tr,
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  navigator.pushReplacementNamed(Routes.dashboardScreen);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
