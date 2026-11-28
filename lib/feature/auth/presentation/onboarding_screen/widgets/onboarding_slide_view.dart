import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import 'onboarding_slide.dart';

/// One carousel page: the poster in a floating card that has the poster's
/// exact 4:5 shape, so the image fills it edge to edge with no letterbox
/// bands. The card is as large as the page allows — width-limited on tall
/// phones, height-limited on short ones — and stays centred.
class OnboardingSlideView extends StatelessWidget {
  /// Poster assets are 1080 x 1350.
  static const double posterAspectRatio = 1080 / 1350;

  final OnboardingSlide slide;

  const OnboardingSlideView({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Small side padding: it is the gap between neighbouring cards.
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: AspectRatio(
            aspectRatio: posterAspectRatio,
            child: _PosterCard(imageAsset: slide.imageAsset),
          ),
        ),
      ),
    );
  }
}

/// Rounded poster with a layered soft shadow and a thin inner rim that
/// separates the light poster from the cream page background.
class _PosterCard extends StatelessWidget {
  final String imageAsset;

  const _PosterCard({required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(26.r);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          // Wide, soft brand glow…
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.5) : primaryOrange.withValues(alpha: 0.22),
            blurRadius: 30.r,
            offset: Offset(0, 10.h),
          ),
          // …plus a tight contact shadow so the card reads as lifted.
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 6.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imageAsset,
              // Card and poster share the same ratio, so cover fills the card
              // exactly without cropping (and without sub-pixel gaps).
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => ColoredBox(
                color: AppColorsTheme.cardBg(context),
                child: Center(
                  child: Icon(Icons.image_not_supported_rounded, size: 56.sp, color: primaryOrange),
                ),
              ),
            ),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
