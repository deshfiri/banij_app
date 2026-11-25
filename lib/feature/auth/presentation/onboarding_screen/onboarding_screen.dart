import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/gradient_button.dart';
import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import '../login_screen/loginScreen.dart';
import '../widgets/auth_scaffold.dart';
import 'widgets/onboarding_page_indicator.dart';
import 'widgets/onboarding_slide.dart';
import 'widgets/onboarding_slide_view.dart';
import 'widgets/wave_reveal_route.dart';

/// Intro carousel in the dashboard style: hero gradient top with the white
/// logo and theme/language toggles, auto-sliding illustration pages, and a
/// gradient "Get Started" button.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Duration _autoSlideInterval = Duration(milliseconds: 4500);
  static const Duration _slideDuration = Duration(milliseconds: 600);
  static const List<OnboardingSlide> _slides = OnboardingSlide.all;

  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoSlide();
  }

  /// (Re)starts auto-sliding, so a manual swipe gets a full interval
  /// before the next automatic move.
  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(_autoSlideInterval, (_) {
      if (!_pageController.hasClients) return;
      _pageController.animateToPage(
        (_currentPage + 1) % _slides.length,
        duration: _slideDuration,
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _goToPage(int index) {
    _pageController.animateToPage(index, duration: _slideDuration, curve: Curves.easeInOutCubic);
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(context, WaveRevealRoute(page: const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      heroHeight: 240,
      showToggleSnackBars: true,
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollStartNotification>(
              // A finger drag (not the timer) restarts the auto-slide clock.
              onNotification: (notification) {
                if (notification.dragDetails != null) _startAutoSlide();
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (_, index) => _CarouselPage(
                  controller: _pageController,
                  index: index,
                  child: OnboardingSlideView(slide: _slides[index]),
                ),
              ),
            ),
          ),
          UIHelper.verticalSpace(4.h),
          OnboardingPageIndicator(count: _slides.length, current: _currentPage, onTap: _goToPage),
          _OnboardingActions(onGetStarted: _navigateToLogin, onSkip: _navigateToLogin),
        ],
      ),
    );
  }
}

/// Carousel effect: pages leaving the centre shrink and fade slightly.
class _CarouselPage extends StatelessWidget {
  final PageController controller;
  final int index;
  final Widget child;

  const _CarouselPage({required this.controller, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        double page = index.toDouble();
        if (controller.hasClients && controller.position.haveDimensions) {
          page = controller.page ?? page;
        }
        final distance = (page - index).abs().clamp(0.0, 1.0);
        return Opacity(
          opacity: 1 - distance * 0.45,
          child: Transform.scale(scale: 1 - distance * 0.08, child: child),
        );
      },
    );
  }
}

/// "GET STARTED" gradient button and "SKIP" text link.
class _OnboardingActions extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSkip;

  const _OnboardingActions({required this.onGetStarted, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 8.h),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GradientButton(
              label: 'get_started'.tr.toUpperCase(),
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: onGetStarted,
            ),
            UIHelper.verticalSpace(8.h),
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(foregroundColor: AppColorsTheme.textMutedColor(context)),
              child: Text(
                'skip'.tr.toUpperCase(),
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, letterSpacing: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
