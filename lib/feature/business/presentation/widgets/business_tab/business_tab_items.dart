import 'package:flutter/material.dart';

import '../../../../../constants/image_const.dart';
import '../../../../../helpers/all_routes.dart';

/// One business action tile. Title/subtitle are translation keys.
class BusinessTabItem {
  final String titleKey;
  final String iconAsset;
  final void Function(BuildContext context) onTap;

  const BusinessTabItem({
    required this.titleKey,
    required this.iconAsset,
    required this.onTap,
  });

  static final List<BusinessTabItem> all = [
    BusinessTabItem(
      titleKey: 'Verification',
      iconAsset: verificationIconAsset,
      onTap: (ctx) => Navigator.pushNamed(ctx, Routes.kycVerificationScreen),
    ),
    BusinessTabItem(
      titleKey: 'Subscription',
      iconAsset: subscriptionIconAsset,
      onTap: (ctx) => Navigator.pushNamed(ctx, Routes.accountScreen, arguments: 'Package'),
    ),
    BusinessTabItem(
      titleKey: 'Partner Network',
      iconAsset: partnerNetworkIconAsset,
      onTap: (ctx) => Navigator.pushNamed(ctx, Routes.partnerNetworkScreen),
    ),
    BusinessTabItem(
      titleKey: 'Addresses',
      iconAsset: addressesIconAsset,
      onTap: (ctx) => Navigator.pushNamed(ctx, Routes.addressesScreen),
    ),
  ];
}
