import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constants/color.dart';
import '../../../constants/image_const.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/supplier_dashboard_provider.dart';
import '../../dashboard/presentation/widgets/custom_bottom_nav_bar.dart';
import 'widgets/application_status_card_widget.dart';
import 'widgets/supplier_drawer_widget.dart';

class SupplierDashboardScreen extends StatelessWidget {
  static final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  const SupplierDashboardScreen({super.key});

  void _handleOpenApplication(BuildContext context) {
    Navigator.pushNamed(context, Routes.kycVerificationScreen);
  }

  void _closeDrawer(BuildContext context) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<SupplierDashboardProvider>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColorsTheme.background(context),
      drawer: SupplierDrawerWidget(
        activeDrawerItem: provider.activeDrawerItem,
        onItemSelect: (item) {
          provider.setActiveDrawerItem(item);
        },
        onCloseDrawer: () => _closeDrawer(context),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColorsTheme.cardBg(context),
                border: Border(
                  bottom: BorderSide(
                    color: AppColorsTheme.borderColor(context),
                    width: 1.w,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Menu Icon
                  IconButton(
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    icon: Icon(
                      Icons.menu,
                      color: AppColorsTheme.textMainColor(context),
                      size: 24.sp,
                    ),
                  ),

                  // Center Banij Logo
                  Image.asset(
                    isDark ? whiteLogo : logo,
                    width: 100.w,
                    height: 36.h,
                    fit: BoxFit.contain,
                  ),

                  // Right Icons: Notifications & Profile
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifications'),
                              backgroundColor: primaryOrange,
                              duration: Duration(milliseconds: 700),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.notifications_none,
                          color: AppColorsTheme.textMainColor(context),
                          size: 22.sp,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.accountScreen, arguments: 'supplier');
                        },
                        icon: Icon(
                          Icons.person_outline,
                          color: AppColorsTheme.textMainColor(context),
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Screen Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'supplier_dashboard'.tr,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(20.h),

                    // Modular Application Status Card
                    ApplicationStatusCardWidget(
                      onOpenApplication: () => _handleOpenApplication(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Matching Custom Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quick Action (+) clicked'),
                backgroundColor: primaryOrange,
                duration: Duration(milliseconds: 800),
              ),
            );
            return;
          }
          if (index == 0) {
            // Supplier Dashboard
          } else if (index == 1) {
            Navigator.pushNamed(context, Routes.accountScreen, arguments: 'supplier');
          } else if (index == 3) {
            Navigator.pushNamed(context, Routes.verificationHistoryScreen);
          } else if (index == 4) {
            Navigator.pushNamed(context, Routes.accountScreen, arguments: 'supplier');
          }
        },
      ),
    );
  }
}
