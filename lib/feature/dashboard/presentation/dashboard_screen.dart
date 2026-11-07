import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/custom_button.dart';
import '../../../constants/color.dart';
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
import 'widgets/package_selection_widget.dart';
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

  Widget _buildDashboardTab(BuildContext context, DashboardProvider dashboardProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (dashboardProvider.isKycSubmitted) {
      return DashboardHubWidget(
        onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        children: [
          UIHelper.verticalSpace(12.h),

          // Title Header
          Text(
            dashboardProvider.currentStep == 4
                ? 'Select Subscription Package'
                : (dashboardProvider.currentStep == 5
                    ? 'Account Under Review'
                    : 'setting_up_account'.tr),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(20.h),

          // Dynamic Step Indicator (Steps 1 to 5)
          DynamicStepIndicator(currentStep: dashboardProvider.currentStep),
          UIHelper.verticalSpace(24.h),

          // Step 3: KYC Documents Pending
          if (dashboardProvider.currentStep == 3) ...[
            StatusCardWidget(),
            UIHelper.verticalSpace(28.h),
            CustomButton(
              onTap: () {
                dashboardProvider.submitKYC();
                Navigator.pushNamed(context, Routes.kycVerificationScreen);
              },
              btnName: 'Submit your KYC documents',
            ),
          ],

          // Step 4: Package Selection
          if (dashboardProvider.currentStep == 4) ...[
            PackageSelectionWidget(
              onContinue: () {
                dashboardProvider.completePackageSelection();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Package selected successfully!'),
                    backgroundColor: primaryOrange,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],

          // Step 5: Approval Pending & Unlock Workspace
          if (dashboardProvider.currentStep >= 5) ...[
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColorsTheme.cardBg(context),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.5),
                  width: 1.5.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.0 : 0.06),
                    blurRadius: 16.r,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Approval Status',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'FINAL STEP',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(14.h),
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 24.sp,
                          color: const Color(0xFF10B981),
                        ),
                        UIHelper.horizontalSpace(12.w),
                        Expanded(
                          child: Text(
                            'Package Confirmed! Your account is undergoing final workspace verification.',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            UIHelper.verticalSpace(28.h),
            CustomButton(
              onTap: () {
                dashboardProvider.unlockDashboard();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Welcome to your Product Dashboard!'),
                    backgroundColor: primaryOrange,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              btnName: 'Unlock Workspace Dashboard',
            ),
          ],
          UIHelper.verticalSpace(20.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: IndexedStack(
          index: dashboardProvider.currentIndex,
          children: [
            // Index 0: Dashboard Tab
            _buildDashboardTab(context, dashboardProvider),

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
