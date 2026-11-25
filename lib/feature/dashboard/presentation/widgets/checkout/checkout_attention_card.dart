import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/wholesale_cart_model.dart';

const Color _amber = Color(0xFFF59E0B);

/// Shown at the top of checkout when the server answers `cart_not_ready`:
/// the reason, each problem line, and the actions that fix it.
class CheckoutAttentionCard extends StatelessWidget {
  final String message;
  final List<WholesaleCartLine> problemLines;
  final bool hasPriceChanges;
  final bool isBusy;
  final VoidCallback onAcceptPrices;
  final VoidCallback onReviewCart;

  const CheckoutAttentionCard({
    super.key,
    required this.message,
    required this.problemLines,
    required this.hasPriceChanges,
    required this.isBusy,
    required this.onAcceptPrices,
    required this.onReviewCart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _amber.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _amber.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: _amber.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.warning_amber_rounded, size: 18.sp, color: _amber),
              ),
              UIHelper.horizontalSpace(10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your cart needs attention'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),
                    Text(
                      message,
                      style: TextStyle(fontSize: 12.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (problemLines.isNotEmpty) ...[
            UIHelper.verticalSpace(12.h),
            for (final line in problemLines) _ProblemLine(line: line),
          ],
          UIHelper.verticalSpace(6.h),
          Row(
            children: [
              if (hasPriceChanges) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isBusy ? null : onAcceptPrices,
                    icon: isBusy
                        ? SizedBox.square(
                            dimension: 14.sp,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(Icons.price_check_rounded, size: 16.sp),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Accept new prices'.tr, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: Size(0, 40.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ),
                UIHelper.horizontalSpace(10.w),
              ],
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isBusy ? null : onReviewCart,
                  icon: Icon(Icons.shopping_cart_outlined, size: 16.sp),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Review cart'.tr, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800)),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryOrange,
                    side: BorderSide(color: primaryOrange.withValues(alpha: 0.6)),
                    minimumSize: Size(0, 40.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shown when `GET /checkout/payment` reports an attempt still open (e.g.
/// the app was closed during payment): lets the user check its status
/// instead of paying twice.
class CheckoutOpenPaymentCard extends StatelessWidget {
  final String? status;
  final VoidCallback onCheckStatus;

  const CheckoutOpenPaymentCard({super.key, required this.status, required this.onCheckStatus});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF3B82F6);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: blue.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: blue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10.r)),
            child: Icon(Icons.sync_rounded, size: 18.sp, color: blue),
          ),
          UIHelper.horizontalSpace(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A payment is in progress'.tr,
                  style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800, color: AppColorsTheme.textMainColor(context)),
                ),
                UIHelper.verticalSpace(2.h),
                Text(
                  'Check its status before paying again.'.tr,
                  style: TextStyle(fontSize: 11.5.sp, color: AppColorsTheme.textMutedColor(context)),
                ),
              ],
            ),
          ),
          UIHelper.horizontalSpace(8.w),
          TextButton(
            onPressed: onCheckStatus,
            style: TextButton.styleFrom(
              foregroundColor: blue,
              backgroundColor: blue.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            ),
            child: Text('Check status'.tr, style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

/// One problem line: product name and readable reasons.
class _ProblemLine extends StatelessWidget {
  final WholesaleCartLine line;

  const _ProblemLine({required this.line});

  /// Turns API problem codes into sentences, using the line's own limits.
  List<String> _reasons() {
    final reasons = <String>[];
    for (final code in line.problems ?? const <String>[]) {
      final c = code.toLowerCase();
      if (c.contains('min')) {
        reasons.add('Minimum order is @count'.trParams({'count': '${line.minOrderQuantity ?? '-'}'}));
      } else if (c.contains('max')) {
        reasons.add('Maximum order is @count'.trParams({'count': '${line.maxOrderQuantity ?? '-'}'}));
      } else if (c.contains('stock') || c.contains('available') || c.contains('quantity')) {
        reasons.add(line.available != null
            ? 'Only @count available'.trParams({'count': '${line.available}'})
            : 'Not enough stock'.tr);
      } else if (c.contains('price')) {
        reasons.add('Price has changed'.tr);
      } else if (c.contains('unavailable') || c.contains('inactive') || c.contains('purchas')) {
        reasons.add('No longer available'.tr);
      } else {
        // Already a sentence from the API, or an unknown code made readable.
        final text = code.replaceAll(RegExp(r'[_-]+'), ' ').trim();
        if (text.isNotEmpty) reasons.add(text[0].toUpperCase() + text.substring(1));
      }
    }
    if (line.priceChanged == true && !reasons.contains('Price has changed'.tr)) {
      final now = line.unitPrice?.formatted;
      final seen = line.unitPriceSeen?.formatted;
      reasons.add(now != null && seen != null
          ? 'Price changed from @old to @new'.trParams({'old': seen, 'new': now})
          : 'Price has changed'.tr);
    }
    if (line.purchasable == false && reasons.isEmpty) reasons.add('No longer available'.tr);
    return reasons;
  }

  @override
  Widget build(BuildContext context) {
    final reasons = _reasons();
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 16.sp, color: _amber),
          UIHelper.horizontalSpace(8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product?.name ?? 'Product Item'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                for (final reason in reasons)
                  Text(
                    reason,
                    style: TextStyle(fontSize: 11.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
