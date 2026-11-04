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

  Widget _buildBodyContent(BuildContext context, DashboardProvider dashboardProvider, bool isDark) {
    switch (dashboardProvider.currentIndex) {
      case 0:
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
                    const SnackBar(
                      content: Text('KYC documents submitted successfully!'),
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
      case 1:
        return const FinanceScreenBody();
      case 3:
        return const BusinessScreenBody();
      case 4:
        return const AccountScreenBody();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardProvider = context.watch<DashboardProvider>();

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildBodyContent(context, dashboardProvider, isDark),
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
              const SnackBar(
                content: Text('Quick Action (+) clicked'),
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
