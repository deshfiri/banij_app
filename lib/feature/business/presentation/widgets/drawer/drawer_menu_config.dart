import 'package:flutter/material.dart';

import '../../../../../helpers/all_routes.dart';

/// One navigation entry in the supplier drawer.
///
/// [id] is the value hosts pass as `activeDrawerItem` / receive in `onItemSelect`.
/// When [routeName] is null the item only closes the drawer (e.g. Dashboard).
class DrawerMenuItem {
  final String id;
  final String titleKey;
  final IconData icon;
  final String? routeName;
  final Object? arguments;

  const DrawerMenuItem({
    required this.id,
    required this.titleKey,
    required this.icon,
    this.routeName,
    this.arguments,
  });
}

/// A titled group of drawer items.
class DrawerMenuSection {
  final String titleKey;
  final List<DrawerMenuItem> items;

  const DrawerMenuSection({required this.titleKey, required this.items});
}

/// Single source of truth for the drawer's sections and items.
class DrawerMenuConfig {
  DrawerMenuConfig._();

  static const String dashboardId = 'Dashboard';

  static const List<DrawerMenuSection> sections = [
    DrawerMenuSection(
      titleKey: 'overview',
      items: [
        DrawerMenuItem(
          id: dashboardId,
          titleKey: 'dashboard',
          icon: Icons.grid_view_rounded,
        ),
        DrawerMenuItem(
          id: 'Application & KYC',
          titleKey: 'application_and_kyc',
          icon: Icons.verified_user_outlined,
          routeName: Routes.kycVerificationScreen,
        ),
      ],
    ),
    DrawerMenuSection(
      titleKey: 'account',
      items: [
        DrawerMenuItem(
          id: 'Notifications',
          titleKey: 'notifications',
          icon: Icons.notifications_none_rounded,
          routeName: Routes.notificationScreen,
        ),
        DrawerMenuItem(
          id: 'Profile',
          titleKey: 'profile',
          icon: Icons.person_outline_rounded,
          routeName: Routes.accountScreen,
          arguments: 'supplier',
        ),
        DrawerMenuItem(
          id: 'Security',
          titleKey: 'security',
          icon: Icons.shield_outlined,
          routeName: Routes.changePasswordScreen,
        ),
      ],
    ),
  ];
}
