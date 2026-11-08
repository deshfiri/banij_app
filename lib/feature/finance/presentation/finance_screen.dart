import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/finance_card_widget.dart';
import '../../../constants/color.dart';
import '../../../constants/image_const.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/supplier_dashboard_provider.dart';
import 'widgets/invoices_receipts_sheet.dart';

class FinanceScreenBody extends StatelessWidget {
  final VoidCallback? onOpenDrawer;

  const FinanceScreenBody({
    super.key,
    this.onOpenDrawer,
  });

  void _handleInvoiceTap(BuildContext context) {
    InvoicesReceiptsSheet.show(context, initialTab: 'Invoices');
  }

  void _handleReceiptsTap(BuildContext context) {
    InvoicesReceiptsSheet.show(context, initialTab: 'Receipts');
  }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: AppColorsTheme.background(context),
      child: Column(
        children: [
          // Finance Top Header / AppBar Stack (Fixed Centered Logo & Left Drawer Menu Icon)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColorsTheme.cardBg(context),
              border: Border(
                bottom: BorderSide(
                  color: AppColorsTheme.borderColor(context),
                  width: 1.w,
                ),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 100% Dead-Centered Logo
                Center(
                  child: Image.asset(
                    isDark ? whiteLogo : logo,
                    width: 110.w,
                    height: 36.h,
                    fit: BoxFit.contain,
                  ),
                ),
                // Left Drawer Menu Icon
                if (onOpenDrawer != null)
                  Positioned(
                    left: 0,
                    child: IconButton(
                      onPressed: onOpenDrawer,
                      icon: Icon(
                        Icons.menu_rounded,
                        color: AppColorsTheme.textMainColor(context),
                        size: 24.sp,
                      ),
                    ),
                  ),
                // Right Action Icons: Notifications & Profile
                Positioned(
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.notificationScreen);
                        },
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              color: AppColorsTheme.textMainColor(context),
                              size: 22.sp,
                            ),
                            Positioned(
                              top: -2.h,
                              right: -2.w,
                              child: Container(
                                width: 8.w,
                                height: 8.h,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _handleProfileTap(context),
                        icon: Icon(
                          Icons.person_outline_rounded,
                          color: AppColorsTheme.textMainColor(context),
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body Content with Cards
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'finance'.tr,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColorsTheme.textMainColor(context),
                              ),
                            ),
                            UIHelper.verticalSpace(2.h),
                            Text(
                              'financial_subtitle'.tr,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColorsTheme.textMutedColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: primaryOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'B2B Billing',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(20.h),

                  // Card 1: Invoice
                  FinanceCardWidget(
                    title: 'invoice'.tr,
                    subtitle: 'invoice_subtitle'.tr,
                    iconData: Icons.receipt_long_outlined,
                    onTap: () => _handleInvoiceTap(context),
                  ),
                  UIHelper.verticalSpace(16.h),

                  // Card 2: Receipts
                  FinanceCardWidget(
                    title: 'receipts'.tr,
                    subtitle: 'receipts_subtitle'.tr,
                    iconData: Icons.payments_outlined,
                    onTap: () => _handleReceiptsTap(context),
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
