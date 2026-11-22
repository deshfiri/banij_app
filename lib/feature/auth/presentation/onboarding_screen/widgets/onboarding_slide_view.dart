import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import 'onboarding_slide.dart';

/// One page: illustration card floating over the hero, badge, title, subtitle.
class OnboardingSlideView extends StatelessWidget {
  final OnboardingSlide slide;

  const OnboardingSlideView({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 12.h),
      child: Column(
        children: [
          _IllustrationCard(imageAsset: slide.imageAsset),
          UIHelper.verticalSpace(22.h),
          _BadgePill(label: slide.badgeKey.tr, icon: slide.badgeIcon),
          UIHelper.verticalSpace(12.h),
          Text(
            slide.titleKey.tr.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              slide.subtitleKey.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, height: 1.45, color: AppColorsTheme.textMutedColor(context)),
            ),
          ),
        ],
      ),
    );
  }
}

/// White (dark: card) rounded card with a soft orange halo behind the image.
class _IllustrationCard extends StatelessWidget {
  final String imageAsset;

  const _IllustrationCard({required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 286.h,
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: isDark ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.15),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.35) : primaryOrange.withValues(alpha: 0.18),
            blurRadius: 24.r,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160.w,
            height: 160.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryOrange.withValues(alpha: isDark ? 0.12 : 0.08),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(18.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(Icons.business_center_rounded, size: 60.sp, color: primaryOrange),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _BadgePill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: primaryOrange.withValues(alpha: isDark ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: primaryOrange.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: primaryOrange),
          UIHelper.horizontalSpace(5.w),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: primaryOrange),
          ),
        ],
      ),
    );
  }
}
