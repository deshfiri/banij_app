import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../finance/presentation/invoices_receipts_screen.dart';
import '../all_modules_screen.dart';
import 'dashboard_card_decoration.dart';
import '../orders_screen.dart';
import '../products_screen.dart';

/// "Quick Access" header plus the Products / Order / Finance shortcut tiles.
class QuickAccessSectionWidget extends StatelessWidget {
  const QuickAccessSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      QuickAccessTile(
        title: 'hub_products'.tr,
        iconAsset: productIcon,
        onTap: () =>
            ProductsScreen.open(context, 'hub_products'.tr, isCatalog: true),
      ),
      QuickAccessTile(
        title: 'hub_orders'.tr,
        iconAsset: cartIconAsset,
        onTap: () => OrdersScreen.open(context, 'hub_all_orders'.tr),
      ),
      QuickAccessTile(
        title: 'finance'.tr,
        iconAsset: financeIconAsset,
        onTap: () =>
            InvoicesReceiptsScreen.open(context, initialTab: 'Invoices'),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardSectionHeader(
            title: 'Quick Access'.tr,
            actionLabel: 'See All'.tr,
            onAction: () => AllModulesScreen.open(context),
          ),
          UIHelper.verticalSpace(10.h),
          SizedBox(
            height: 114.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final tile in tiles)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: tile,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section title with an orange accent bar and an optional trailing action.
class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final actionColor = AppColorsTheme.textMainColor(context);

    return Row(
      children: [
        Container(
          width: 4.w,
          height: 17.h,
          decoration: BoxDecoration(
            color: primaryOrange,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        UIHelper.horizontalSpace(8.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: AppColorsTheme.textMainColor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actionLabel != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              child: Row(
                children: [
                  Text(
                    actionLabel!,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w800,
                      color: actionColor,
                    ),
                  ),
                  UIHelper.horizontalSpace(2.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: actionColor,
                    size: 14.sp,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Square shortcut tile: icon in a circle, title below, chevron in the corner.
class QuickAccessTile extends StatelessWidget {
  final String title;
  final String iconAsset;

  /// Null shows the tile without any tap action.
  final VoidCallback? onTap;

  const QuickAccessTile({
    super.key,
    required this.title,
    required this.iconAsset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = 22.r;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
          decoration: DashboardCardDecoration.of(context, radius: 22),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: primaryOrange.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: primaryOrange,
                    size: 14.sp,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(9.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColorsTheme.innerCardBg(context)
                            : lightBackground,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryOrange.withValues(
                              alpha: isDark ? 0.2 : 0.12,
                            ),
                            blurRadius: 8.r,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        iconAsset,
                        width: 24.w,
                        height: 24.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                    UIHelper.verticalSpace(6.h),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid of [QuickAccessTile]s with the same columns, size and spacing as the
/// dashboard Quick Access row and the All Modules screen. For use inside a
/// scroll view (shrink-wraps, does not scroll itself).
class QuickAccessGrid extends StatelessWidget {
  final List<QuickAccessTile> tiles;

  const QuickAccessGrid({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 10.h,
        mainAxisExtent: 114.h,
      ),
      itemCount: tiles.length,
      itemBuilder: (_, index) => tiles[index],
    );
  }
}
