import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../dashboard_card_decoration.dart';

/// Dashboard-style card for one checkout section: tinted [icon] (or an orange
/// accent bar when no icon is given) + title, optional trailing widget, then
/// [child].
class CheckoutSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final VoidCallback? onTap;
  final IconData? icon;

  const CheckoutSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final radius = 20.r;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          padding: EdgeInsets.all(14.w),
          decoration: DashboardCardDecoration.of(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null)
                    Container(
                      padding: EdgeInsets.all(7.w),
                      decoration: BoxDecoration(
                        color: primaryOrange.withValues(alpha: isDark ? 0.18 : 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(icon, size: 16.sp, color: primaryOrange),
                    )
                  else
                    Container(
                      width: 4.w,
                      height: 15.h,
                      decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(2.r)),
                    ),
                  UIHelper.horizontalSpace(icon != null ? 10.w : 8.w),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
              UIHelper.verticalSpace(14.h),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon inside a tinted circle (address pin, delivery truck, payment brand…).
class CheckoutIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double? size;

  const CheckoutIconBadge({super.key, required this.icon, this.color = primaryOrange, this.size});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final box = size ?? 40.w;

    return Container(
      width: box,
      height: box,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color.withValues(alpha: isDark ? 0.18 : 0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: box * 0.5),
    );
  }
}

/// Selectable option row: orange border + tinted surface + check when selected
/// (same look as the selected package card). Used for payment methods and the
/// address picker.
class CheckoutOptionTile extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const CheckoutOptionTile({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(14.r);
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryOrange.withValues(alpha: isDark ? 0.14 : 0.06)
                  : (isDark ? AppColorsTheme.innerCardBg(context) : lightBackground),
              borderRadius: radius,
              border: Border.all(
                color: isSelected ? primaryOrange : (isDark ? darkCardBorderColor : cardBorderColor),
                width: isSelected ? 1.6.w : 1.w,
              ),
            ),
            child: Row(
              children: [
                leading,
                UIHelper.horizontalSpace(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                      if (hasSubtitle) ...[
                        UIHelper.verticalSpace(2.h),
                        Text(
                          subtitle!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11.sp, height: 1.35, color: AppColorsTheme.textMutedColor(context)),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[UIHelper.horizontalSpace(6.w), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small grey pill with a number, e.g. the item count next to "Order items".
class CheckoutCountBadge extends StatelessWidget {
  final String label;

  const CheckoutCountBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.innerCardBg(context),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w800,
          color: AppColorsTheme.textMutedColor(context),
        ),
      ),
    );
  }
}

/// Order summary card: subtotal, shipping, divider, emphasised total.
class CheckoutSummaryCard extends StatelessWidget {
  final String subtotalText;
  final String shippingText;
  final String totalText;
  final String? couponText;

  const CheckoutSummaryCard({
    super.key,
    required this.subtotalText,
    required this.shippingText,
    required this.totalText,
    this.couponText,
  });

  @override
  Widget build(BuildContext context) {
    return CheckoutSectionCard(
      title: 'Order summary'.tr,
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          _SummaryLine(icon: Icons.shopping_bag_outlined, label: 'Items Subtotal'.tr, value: subtotalText),
          UIHelper.verticalSpace(10.h),
          _SummaryLine(icon: Icons.local_shipping_outlined, label: 'Shipping Fee'.tr, value: shippingText),
          if (couponText != null && couponText!.isNotEmpty) ...[
            UIHelper.verticalSpace(10.h),
            _SummaryLine(
              icon: Icons.confirmation_number_outlined,
              label: 'Apply Voucher'.tr,
              value: couponText!,
              valueColor: successGreen,
            ),
          ],
          UIHelper.verticalSpace(12.h),
          Divider(height: 1, color: AppColorsTheme.borderColor(context)),
          UIHelper.verticalSpace(12.h),
          Row(
            children: [
              Text(
                'Total'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
              UIHelper.horizontalSpace(12.w),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    totalText,
                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: primaryOrange),
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

class _SummaryLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryLine({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    return Row(
      children: [
        Icon(icon, size: 15.sp, color: muted),
        UIHelper.horizontalSpace(8.w),
        Expanded(child: Text(label, style: TextStyle(fontSize: 12.sp, color: muted))),
        UIHelper.horizontalSpace(8.w),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColorsTheme.textMainColor(context),
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact orange gradient pill button (Apply coupon, stepper +/−).
class CheckoutPillButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BoxShape shape;

  const CheckoutPillButton({
    super.key,
    required this.onTap,
    required this.child,
    this.padding,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : 0.6,
        child: Container(
          padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
          alignment: shape == BoxShape.circle ? Alignment.center : null,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [primaryOrange, secondaryOrange]),
            shape: shape,
            borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(color: primaryOrange.withValues(alpha: 0.3), blurRadius: 8.r, offset: const Offset(0, 3)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
