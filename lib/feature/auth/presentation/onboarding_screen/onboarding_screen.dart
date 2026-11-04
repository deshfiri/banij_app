import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/di.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/theme_provider.dart';

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

    // Auto-slide timer every 4 seconds
    _autoSlideTimer = Timer.periodic(const Duration(milliseconds: 4000), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % 3;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 650),
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
          newIsBengali
              ? 'Language switched to Bengali (বাংলা)'
              : 'Language switched to English',
        ),
        backgroundColor: primaryOrange,
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, Routes.loginScreen);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? darkBackground : primaryOrange,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1E130B),
                    darkBackground,
                    const Color(0xFF0D0907),
                  ]
                : [
                    const Color(0xFFFF8533),
                    const Color(0xFFFD6B04),
                    const Color(0xFFD15300),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar: Modern Vendor Logo & Theme/Language Controls
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      whiteLogo,
                      width: 120.w,
                      height: 40.h,
                      fit: BoxFit.contain,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Theme Switcher
                        GestureDetector(
                          onTap: () {
                            final newMode = !isDark;
                            context.read<ThemeProvider>().toggleDarkMode(newMode);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(newMode ? 'Dark Mode Enabled' : 'Light Mode Enabled'),
                                backgroundColor: primaryOrange,
                                duration: const Duration(milliseconds: 600),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: EdgeInsets.all(8.w),
                            margin: EdgeInsets.only(right: 8.w),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF221A15) : Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isDark ? primaryOrange : Colors.white.withValues(alpha: 0.6),
                                width: 1.w,
                              ),
                            ),
                            child: Icon(
                              isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_outlined,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ),
                        ),

                        // Language Toggle Button
                        GestureDetector(
                          onTap: _toggleLanguage,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                            decoration: BoxDecoration(
                              color: _isBengali ? Colors.white : Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.w),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.g_translate,
                                  color: _isBengali ? primaryOrange : Colors.white,
                                  size: 16.sp,
                                ),
                                UIHelper.horizontalSpace(6.w),
                                Text(
                                  _isBengali ? 'বাংলা' : 'EN',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: _isBengali ? primaryOrange : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UIHelper.verticalSpace(6.h),

                      // Supplier Network Glass Tag
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.h,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                            UIHelper.horizontalSpace(6.w),
                            Text(
                              'supplier_network'.tr,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpace(12.h),

                      // Hero Title
                      Text(
                        'onboarding_title'.tr,
                        style: TextStyle(
                          fontSize: 27.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.22,
                          letterSpacing: -0.4,
                        ),
                      ),
                      UIHelper.verticalSpace(10.h),

                      // Subtitle
                      Text(
                        'onboarding_subtitle'.tr,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.92),
                          height: 1.45,
                          letterSpacing: 0.1,
                        ),
                      ),
                      UIHelper.verticalSpace(24.h),

                      // Carousel View with Asset Image Cards (Expanded generous height to prevent overflow)
                      SizedBox(
                        height: 270.h,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          children: [
                            _buildAssetImageCard(
                              context,
                              assetPath: 'assets/images/onboarding_store.png',
                              badgeText: 'Retail Store Front',
                              cardTitle: 'business_overview'.tr,
                              cardSubtitle: 'Manage active shop products & inventory in real time.',
                              tagText: 'KYC Verified',
                              cardGradient: const [Color(0xFF2A1608), Color(0xFF140B04)],
                            ),
                            _buildAssetImageCard(
                              context,
                              assetPath: 'assets/images/onboarding_logistics.png',
                              badgeText: 'Express Dispatch',
                              cardTitle: 'order_operations'.tr,
                              cardSubtitle: 'Seamlessly pack, ship, and fulfill buyer orders instantly.',
                              tagText: 'Live Tracking',
                              cardGradient: const [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                            ),
                            _buildAssetImageCard(
                              context,
                              assetPath: 'assets/images/onboarding_global.png',
                              badgeText: 'Wholesale Ecosystem',
                              cardTitle: 'global_network'.tr,
                              cardSubtitle: 'Connect with reliable wholesale suppliers and scale fast.',
                              tagText: 'Global Partner',
                              cardGradient: const [Color(0xFF0B251D), Color(0xFF061A13)],
                            ),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpace(16.h),

                      // Harmonized Image Slider Cursor (Modern Gradient Dots)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isSelected = _currentPage == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 5.w),
                            height: 8.h,
                            width: isSelected ? 32.w : 8.w,
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [Colors.white, Color(0xFFFFD1A9)],
                                    )
                                  : null,
                              color: isSelected ? null : Colors.white.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(4.r),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        blurRadius: 6.r,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),
                      UIHelper.verticalSpace(24.h),

                      // Glassmorphism Shield Trust Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.verified_user,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                            ),
                            UIHelper.horizontalSpace(12.w),
                            Expanded(
                              child: Text(
                                'built_for_reliable'.tr,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpace(20.h),

                      // Footer Link: Already have a Supplier account? Sign in
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'already_supplier'.tr,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: _navigateToLogin,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'sign_in'.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
                                    ),
                                  ),
                                  UIHelper.horizontalSpace(4.w),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                    size: 12.sp,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpace(16.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Carousel Slider Card featuring Shop/Vendor Asset Image with Overlaid Titles & Subtitles (Zero Overflow Stack Positioning)
  Widget _buildAssetImageCard(
    BuildContext context, {
    required String assetPath,
    required String badgeText,
    required String cardTitle,
    required String cardSubtitle,
    required String tagText,
    required List<Color> cardGradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20.r,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: cardGradient,
            ),
          ),
          child: Stack(
            children: [
              // 1. Background Shop/Vendor Asset Image
              Positioned.fill(
                child: Opacity(
                  opacity: 0.50,
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: const Color(0xFF2C2C30));
                    },
                  ),
                ),
              ),

              // 2. Dark Gradient Overlay for Text Contrast
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Top Badges Row (Positioned at top)
              Positioned(
                top: 16.h,
                left: 16.w,
                right: 16.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: primaryOrange,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.h,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          UIHelper.horizontalSpace(4.w),
                          Text(
                            tagText,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Bottom Title & Subtitle (Positioned at bottom)
              Positioned(
                bottom: 16.h,
                left: 16.w,
                right: 16.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cardTitle,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    UIHelper.verticalSpace(4.h),
                    Text(
                      cardSubtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
