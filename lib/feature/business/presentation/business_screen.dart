import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/supplier_dashboard_provider.dart';
import '../../dashboard/presentation/widgets/quick_access_section_widget.dart';
import 'widgets/business_tab/business_hero_header.dart';
import 'widgets/business_tab/business_tab_items.dart';

/// Business tab: hero header and a grid of business tools
/// (verification, subscription, partner network, addresses).
class BusinessScreenBody extends StatelessWidget {
  final VoidCallback? onOpenDrawer;

  const BusinessScreenBody({
    super.key,
    this.onOpenDrawer,
  });

  void _handleProfileTap(BuildContext context) {
    try {
      final dashProvider = Provider.of<DashboardProvider>(context, listen: false);
      dashProvider.setBottomNavIndex(4);
      return;
    } catch (_) {}
    try {
      final supplierProvider = Provider.of<SupplierDashboardProvider>(context, listen: false);
      supplierProvider.setBottomNavIndex(4);
      return;
    } catch (_) {}
    Navigator.pushNamed(context, Routes.accountScreen);
  }

  @override
  Widget build(BuildContext context) {
    final items = BusinessTabItem.all;

    return Container(
      color: AppColorsTheme.background(context),
      child: Column(
        children: [
          BusinessHeroHeader(
            onOpenDrawer: onOpenDrawer,
            onNotificationsTap: () => Navigator.pushNamed(context, Routes.notificationScreen),
            onProfileTap: () => _handleProfileTap(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardSectionHeader(title: 'Business tools'.tr),
                  UIHelper.verticalSpace(12.h),
                  QuickAccessGrid(
                    tiles: [
                      for (final item in items)
                        QuickAccessTile(
                          title: item.titleKey.tr,
                          iconAsset: item.iconAsset,
                          onTap: () => item.onTap(context),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
