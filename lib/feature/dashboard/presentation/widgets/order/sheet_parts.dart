import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';

/// Grab handle at the top of the order/website bottom sheets, with the
/// 12-point gaps above and below it.
class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UIHelper.verticalSpace(12.h),
        Center(
          child: Container(
            width: 42.w,
            height: 4.5.h,
            decoration: BoxDecoration(
              color: AppColorsTheme.textMutedColor(context).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
        UIHelper.verticalSpace(12.h),
      ],
    );
  }
}

/// Rounded-top background used by the full-height order/website sheets.
BoxDecoration sheetDecoration(BuildContext context, {bool withShadow = true}) {
  return BoxDecoration(
    color: AppColorsTheme.background(context),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(28.r),
      topRight: Radius.circular(28.r),
    ),
    boxShadow: withShadow
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20.r,
              offset: const Offset(0, -6),
            ),
          ]
        : null,
  );
}

/// Round icon button in a sheet header (close, export, ...).
class SheetCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;

  const SheetCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
  });

  /// The standard "X" close button that pops the sheet.
  const SheetCircleButton.close({super.key, required this.onTap})
      : icon = Icons.close_rounded,
        backgroundColor = null,
        borderColor = null,
        iconColor = null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColorsTheme.cardBg(context),
          shape: BoxShape.circle,
          border: Border.all(color: borderColor ?? AppColorsTheme.borderColor(context)),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: iconColor ?? AppColorsTheme.textMainColor(context),
        ),
      ),
    );
  }
}

/// Grey/white shimmer colours for the current theme.
class SheetShimmer extends StatelessWidget {
  final Widget child;

  const SheetShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColorsTheme.shimmerBase(context),
      highlightColor: AppColorsTheme.shimmerHighlight(context),
      child: child,
    );
  }
}
