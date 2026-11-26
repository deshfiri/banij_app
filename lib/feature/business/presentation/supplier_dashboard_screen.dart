import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/animated_side_menu.dart';
import '../../../constants/color.dart';
import '../../../providers/supplier_dashboard_provider.dart';
import '../../account/presentation/account_screen.dart';
import '../../dashboard/presentation/widgets/custom_bottom_nav_bar.dart';
import '../../finance/presentation/finance_screen.dart';
import 'business_screen.dart';
import 'widgets/supplier_dashboard/supplier_home_tab.dart';
import 'widgets/supplier_drawer_widget.dart';

class SupplierDashboardScreen extends StatefulWidget {
  const SupplierDashboardScreen({super.key});

  @override
  State<SupplierDashboardScreen> createState() => _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState extends State<SupplierDashboardScreen> {
  final GlobalKey<AnimatedSideMenuState> _sideMenuKey = GlobalKey<AnimatedSideMenuState>();

  void _openDrawer() => _sideMenuKey.currentState?.open();

  void _closeDrawer() => _sideMenuKey.currentState?.close();

  void _openAccountTab() => context.read<SupplierDashboardProvider>().setBottomNavIndex(4);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierDashboardProvider>();

    return AnimatedSideMenu(
      key: _sideMenuKey,
      menu: SupplierDrawerWidget(
        activeDrawerItem: provider.activeDrawerItem,
        onItemSelect: (item) {
          provider.setActiveDrawerItem(item);
        },
        onCloseDrawer: _closeDrawer,
      ),
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: SafeArea(
          top: false,
          child: IndexedStack(
            index: provider.currentIndex,
            children: [
              // Index 0: Supplier Dashboard Home View
              SupplierHomeTab(onOpenDrawer: _openDrawer, onOpenAccount: _openAccountTab),

              // Index 1: Finance Tab
              FinanceScreenBody(onOpenDrawer: _openDrawer, onProfileTap: _openAccountTab),

              // Index 2: Quick Action Placeholder
              const SizedBox.shrink(),

              // Index 3: Business Tab
              BusinessScreenBody(onOpenDrawer: _openDrawer, onProfileTap: _openAccountTab),

              // Index 4: Account Tab
              AccountScreenBody(
                initialTab: 'supplier',
                onOpenDrawer: _openDrawer,
              ),
            ],
          ),
        ),

        // Matching Custom Bottom Navigation Bar
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: provider.currentIndex == 2 ? 0 : provider.currentIndex,
          onTap: (index) {
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
            provider.setBottomNavIndex(index);
          },
        ),
      ),
    );
  }
}
