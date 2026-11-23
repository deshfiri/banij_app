import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../common_widget/gradient_button.dart';
import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';

/// Checkout footer: tappable "Total" header that expands to show subtotal and
/// shipping, then the primary "Place Order" / "Add address" gradient button.
class CheckoutBottomBar extends StatefulWidget {
  final String totalText;
  final String subtotalText;
  final String shippingText;
  final bool isLoading;
  final bool hasAddress;
  final VoidCallback onPrimaryPressed;

  const CheckoutBottomBar({
    super.key,
    required this.totalText,
    required this.subtotalText,
    required this.shippingText,
    required this.isLoading,
    required this.hasAddress,
    required this.onPrimaryPressed,
  });

  @override
  State<CheckoutBottomBar> createState() => _CheckoutBottomBarState();
}

class _CheckoutBottomBarState extends State<CheckoutBottomBar> {
  bool _isSummaryExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = AppColorsTheme.textMutedColor(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border(
          top: BorderSide(color: isDark ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.15), width: 1.w),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.35) : primaryOrange.withValues(alpha: 0.10),
            blurRadius: 24.r,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => setState(() => _isSummaryExpanded = !_isSummaryExpanded),
                borderRadius: BorderRadius.circular(10.r),
                child: Row(
                  children: [
                    Text(
                      'Total'.tr,
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: muted),
                    ),
                    UIHelper.horizontalSpace(8.w),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.totalText,
                          maxLines: 1,
                          style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isSummaryExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: primaryOrange.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.keyboard_arrow_up_rounded, color: primaryOrange, size: 20.sp),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: _isSummaryExpanded
                    ? Container(
                        margin: EdgeInsets.only(top: 10.h),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isDark ? AppColorsTheme.innerCardBg(context) : lightBackground,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          children: [
                            _SummaryRow(label: 'Items Subtotal'.tr, value: widget.subtotalText),
                            UIHelper.verticalSpace(6.h),
                            _SummaryRow(label: 'Shipping Fee'.tr, value: widget.shippingText),
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
              UIHelper.verticalSpace(12.h),
              GradientButton(
                label: widget.hasAddress ? 'Place Order'.tr : 'Add address'.tr,
                trailingIcon: widget.hasAddress ? Icons.arrow_forward_rounded : Icons.add_location_alt_rounded,
                isLoading: widget.isLoading,
                onPressed: widget.onPrimaryPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context))),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800, color: AppColorsTheme.textMainColor(context)),
        ),
      ],
    );
  }
}
