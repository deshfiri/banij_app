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

  @override
  void initState() {
    super.initState();
    _isBengali = appData.read('isBengali') ?? false;
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
                    const Color(0xFF1E140C),
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
                        // App Theme Switcher (Dark / Light)
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
                                color: isDark ? primaryOrange : Colors.white,
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
                              border: Border.all(color: Colors.white, width: 1.w),
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
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UIHelper.verticalSpace(12.h),

                      // Supplier Network Tag
                      Text(
                        'supplier_network'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 1.2,
                        ),
                      ),
                      UIHelper.verticalSpace(10.h),

                      // Hero Title
                      Text(
                        'onboarding_title'.tr,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      UIHelper.verticalSpace(12.h),

                      // Subtitle
                      Text(
                        'onboarding_subtitle'.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                      UIHelper.verticalSpace(28.h),

                      // Graphic Card Stack
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Main Graphic Card
                          Container(
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(
                              color: AppColorsTheme.cardBg(context),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: AppColorsTheme.borderColor(context)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20.r,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                UIHelper.verticalSpace(14.h), // space for overlapping pill badge

                                // Header row of card
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'business_overview'.tr,
                                      style: TextStyle(
                                        fontSize: 16.sp,
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
                                UIHelper.verticalSpace(18.h),

                                // 4-Step Icons Connected Row
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
                                UIHelper.verticalSpace(20.h),

                                // 3 Metric Cards Side-by-Side
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMetricCard(
                                        context,
                                        'tag_products'.tr,
                                        '248',
                                        'active_products'.tr,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: _buildMetricCard(
                                        context,
                                        'hub_orders'.tr.toUpperCase(),
                                        '1.2K',
                                        '+18.4%',
                                        valueColor: const Color(0xFF10B981),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: _buildMetricCard(
                                        context,
                                        'IN STOCK',
                                        '92%',
                                        'availability'.tr,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Top-Left Floating Pill Badge: Supplier Account ready
                          Positioned(
                            top: -16.h,
                            left: 12.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: AppColorsTheme.cardBg(context),
                                borderRadius: BorderRadius.circular(30.r),
                                border: Border.all(color: AppColorsTheme.borderColor(context)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 10.r,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 24.w,
                                    height: 24.h,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFD1FAE5),
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: const Color(0xFF10B981),
                                      size: 14.sp,
                                    ),
                                  ),
                                  UIHelper.horizontalSpace(8.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Supplier',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: AppColorsTheme.textMutedColor(context),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'account_ready'.tr,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColorsTheme.textMainColor(context),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Bottom-Right Floating Cube Icon Badge
                          Positioned(
                            bottom: -16.h,
                            right: 12.w,
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF8C38), Color(0xFFFD6B04)],
                                ),
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryOrange.withValues(alpha: 0.4),
                                    blurRadius: 12.r,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.view_in_ar,
                                color: Colors.white,
                                size: 22.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      UIHelper.verticalSpace(36.h),

                      // Shield Trust Badge
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 18.sp,
                          ),
                          UIHelper.horizontalSpace(8.w),
                          Expanded(
                            child: Text(
                              'built_for_reliable'.tr,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      UIHelper.verticalSpace(32.h),

                      // Footer Link: Already have a Supplier account? Sign in
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'already_supplier'.tr,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: _navigateToLogin,
                            child: Text(
                              'sign_in'.tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildWorkflowIcon(IconData icon, String label, {required BuildContext context, bool isGreen = false}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: isGreen ? const Color(0xFFECFDF5) : const Color(0xFFFFF7F2),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isGreen ? const Color(0xFFA7F3D0) : const Color(0xFFFFD8BF),
            ),
          ),
          child: Icon(
            icon,
            color: isGreen ? const Color(0xFF10B981) : primaryOrange,
            size: 18.sp,
          ),
        ),
        UIHelper.verticalSpace(4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 16.w,
      height: 1.5.h,
      color: Colors.grey.withValues(alpha: 0.3),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, String subText, {Color? valueColor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.background(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
              color: AppColorsTheme.textMutedColor(context),
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          UIHelper.verticalSpace(4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(2.h),
          Text(
            subText,
            style: TextStyle(
              fontSize: 10.sp,
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
