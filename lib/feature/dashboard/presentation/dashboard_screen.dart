import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/custom_button.dart';
import '../../../constants/color.dart';
import '../../../constants/image_const.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/dashboard_provider.dart';
import '../../account/presentation/account_screen.dart';
import '../../business/presentation/business_screen.dart';
import '../../finance/presentation/finance_screen.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'widgets/dashboard_hub_widget.dart';
import 'widgets/dynamic_step_indicator.dart';
import 'widgets/status_card_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget _buildDashboardTab(BuildContext context, DashboardProvider dashboardProvider, bool isDark) {
    if (dashboardProvider.isKycSubmitted) {
      return const DashboardHubWidget();
    }
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        children: [
          // 1. Banij Header Logo
          Center(
            child: Image.asset(
              isDark ? whiteLogo : logo,
              width: 130.w,
              height: 55.h,
              fit: BoxFit.contain,
            ),
          ),
          UIHelper.verticalSpace(12.h),

          // 2. Title
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

          // 3. Dynamic Step Indicator
          DynamicStepIndicator(currentStep: dashboardProvider.currentStep),
          UIHelper.verticalSpace(24.h),

          // 4. KYC Status Card
          StatusCardWidget(),
          UIHelper.verticalSpace(28.h),

          // 5. Submit KYC Action Button
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
      backgroundColor: AppColorsTheme.background(context),
      body: SafeArea(
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
