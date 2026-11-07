import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/di.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/theme_provider.dart';
import '../login_screen/loginScreen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late bool _isBengali;
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _isBengali = appData.read('isBengali') ?? false;
    _pageController = PageController(initialPage: 0);

    // Auto-slide every 4.5 seconds
    _autoSlideTimer = Timer.periodic(const Duration(milliseconds: 4500), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % 3;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _toggleLanguage() async {
    bool newIsBengali = !_isBengali;
    await appData.write('isBengali', newIsBengali);
    if (!mounted) return;
    setState(() {
      _isBengali = newIsBengali;
    });
    Get.updateLocale(
      newIsBengali ? const Locale('bn', 'BD') : const Locale('en', 'US'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newIsBengali ? 'lang_switched_bn'.tr : 'lang_switched_en'.tr,
        ),
        backgroundColor: primaryOrange,
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, animChild) {
              return ClipPath(
                clipper: _WaveClipper(animation.value),
                child: animChild,
              );
            },
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 1200),
        reverseTransitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final List<Map<String, String>> slides = [
      {
        'image': 'assets/images/onboarding_store.png',
        'badge': 'business_overview'.tr,
        'title': 'onboarding_title_1'.tr.toUpperCase(),
        'subtitle': 'onboarding_subtitle_1'.tr,
      },
      {
        'image': 'assets/images/onborading2.jpeg',
        'badge': 'order_operations'.tr,
        'title': 'onboarding_title_2'.tr.toUpperCase(),
        'subtitle': 'onboarding_subtitle_2'.tr,
      },
      {
        'image': 'assets/images/onboarding_global.png',
        'badge': 'global_network'.tr,
        'title': 'onboarding_title_3'.tr.toUpperCase(),
        'subtitle': 'onboarding_subtitle_3'.tr,
      },
    ];

    // Soft peach/cream background matching reference UI
    final bgColor = isDark ? const Color(0xFF121214) : const Color(0xFFFFF8F5);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // 1. Top Background Orange Decorative Accent Shapes & Circles
          Positioned(
            top: -40.h,
            right: -40.w,
            child: Container(
              width: 160.w,
              height: 160.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryOrange.withValues(alpha: isDark ? 0.12 : 0.15),
              ),
            ),
          ),
          Positioned(
            top: 60.h,
            left: -30.w,
            child: Container(
              width: 120.w,
              height: 180.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60.r),
                color: primaryOrange.withValues(alpha: isDark ? 0.08 : 0.15),
              ),
            ),
          ),
          Positioned(
            top: 220.h,
            left: 20.w,
            child: Container(
              width: 16.w,
              height: 16.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryOrange.withValues(alpha: isDark ? 0.2 : 0.10),
              ),
            ),
          ),
          Positioned(
            top: 180.h,
            right: 24.w,
            child: Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryOrange.withValues(alpha: isDark ? 0.3 : 0.9),
              ),
            ),
          ),

          // 2. Main Onboarding Body Content Layer
          SafeArea(
            child: Column(
              children: [
                // Perfectly Centered Logo & Top Controls Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Image.asset(
                          isDark ? whiteLogo : logo,
                          width: 120.w,
                          height: 50.h,
                          fit: BoxFit.contain,
                        ),
                      ),

                      Positioned(
                        right: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Theme Switcher Button
                            GestureDetector(
                              onTap: () {
                                final newMode = !isDark;
                                context.read<ThemeProvider>().toggleDarkMode(newMode);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      newMode
                                          ? 'dark_mode_enabled'.tr
                                          : 'light_mode_enabled'.tr,
                                    ),
                                    backgroundColor: primaryOrange,
                                    duration: const Duration(milliseconds: 600),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(7.w),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF221A15)
                                      : Colors.white.withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColorsTheme.borderColor(context),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6.r,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_outlined,
                                  color: isDark ? const Color(0xFFFFB74D) : primaryOrange,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                            UIHelper.horizontalSpace(6.w),

                            // Language Switcher Pill Button
                            GestureDetector(
                              onTap: _toggleLanguage,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF221A15)
                                      : Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: AppColorsTheme.borderColor(context),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6.r,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.g_translate,
                                      color: primaryOrange,
                                      size: 14.sp,
                                    ),
                                    UIHelper.horizontalSpace(4.w),
                                    Text(
                                      _isBengali ? 'বাংলা' : 'EN',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColorsTheme.textMainColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Centered 3-Slide Carousel Content Area
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: slides.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final slide = slides[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // High Definition Business Illustration Stage Card
                            Container(
                              width: double.infinity,
                              height: 245.h,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E1E24)
                                    : const Color(0xFFF4F6F9),
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(
                                  color: AppColorsTheme.borderColor(context),
                                  width: 1.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryOrange.withValues(alpha: isDark ? 0.12 : 0.08),
                                    blurRadius: 20.r,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      width: 170.w,
                                      height: 170.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark
                                            ? primaryOrange.withValues(alpha: 0.1)
                                            : const Color(0xFFFEEBE7),
                                      ),
                                    ),
                                  ),

                                  // High Resolution Business Feature Image
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                      child: Image.asset(
                                        slide['image'] ?? '',
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.business_center_rounded,
                                            size: 70.sp,
                                            color: primaryOrange,
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                                  // Top Left Business Domain Tag Badge
                                  Positioned(
                                    top: 14.h,
                                    left: 14.w,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF282830) : Colors.white,
                                        borderRadius: BorderRadius.circular(16.r),
                                        border: Border.all(
                                          color: primaryOrange.withValues(alpha: 0.3),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.05),
                                            blurRadius: 8.r,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.storefront_rounded,
                                            size: 13.sp,
                                            color: primaryOrange,
                                          ),
                                          UIHelper.horizontalSpace(5.w),
                                          Text(
                                            slide['badge'] ?? '',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.bold,
                                              color: primaryOrange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            UIHelper.verticalSpace(28.h),

                            // Centered Bold Uppercase Headline
                            Text(
                              slide['title'] ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 21.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColorsTheme.textMainColor(context),
                                letterSpacing: 0.8,
                              ),
                            ),

                            UIHelper.verticalSpace(12.h),

                            // Centered Subtitle Description Paragraph
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Text(
                                slide['subtitle'] ?? '',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColorsTheme.textMutedColor(context),
                                  height: 1.45,
                                ),
                              ),
                            ),

                            UIHelper.verticalSpace(20.h),

                            // Centered 3-Dot Page Indicator
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(3, (dotIndex) {
                                final isSelected = _currentPage == dotIndex;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                                  height: isSelected ? 10.h : 8.h,
                                  width: isSelected ? 10.w : 8.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? primaryOrange
                                        : (isDark
                                        ? const Color(0xFF3F3F46)
                                        : const Color(0xFFFED7AA)),
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryOrange
                                          : (isDark
                                          ? const Color(0xFF52525B)
                                          : const Color(0xFFFDBA74)),
                                      width: 1.w,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 4. Custom Peach Bottom Container Footer (Color #FCC6BB)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF261D1B) : primaryOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32.r),
                      topRight: Radius.circular(32.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                        blurRadius: 20.r,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Primary Orange Rounded Pill Button ("GET STARTED")
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: _navigateToLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryOrange,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: primaryOrange.withValues(alpha: 0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26.r),
                            ),
                          ),
                          child: Text(
                            'get_started'.tr.toUpperCase(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),

                      UIHelper.verticalSpace(14.h),

                      // Secondary Centered Skip Link ("SKIP")
                      GestureDetector(
                        onTap: _navigateToLogin,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
                          child: Text(
                            'skip'.tr.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : const Color(0xFF6E281C),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double progress;

  _WaveClipper(this.progress);

  @override
  Path getClip(Size size) {
    Path path = Path();
    double radius = progress * size.height * 1.5;
    path.addOval(Rect.fromCircle(
      center: Offset(size.width * 0.5, size.height * 0.85),
      radius: radius,
    ));
    return path;
  }

  @override
  bool shouldReclip(covariant _WaveClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}