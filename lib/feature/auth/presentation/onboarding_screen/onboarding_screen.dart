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

    // Auto-slide timer every 3.5 seconds
    _autoSlideTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
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
                    const Color(0xFF23160B),
                    darkBackground,
                    const Color(0xFF0F0B08),
                  ]
                : [
                    const Color(0xFFFF7A1A),
                    const Color(0xFFFD6B04),
                    const Color(0xFFE05600),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar: Logo & Theme Switcher & Language Toggle
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
                      UIHelper.verticalSpace(8.h),

                      // Supplier Network Glass Tag
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
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
                          fontSize: 28.sp,
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
                      UIHelper.verticalSpace(28.h),

                      // Auto-Sliding Carousel View Area (Spacious & Responsive Height)
                      SizedBox(
                        height: 255.h,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          children: [
                            _buildSlideOne(context),
                            _buildSlideTwo(context),
                            _buildSlideThree(context),
                          ],
                        ),
                      ),
                      UIHelper.verticalSpace(18.h),

                      // Carousel Page Dot Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isSelected = _currentPage == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            height: 8.h,
                            width: isSelected ? 28.w : 8.w,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          );
                        }),
                      ),
                      UIHelper.verticalSpace(28.h),

                      // Glassmorphism Shield Trust Badge (Bellow section)
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
                      UIHelper.verticalSpace(24.h),

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

  // Slide 1: Business Overview & Metrics
  Widget _buildSlideOne(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: AppColorsTheme.cardBg(context),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: AppColorsTheme.borderColor(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 22.r,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UIHelper.verticalSpace(10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'business_overview'.tr,
                    style: TextStyle(
                      fontSize: 16.5.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECE0),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.home_outlined,
                      color: primaryOrange,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpace(12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWorkflowIcon(Icons.inventory_2_outlined, 'hub_products'.tr, context: context),
                  _buildStepLine(),
                  _buildWorkflowIcon(Icons.assignment_outlined, 'Inventory', isGreen: true, context: context),
                  _buildStepLine(),
                  _buildWorkflowIcon(Icons.shopping_bag_outlined, 'hub_orders'.tr, context: context),
                  _buildStepLine(),
                  _buildWorkflowIcon(Icons.trending_up, 'Growth', isGreen: true, context: context),
                ],
              ),
              UIHelper.verticalSpace(12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(context, 'tag_products'.tr, '248', 'active_products'.tr),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: _buildMetricCard(context, 'hub_orders'.tr.toUpperCase(), '1.2K', '+18.4%', valueColor: const Color(0xFF10B981)),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: _buildMetricCard(context, 'IN STOCK', '92%', 'availability'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildPillBadge(context, 'Supplier', 'account_ready'.tr),
        _buildCubeBadge(),
      ],
    );
  }

  // Slide 2: Real-time Order Operations
  Widget _buildSlideTwo(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: AppColorsTheme.cardBg(context),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: AppColorsTheme.borderColor(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 22.r,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UIHelper.verticalSpace(10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'order_operations'.tr,
                    style: TextStyle(
                      fontSize: 16.5.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECE0),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.local_shipping_outlined,
                      color: primaryOrange,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpace(12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWorkflowIcon(Icons.add_shopping_cart, 'New', context: context),
                  _buildStepLine(),
                  _buildWorkflowIcon(Icons.sync, 'Processing', isGreen: true, context: context),
                  _buildStepLine(),
                  _buildWorkflowIcon(Icons.local_shipping, 'Shipped', context: context),
                  _buildStepLine(),
                  _buildWorkflowIcon(Icons.check_circle, 'Done', isGreen: true, context: context),
                ],
              ),
              UIHelper.verticalSpace(12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(context, 'revenue'.tr.toUpperCase(), '৳450K', '+24.8%', valueColor: primaryOrange),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: _buildMetricCard(context, 'DISPATCH', '98.2%', 'dispatch_rate'.tr, valueColor: const Color(0xFF10B981)),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: _buildMetricCard(context, 'RATING', '4.9★', 'rating'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildPillBadge(context, 'Sales', 'sales_live'.tr),
        _buildCubeBadge(icon: Icons.flash_on_rounded),
      ],
    );
  }

  // Slide 3: Global Supplier Network
  Widget _buildSlideThree(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: AppColorsTheme.cardBg(context),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: AppColorsTheme.borderColor(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 22.r,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UIHelper.verticalSpace(10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'global_network'.tr,
                    style: TextStyle(
                      fontSize: 16.5.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECE0),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.public_outlined,
                      color: primaryOrange,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpace(12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWorkflowIcon(Icons.hub_outlined, 'Connect', context: context),
                  _buildStepLine(),
                  _buildWorkflowIcon(Icons.verified, 'Verify', isGreen: true, context: context),
                  _buildStepLine(),
                  _buildWorkflowIcon(Icons.open_in_new, 'Expand', context: context),
                  _buildStepLine(),
                  _buildWorkflowIcon(Icons.rocket_launch, 'Scale', isGreen: true, context: context),
                ],
              ),
              UIHelper.verticalSpace(12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(context, 'REGIONS', '14+', 'regions'.tr),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: _buildMetricCard(context, 'PARTNERS', '3.5K', 'partners'.tr, valueColor: primaryOrange),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: _buildMetricCard(context, 'GROWTH', '+32%', 'growth'.tr, valueColor: const Color(0xFF10B981)),
                  ),
                ],
              ),
            ],
          ),
        ),
        _buildPillBadge(context, 'Network', 'network_active'.tr),
        _buildCubeBadge(icon: Icons.language),
      ],
    );
  }

  Widget _buildPillBadge(BuildContext context, String title, String subtitle) {
    return Positioned(
      top: -14.h,
      left: 12.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColorsTheme.cardBg(context),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: AppColorsTheme.borderColor(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22.w,
              height: 22.h,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD1FAE5),
              ),
              child: Icon(
                Icons.check,
                color: const Color(0xFF10B981),
                size: 13.sp,
              ),
            ),
            UIHelper.horizontalSpace(6.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: AppColorsTheme.textMutedColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColorsTheme.textMainColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCubeBadge({IconData icon = Icons.view_in_ar}) {
    return Positioned(
      bottom: -14.h,
      right: 12.w,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8C38), Color(0xFFFD6B04)],
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: primaryOrange.withValues(alpha: 0.4),
              blurRadius: 12.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildWorkflowIcon(IconData icon, String label, {required BuildContext context, bool isGreen = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isGreen ? const Color(0xFFECFDF5) : const Color(0xFFFFF7F2),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isGreen ? const Color(0xFFA7F3D0) : const Color(0xFFFFD8BF),
            ),
          ),
          child: Icon(
            icon,
            color: isGreen ? const Color(0xFF10B981) : primaryOrange,
            size: 16.sp,
          ),
        ),
        UIHelper.verticalSpace(3.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: AppColorsTheme.textMainColor(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 12.w,
      height: 1.5.h,
      color: Colors.grey.withValues(alpha: 0.3),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, String subText, {Color? valueColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.background(context),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.bold,
              color: AppColorsTheme.textMutedColor(context),
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          UIHelper.verticalSpace(2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColorsTheme.textMainColor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          UIHelper.verticalSpace(2.h),
          Text(
            subText,
            style: TextStyle(
              fontSize: 9.sp,
              color: valueColor ?? AppColorsTheme.textMutedColor(context),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
