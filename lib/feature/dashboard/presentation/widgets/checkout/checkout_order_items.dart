import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/toast.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/dashboard_provider.dart';
import '../../../model/wholesale_cart_model.dart';
import 'checkout_ui.dart';

/// Rounded product image with an orange placeholder when the URL fails.
class _ProductImage extends StatelessWidget {
  final String url;
  final double size;

  const _ProductImage({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: size,
        height: size,
        color: primaryOrange.withValues(alpha: isDark ? 0.14 : 0.08),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Center(
            child: Icon(Icons.inventory_2_outlined, color: primaryOrange, size: size * 0.4),
          ),
        ),
      ),
    );
  }
}

/// One server cart line: thumbnail, name, "qty × unit price", line total.
class CheckoutCartLineTile extends StatelessWidget {
  final WholesaleCartLine line;

  const CheckoutCartLineTile({super.key, required this.line});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: isDark ? AppColorsTheme.innerCardBg(context) : lightBackground,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          _ProductImage(url: line.product?.image?.url ?? '', size: 54.w),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product?.name ?? 'Product Item'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                UIHelper.verticalSpace(3.h),
                Text(
                  '${line.quantity ?? 1} × ${line.unitPrice?.formatted ?? ''}',
                  style: TextStyle(fontSize: 11.5.sp, color: AppColorsTheme.textMutedColor(context)),
                ),
              ],
            ),
          ),
          UIHelper.horizontalSpace(8.w),
          Text(
            line.lineTotal?.formatted ?? '',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: primaryOrange),
          ),
        ],
      ),
    );
  }
}

/// Fallback card when the server cart is empty: the product being ordered
/// with a quantity stepper (bound to [DashboardProvider.orderQuantity]).
class CheckoutSingleProductCard extends StatelessWidget {
  final String imageUrl;
  final String categoryVariant;
  final String productTitle;
  final int minOrder;
  final String productPrice;
  final int quantity;

  const CheckoutSingleProductCard({
    super.key,
    required this.imageUrl,
    required this.categoryVariant,
    required this.productTitle,
    required this.minOrder,
    required this.productPrice,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = AppColorsTheme.textMainColor(context);
    final muted = AppColorsTheme.textMutedColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _ProductImage(url: imageUrl, size: 76.w),
                Positioned(
                  bottom: 5.h,
                  left: 5.w,
                  right: 5.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: textMain.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      categoryVariant.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 8.sp, color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
            UIHelper.horizontalSpace(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productTitle,
                    style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800, color: mainColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  UIHelper.verticalSpace(4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      (minOrder > 1 ? 'Min. order: @count pieces' : 'Min. order: @count piece')
                          .trParams({'count': '$minOrder'}),
                      style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: primaryOrange),
                    ),
                  ),
                  UIHelper.verticalSpace(8.h),
                  Text(
                    productPrice,
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                  ),
                ],
              ),
            ),
          ],
        ),
        UIHelper.verticalSpace(12.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => ToastUtil.showSuccessMessage('Note dialog opened'.tr),
                child: Row(
                  children: [
                    Icon(Icons.edit_note_rounded, size: 18.sp, color: muted),
                    UIHelper.horizontalSpace(4.w),
                    Flexible(
                      child: Text(
                        'Add note to supplier'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: muted,
                          decoration: TextDecoration.underline,
                          decorationColor: muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _QuantityStepper(quantity: quantity),
          ],
        ),
      ],
    );
  }
}

/// −  qty  + stepper with gradient round buttons; taps go to
/// [DashboardProvider] order quantity.
class _QuantityStepper extends StatelessWidget {
  final int quantity;

  const _QuantityStepper({required this.quantity});

  @override
  Widget build(BuildContext context) {
    Widget stepButton(IconData icon, VoidCallback onTap) => CheckoutPillButton(
          onTap: onTap,
          shape: BoxShape.circle,
          padding: EdgeInsets.all(6.w),
          child: Icon(icon, size: 16.sp, color: Colors.white),
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        stepButton(Icons.remove_rounded, () => context.read<DashboardProvider>().decrementOrderQuantity()),
        SizedBox(
          width: 40.w,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
        ),
        stepButton(Icons.add_rounded, () => context.read<DashboardProvider>().incrementOrderQuantity()),
      ],
    );
  }
}
