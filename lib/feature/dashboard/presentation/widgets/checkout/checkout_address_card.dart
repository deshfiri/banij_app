import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../common_widget/gradient_button.dart';
import '../../../../../constants/color.dart';
import '../../../../../helpers/all_routes.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/dashboard_provider.dart';
import 'checkout_shimmer.dart';
import 'checkout_ui.dart';

/// Shipping address section. Tap opens Add Address (no address yet) or the
/// saved-address picker.
class CheckoutAddressCard extends StatelessWidget {
  final DashboardProvider dashboardProvider;

  const CheckoutAddressCard({super.key, required this.dashboardProvider});

  /// Opens Add Address, then refreshes checkout when the user comes back.
  void _openAddAddress(BuildContext context) {
    Navigator.pushNamed(context, Routes.addAddressScreen).then((_) {
      dashboardProvider.fetchCheckoutState();
    });
  }

  void _showAddressSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      builder: (ctx) => _AddressSelectionSheet(
        hostContext: context,
        sheetContext: ctx,
        dashboardProvider: dashboardProvider,
        onAddNew: () {
          Navigator.pop(ctx);
          _openAddAddress(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedAddress = dashboardProvider.selectedAddress;
    final muted = AppColorsTheme.textMutedColor(context);

    return CheckoutSectionCard(
      title: 'Shipping address'.tr,
      icon: Icons.location_on_outlined,
      onTap: dashboardProvider.isLoadingCheckout
          ? null
          : () {
              if (selectedAddress == null) {
                _openAddAddress(context);
              } else {
                _showAddressSelectionSheet(context);
              }
            },
      trailing: dashboardProvider.isLoadingCheckout
          ? null
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                (selectedAddress == null ? 'Add' : 'Change').tr,
                style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w800, color: primaryOrange),
              ),
            ),
      child: dashboardProvider.isLoadingCheckout
          ? const _AddressShimmer()
          : Row(
              children: [
                const CheckoutIconBadge(icon: Icons.location_on_rounded),
                UIHelper.horizontalSpace(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedAddress != null ? selectedAddress.recipientName : 'Address is not found'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                      UIHelper.verticalSpace(2.h),
                      Text(
                        selectedAddress != null
                            ? selectedAddress.fullAddressFormatted
                            : 'Add your address for shipping options and accurate delivery.'.tr,
                        style: TextStyle(fontSize: 11.5.sp, height: 1.35, color: muted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 22.sp, color: muted),
              ],
            ),
    );
  }
}

class _AddressShimmer extends StatelessWidget {
  const _AddressShimmer();

  @override
  Widget build(BuildContext context) {
    final colors = CheckoutShimmerColors.of(context);
    return Shimmer.fromColors(
      baseColor: colors.base,
      highlightColor: colors.highlight,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}

/// Bottom sheet listing saved addresses; tapping one selects it for checkout.
class _AddressSelectionSheet extends StatelessWidget {
  final BuildContext hostContext;
  final BuildContext sheetContext;
  final DashboardProvider dashboardProvider;
  final VoidCallback onAddNew;

  const _AddressSelectionSheet({
    required this.hostContext,
    required this.sheetContext,
    required this.dashboardProvider,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext _) {
    // Styles resolve against the host screen, as in the original inline builder.
    final context = hostContext;
    final ctx = sheetContext;
    final addresses = dashboardProvider.addressResponseModel?.data ?? [];
    final muted = AppColorsTheme.textMutedColor(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42.w,
                height: 4.5.h,
                decoration: BoxDecoration(color: muted.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
            UIHelper.verticalSpace(10.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Address'.tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColorsTheme.textMainColor(context)),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            UIHelper.verticalSpace(8.h),
            if (addresses.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Column(
                    children: [
                      const CheckoutIconBadge(icon: Icons.location_off_outlined),
                      UIHelper.verticalSpace(10.h),
                      Text('Address is not found'.tr, style: TextStyle(fontSize: 13.5.sp, color: muted)),
                    ],
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 320.h),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: addresses.length,
                  itemBuilder: (_, index) {
                    final addr = addresses[index];
                    final isSelected = dashboardProvider.selectedAddress?.id == addr.id;
                    return CheckoutOptionTile(
                      isSelected: isSelected,
                      leading: CheckoutIconBadge(
                        icon: Icons.location_on_rounded,
                        color: isSelected ? primaryOrange : muted,
                        size: 36.w,
                      ),
                      title: addr.recipientName,
                      subtitle: addr.fullAddressFormatted.isNotEmpty
                          ? addr.fullAddressFormatted
                          : 'No address details'.tr,
                      trailing: Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                        color: isSelected ? primaryOrange : muted,
                        size: 22.sp,
                      ),
                      onTap: () {
                        dashboardProvider.selectWholesaleAddress(addr);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            UIHelper.verticalSpace(12.h),
            GradientButton(
              label: 'Add New Address'.tr,
              trailingIcon: Icons.add_rounded,
              onPressed: onAddNew,
            ),
          ],
        ),
      ),
    );
  }
}
