import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/animated_side_menu.dart';
import '../../../common_widget/custom_button.dart';
import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/dashboard_provider.dart';
import '../../account/presentation/account_screen.dart';
import '../../business/presentation/business_screen.dart';
import '../../business/presentation/widgets/supplier_drawer_widget.dart';
import '../../finance/presentation/finance_screen.dart';
import 'widgets/approval_status_card_widget.dart';
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
  final GlobalKey<AnimatedSideMenuState> _sideMenuKey = GlobalKey<AnimatedSideMenuState>();

  void _openDrawer() => _sideMenuKey.currentState?.open();

  void _closeDrawer() => _sideMenuKey.currentState?.close();

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryOrange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _onboardingTitle(int step, bool isApproved) {
    if (step == 4) return 'Select Subscription Package'.tr;
    if (step >= 5) return isApproved ? 'Account Approved & Active'.tr : 'Account Under Review'.tr;
    return 'setting_up_account'.tr;
  }

  Widget _buildDashboardTab(BuildContext context, DashboardProvider dashboardProvider) {
    final onboardingData = dashboardProvider.onboardingModel?.data;
    final onboardingStatus = onboardingData?.status?.value?.toLowerCase();
    final isApproved =
        onboardingData?.isApproved == true || onboardingStatus == 'active' || onboardingStatus == 'approved';

    final standingStatus = dashboardProvider.dashboardModel?.data?.standing?.status?.toLowerCase();
    final isStandingActive = standingStatus == 'active' || standingStatus == 'approved';

    if (isApproved || isStandingActive || dashboardProvider.isAccountSetupCompleted || dashboardProvider.isKycSubmitted) {
      return DashboardHubWidget(onOpenDrawer: _openDrawer);
    }

    final step = dashboardProvider.currentStep;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        children: [
          UIHelper.verticalSpace(12.h),
          Text(
            _onboardingTitle(step, isApproved),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(20.h),
          DynamicStepIndicator(currentStep: step, isApproved: isApproved),
          UIHelper.verticalSpace(24.h),

          // Step 3: KYC documents pending
          if (step == 3) ...[
            StatusCardWidget(),
            UIHelper.verticalSpace(28.h),
            CustomButton(
              onTap: () {
                dashboardProvider.submitKYC();
                Navigator.pushNamed(context, Routes.kycVerificationScreen);
              },
              btnName: 'submit_kyc'.tr,
            ),
          ],

          // Step 4: package selection
          if (step == 4)
            PackageSelectionWidget(
              onContinue: () {
                dashboardProvider.completePackageSelection();
                _showSnackBar(context, 'Package selected successfully!'.tr);
              },
            ),

          // Step 5: approval pending & unlock workspace
          if (step >= 5) ...[
            ApprovalStatusCardWidget(
              badgeLabel: onboardingData?.status?.label ?? onboardingData?.approvalStatus ?? 'active'.tr,
              message: onboardingData?.message ?? 'Package confirmed! Your account is undergoing final workspace verification.'.tr,
            ),
            UIHelper.verticalSpace(28.h),
            CustomButton(
              onTap: () {
                dashboardProvider.unlockDashboard();
                _showSnackBar(context, 'Welcome to your Product Dashboard!'.tr);
              },
              btnName: 'Unlock Workspace Dashboard'.tr,
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

    return AnimatedSideMenu(
      key: _sideMenuKey,
      menu: SupplierDrawerWidget(
        activeDrawerItem: 'Dashboard',
        onItemSelect: (item) {
          if (item == 'Dashboard') dashboardProvider.setBottomNavIndex(0);
        },
        onCloseDrawer: _closeDrawer,
      ),
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: SafeArea(
          top: false,
          child: IndexedStack(
            index: dashboardProvider.currentIndex,
            children: [
              // Index 0: Dashboard Tab
              _buildDashboardTab(context, dashboardProvider),

              // Index 1: Finance Tab
              FinanceScreenBody(onOpenDrawer: _openDrawer),

              // Index 2: Quick Action Placeholder
              const SizedBox.shrink(),

              // Index 3: Business Tab
              BusinessScreenBody(onOpenDrawer: _openDrawer),

              // Index 4: Account Tab
              AccountScreenBody(onOpenDrawer: _openDrawer),
            ],
          ),
        ),

        // Custom Bottom Navigation Bar
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: dashboardProvider.currentIndex == 2 ? 0 : dashboardProvider.currentIndex,
          onTap: (index) {
            if (index == 2) {
              // Center (+) Button action
              _showSnackBar(context, 'quick_action_clicked'.tr);
              return;
            }
            dashboardProvider.setBottomNavIndex(index);
          },
        ),
      ),
    );
  }
}
