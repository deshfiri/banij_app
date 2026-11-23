import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';

/// Green used for completed KYC states (same value as [successGreen]).
const Color kycSuccessGreen = Color(0xFF10B981);

/// Rounded section card (card background, border, 18 padding) used by the KYC screen.
class KycSectionCard extends StatelessWidget {
  final Widget child;
  final bool withShadow;

  const KycSectionCard({super.key, required this.child, this.withShadow = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColorsTheme.borderColor(context),
          width: 1.w,
        ),
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.03),
                  blurRadius: 10.r,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// Section title + muted description pair.
class KycTitleBlock extends StatelessWidget {
  final String title;
  final String description;
  final double titleSize;
  final double descriptionSize;
  final double descriptionHeight;

  const KycTitleBlock({
    super.key,
    required this.title,
    required this.description,
    required this.titleSize,
    required this.descriptionSize,
    required this.descriptionHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        UIHelper.verticalSpace(4.h),
        Text(
          description,
          style: TextStyle(
            fontSize: descriptionSize,
            color: AppColorsTheme.textMutedColor(context),
            height: descriptionHeight,
          ),
        ),
      ],
    );
  }
}

/// Overall KYC status pill: complete / in progress / not started.
class KycStatusBadge extends StatelessWidget {
  final String statusKey;

  const KycStatusBadge({super.key, required this.statusKey});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String text;
    IconData icon;

    switch (statusKey) {
      case 'complete':
        bg = kycSuccessGreen.withValues(alpha: 0.15);
        fg = kycSuccessGreen;
        text = 'complete'.tr;
        icon = Icons.check_circle_outline;
        break;
      case 'in_progress':
        bg = primaryOrange.withValues(alpha: 0.15);
        fg = primaryOrange;
        text = 'in_progress'.tr;
        icon = Icons.hourglass_top_rounded;
        break;
      default:
        bg = AppColorsTheme.textMutedColor(context).withValues(alpha: 0.12);
        fg = AppColorsTheme.textMutedColor(context);
        text = 'not_started'.tr;
        icon = Icons.radio_button_unchecked;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 12.sp),
          UIHelper.horizontalSpace(4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
