import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import 'onboarding_slide.dart';

/// One page: illustration card, badge, title, subtitle — vertically
/// centred in the space the carousel gives it. The card height follows the
/// available height (clamped), so short phones never overflow and tall
/// phones don't leave a gap; it only scrolls if the text still doesn't fit.
class OnboardingSlideView extends StatelessWidget {
  final OnboardingSlide slide;

  const OnboardingSlideView({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardHeight = (constraints.maxHeight * 0.55).clamp(170.0, 320.0);

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: ConstrainedBox(
            // At least the slide's height, so short content stays centred.
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _IllustrationCard(imageAsset: slide.imageAsset, height: cardHeight),
                      UIHelper.verticalSpace(24.h),
                      _BadgePill(label: slide.badgeKey.tr, icon: slide.badgeIcon),
                      UIHelper.verticalSpace(12.h),
                      Text(
                        slide.titleKey.tr.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          height: 1.25,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                      UIHelper.verticalSpace(10.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          slide.subtitleKey.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13.sp, height: 1.5, color: AppColorsTheme.textMutedColor(context)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// White (dark: card) rounded card with a soft orange halo behind the image.
class _IllustrationCard extends StatelessWidget {
  final String imageAsset;
  final double height;

  const _IllustrationCard({required this.imageAsset, required this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: isDark ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.15), width: 1.w),
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
          // Halo scales with the card so it stays centred behind the image.
          Container(
            width: height * 0.6,
            height: height * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryOrange.withValues(alpha: isDark ? 0.12 : 0.08),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
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
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: primaryOrange),
            ),
          ),
        ],
      ),
    );
  }
}
