import 'package:flutter/material.dart';

import '../../../../../constants/image_const.dart';

/// One onboarding page. Keys are translation keys.
class OnboardingSlide {
  final String imageAsset;
  final String badgeKey;
  final IconData badgeIcon;
  final String titleKey;
  final String subtitleKey;

  const OnboardingSlide({
    required this.imageAsset,
    required this.badgeKey,
    required this.badgeIcon,
    required this.titleKey,
    required this.subtitleKey,
  });

  static const List<OnboardingSlide> all = [
    OnboardingSlide(
      imageAsset: productsImage,
      badgeKey: 'business_overview',
      badgeIcon: Icons.storefront_rounded,
      titleKey: 'onboarding_title_1',
      subtitleKey: 'onboarding_subtitle_1',
    ),
    OnboardingSlide(
      imageAsset: myProductsImage,
      badgeKey: 'order_operations',
      badgeIcon: Icons.receipt_long_rounded,
      titleKey: 'onboarding_title_2',
      subtitleKey: 'onboarding_subtitle_2',
    ),
    OnboardingSlide(
      imageAsset: onboardingGlobalImage,
      badgeKey: 'global_network',
      badgeIcon: Icons.public_rounded,
      titleKey: 'onboarding_title_3',
      subtitleKey: 'onboarding_subtitle_3',
    ),
  ];
}
