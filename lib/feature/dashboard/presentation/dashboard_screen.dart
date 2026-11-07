import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/custom_button.dart';
import '../../../constants/color.dart';
import '../../../constants/image_const.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/dashboard_provider.dart';
import '../../account/presentation/account_screen.dart';
import '../../business/presentation/business_screen.dart';
import '../../business/presentation/widgets/supplier_drawer_widget.dart';
import '../../finance/presentation/finance_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'widgets/dashboard_hub_widget.dart';
import 'widgets/dynamic_step_indicator.dart';
import 'widgets/status_card_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _closeDrawer(BuildContext context) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  Widget _buildDashboardTab(BuildContext context, DashboardProvider dashboardProvider, bool isDark) {
    if (dashboardProvider.isKycSubmitted) {
      return const DashboardHubWidget();
    }
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        children: [
          UIHelper.verticalSpace(12.h),

          // Title
          Text(
            'setting_up_account'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(20.h),

          // Dynamic Step Indicator
          DynamicStepIndicator(currentStep: dashboardProvider.currentStep),
          UIHelper.verticalSpace(24.h),

          // KYC Status Card
          StatusCardWidget(),
          UIHelper.verticalSpace(28.h),

          // Submit KYC Action Button
          CustomButton(
            onTap: () {
              dashboardProvider.submitKYC();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('kyc_submitted_success'.tr),
                  backgroundColor: primaryOrange,
                ),
              );
            },
            btnName: 'submit_kyc'.tr,
          ),
          UIHelper.verticalSpace(20.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardProvider = context.watch<DashboardProvider>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColorsTheme.background(context),
      drawer: SupplierDrawerWidget(
        activeDrawerItem: 'dashboard',
        onItemSelect: (item) {},
        onCloseDrawer: () => _closeDrawer(context),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Header Stack (Fixed Centered Logo & Drawer Menu Icon)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColorsTheme.cardBg(context),
                border: Border(
                  bottom: BorderSide(
                    color: AppColorsTheme.borderColor(context),
                    width: 1.w,
                  ),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 100% Dead-Centered Logo
                  Center(
                    child: Image.asset(
                      isDark ? whiteLogo : logo,
                      width: 110.w,
                      height: 36.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Left Drawer Menu Icon
                  Positioned(
                    left: 0,
                    child: IconButton(
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                      icon: Icon(
                        Icons.menu_rounded,
                        color: AppColorsTheme.textMainColor(context),
                        size: 24.sp,
                      ),
                    ),
                  ),
                  // Right Action Icons: Notifications & Profile
                  Positioned(
                    right: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.notificationScreen);
                          },
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.notifications_none_rounded,
                                color: AppColorsTheme.textMainColor(context),
                                size: 22.sp,
                              ),
                              Positioned(
                                top: -2.h,
                                right: -2.w,
                                child: Container(
                                  width: 8.w,
                                  height: 8.h,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            dashboardProvider.setBottomNavIndex(4);
                          },
                          icon: Icon(
                            Icons.person_outline_rounded,
                            color: AppColorsTheme.textMainColor(context),
                            size: 22.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Indexed Stack Screen Tabs
            Expanded(
              child: IndexedStack(
                index: dashboardProvider.currentIndex,
                children: [
                  // Index 0: Dashboard Tab
                  _buildDashboardTab(context, dashboardProvider, isDark),

                  // Index 1: Finance Tab
                  const FinanceScreenBody(),

                  // Index 2: Quick Action Placeholder
                  const SizedBox.shrink(),

                  // Index 3: Business Tab
                  const BusinessScreenBody(),

                  // Index 4: Account Tab
                  const AccountScreenBody(),
                ],
              ),
            ),
          ],
        ),
      ),

      // Custom Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: dashboardProvider.currentIndex == 2 ? 0 : dashboardProvider.currentIndex,
        onTap: (index) {
          if (index == 2) {
            // Center (+) Button action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('quick_action_clicked'.tr),
                backgroundColor: primaryOrange,
              ),
            );
            return;
          }
          dashboardProvider.setBottomNavIndex(index);
        },
      ),
    );
  }
}
