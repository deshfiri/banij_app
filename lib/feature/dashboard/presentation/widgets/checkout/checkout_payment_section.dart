import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/dashboard_provider.dart';

class CheckoutPaymentSection extends StatelessWidget {
  final DashboardProvider dashboardProvider;

  const CheckoutPaymentSection({
    super.key,
    required this.dashboardProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment method'.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        UIHelper.verticalSpace(10.h),
        Container(
          decoration: BoxDecoration(
            color: AppColorsTheme.cardBg(context),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColorsTheme.borderColor(context)),
          ),
          child: dashboardProvider.isLoadingCheckout
              ? _buildPaymentShimmer(context)
              : Column(
                  children: _buildPaymentList(context),
                ),
        ),
      ],
    );
  }

  List<Widget> _buildPaymentList(BuildContext context) {
    final apiMethods = dashboardProvider.paymentResponseModel?.data ?? [];
    if (apiMethods.isNotEmpty) {
      return List.generate(apiMethods.length, (index) {
        final method = apiMethods[index];
        final name = method.typeLabel ?? method.name ?? 'Payment Method';
        final code = method.code ?? method.type ?? method.id ?? name;
        final description = method.maskedNumber != null ? '${method.label ?? ''} ${method.maskedNumber}' : method.description;
        final isLast = index == apiMethods.length - 1;

        final brandColor = _getPaymentColor(name);
        final iconData = _getPaymentIcon(name);

        return Column(
          children: [
            _buildPaymentOption(
              context: context,
              title: name,
              subtitleText: description,
              icon: iconData,
              iconColor: brandColor,
              value: code,
            ),
            if (!isLast) Divider(height: 1, color: AppColorsTheme.borderColor(context)),
          ],
        );
      });
    }

    return [
      _buildPaymentOption(
        context: context,
        title: 'bKash',
        subtitleText: 'bKash Online Payment',
        icon: Icons.account_balance_wallet_rounded,
        iconColor: const Color(0xFFE2136E),
        value: 'bKash',
      ),
      Divider(height: 1, color: AppColorsTheme.borderColor(context)),
      _buildPaymentOption(
        context: context,
        title: 'Nagad',
        subtitleText: 'Nagad Online Payment',
        icon: Icons.mobile_friendly_rounded,
        iconColor: const Color(0xFFED1C24),
        value: 'Nagad',
      ),
      Divider(height: 1, color: AppColorsTheme.borderColor(context)),
      _buildPaymentOption(
        context: context,
        title: 'Credit / Debit Card',
        subtitleText: 'Visa, MasterCard, AMEX, SSLCommerz',
        icon: Icons.credit_card_rounded,
        iconColor: const Color(0xFF0284C7),
        value: 'Card',
      ),
      Divider(height: 1, color: AppColorsTheme.borderColor(context)),
      _buildPaymentOption(
        context: context,
        title: 'PayPal',
        subtitleText: null,
        icon: Icons.payment_rounded,
        iconColor: primaryOrange,
        value: 'PayPal',
      ),
      Divider(height: 1, color: AppColorsTheme.borderColor(context)),
      _buildPaymentOption(
        context: context,
        title: 'Other payment methods',
        subtitleText: 'T/T\nPlace order first, pay with your preferred method later.',
        icon: Icons.account_balance_outlined,
        iconColor: AppColorsTheme.textMutedColor(context),
        value: 'Other payment methods',
      ),
    ];
  }

  Color _getPaymentColor(String val) {
    final lower = val.toLowerCase();
    if (lower.contains('bkash')) {
      return const Color(0xFFE2136E);
    } else if (lower.contains('nagad')) {
      return const Color(0xFFED1C24);
    } else if (lower.contains('card') || lower.contains('visa')) {
      return const Color(0xFF0284C7);
    } else {
      return primaryOrange;
    }
  }

  IconData _getPaymentIcon(String val) {
    final lower = val.toLowerCase();
    if (lower.contains('card') || lower.contains('visa') || lower.contains('master')) {
      return Icons.credit_card_rounded;
    } else if (lower.contains('bkash')) {
      return Icons.account_balance_wallet_rounded;
    } else if (lower.contains('nagad')) {
      return Icons.mobile_friendly_rounded;
    } else if (lower.contains('bank')) {
      return Icons.account_balance_rounded;
    } else if (lower.contains('paypal')) {
      return Icons.payment_rounded;
    } else {
      return Icons.account_balance_outlined;
    }
  }

  Widget _buildPaymentShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Padding(
      padding: EdgeInsets.all(14.w),
      child: Column(
        children: List.generate(3, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12.h),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Row(
                children: [
                  Container(
                    width: 20.w,
                    height: 20.h,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                  UIHelper.horizontalSpace(12.w),
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
                  ),
                  UIHelper.horizontalSpace(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 120.w, height: 14.h, color: Colors.white),
                        UIHelper.verticalSpace(4.h),
                        Container(width: 180.w, height: 10.h, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required String title,
    String? subtitleText,
    required IconData icon,
    Color? iconColor,
    required String value,
  }) {
    return InkWell(
      onTap: () {
        dashboardProvider.setSelectedPaymentMethod(value);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: dashboardProvider.selectedPaymentMethod,
              activeColor: primaryOrange,
              onChanged: (val) {
                if (val != null) {
                  dashboardProvider.setSelectedPaymentMethod(val);
                }
              },
            ),
            UIHelper.horizontalSpace(8.w),
            Icon(icon, color: iconColor ?? primaryOrange, size: 22.sp),
            UIHelper.horizontalSpace(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  if (subtitleText != null && subtitleText.isNotEmpty) ...[
                    UIHelper.verticalSpace(2.h),
                    Text(
                      subtitleText,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColorsTheme.textMutedColor(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
