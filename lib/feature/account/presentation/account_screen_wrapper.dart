import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../dashboard/presentation/widgets/custom_bottom_nav_bar.dart';
import 'account_screen.dart';

class AccountScreen extends StatelessWidget {
  final String? initialTab;

  const AccountScreen({super.key, this.initialTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SafeArea(
        child: AccountScreenBody(initialTab: initialTab),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 4,
        onTap: (index) {
          if (index == 4) return;
          if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('quick_action_clicked'.tr),
                backgroundColor: primaryOrange,
                duration: const Duration(milliseconds: 800),
              ),
            );
            return;
          }
          if (initialTab == 'supplier') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.supplierDashboardScreen,
              (route) => false,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.dashboardScreen,
              (route) => false,
            );
          }
        },
      ),
    );
  }
}
