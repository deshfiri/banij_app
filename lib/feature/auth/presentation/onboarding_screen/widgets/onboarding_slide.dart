import '../../../../../constants/image_const.dart';

/// One onboarding slide holding poster image asset.
class OnboardingSlide {
  final String imageAsset;

  const OnboardingSlide({
    required this.imageAsset,
  });

  static const List<OnboardingSlide> all = [
    OnboardingSlide(imageAsset: onboardingPost1),
    OnboardingSlide(imageAsset: onboardingPost2),
    OnboardingSlide(imageAsset: onboardingPost3),
  ];
}
