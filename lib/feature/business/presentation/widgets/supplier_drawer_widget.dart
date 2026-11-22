import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import 'drawer/drawer_menu_config.dart';
import 'drawer/drawer_menu_tile.dart';
import 'drawer/drawer_profile_header.dart';
import 'drawer/logout_confirmation_dialog.dart';

/// Supplier navigation drawer, styled like the dashboard (hero header,
/// orange accents, theme-aware surfaces). Works both as `Scaffold.drawer`
/// and as the menu of `AnimatedSideMenu`.
class SupplierDrawerWidget extends StatelessWidget {
  final String activeDrawerItem;
  final ValueChanged<String> onItemSelect;
  final VoidCallback onCloseDrawer;

  const SupplierDrawerWidget({
    super.key,
    required this.activeDrawerItem,
    required this.onItemSelect,
    required this.onCloseDrawer,
  });

  void _onItemTap(BuildContext context, DrawerMenuItem item) {
    onItemSelect(item.id);
    onCloseDrawer();
    if (item.routeName != null) {
      Navigator.pushNamed(context, item.routeName!, arguments: item.arguments);
    }
  }

  void _onLogoutTap(BuildContext context) {
    onCloseDrawer();
    LogoutConfirmationDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColorsTheme.background(context),
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DrawerProfileHeader(),
              UIHelper.verticalSpace(20.h),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final section in DrawerMenuConfig.sections) ...[
                      DrawerSectionLabel(title: section.titleKey.tr),
                      for (final item in section.items)
                        DrawerMenuTile(
                          icon: item.icon,
                          title: item.titleKey.tr,
                          isSelected: item.id == activeDrawerItem,
                          onTap: () => _onItemTap(context, item),
                        ),
                      UIHelper.verticalSpace(14.h),
                    ],
                  ],
                ),
              ),
              Divider(color: AppColorsTheme.borderColor(context), height: 20.h),
              DrawerMenuTile(
                icon: Icons.logout_rounded,
                title: 'logout'.tr,
                style: DrawerTileStyle.danger,
                onTap: () => _onLogoutTap(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
