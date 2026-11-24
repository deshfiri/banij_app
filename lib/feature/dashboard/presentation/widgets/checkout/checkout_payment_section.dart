import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../constants/color.dart';
import '../../../../../providers/dashboard_provider.dart';
import 'checkout_shimmer.dart';
import 'checkout_ui.dart';

/// One selectable payment row. [value] is what the provider stores.
class _PaymentOption {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final String value;

  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.value,
  });
}

/// Payment method section: API methods (or built-in defaults) as selectable tiles.
class CheckoutPaymentSection extends StatelessWidget {
  final DashboardProvider dashboardProvider;

  const CheckoutPaymentSection({
    super.key,
    required this.dashboardProvider,
  });

  @override
  Widget build(BuildContext context) {
    return CheckoutSectionCard(
      title: 'Payment method'.tr,
      icon: Icons.account_balance_wallet_outlined,
      child: dashboardProvider.isLoadingCheckout ? const _PaymentShimmer() : _buildPaymentList(context),
    );
  }

  Widget _buildPaymentList(BuildContext context) {
    final options = _options(context);
    final selected = dashboardProvider.selectedPaymentMethod;

    return RadioGroup<String>(
      groupValue: selected,
      onChanged: (val) {
        if (val != null) {
          dashboardProvider.setSelectedPaymentMethod(val);
        }
      },
      child: Column(
        children: [
          for (final option in options)
            CheckoutOptionTile(
              isSelected: option.value == selected,
              onTap: () => dashboardProvider.setSelectedPaymentMethod(option.value),
              leading: CheckoutIconBadge(icon: option.icon, color: option.iconColor ?? primaryOrange, size: 38.w),
              title: option.title,
              subtitle: option.subtitle,
              trailing: Radio<String>(
                value: option.value,
                activeColor: primaryOrange,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  /// Gateways from `GET /checkout` first; otherwise saved methods from the
  /// API, otherwise the built-in defaults.
  List<_PaymentOption> _options(BuildContext context) {
    final gateways = dashboardProvider.checkoutGateways.where((g) => g.isAvailable).toList();
    if (gateways.isNotEmpty) {
      return gateways
          .map((gateway) => _PaymentOption(
                title: gateway.label,
                subtitle: gateway.description,
                icon: _iconFor(gateway.value),
                iconColor: _colorFor(gateway.value),
                value: gateway.value,
              ))
          .toList();
    }

    // Package checkout without a gateway list: SSLCommerz handles every
    // method (bKash, Nagad, cards, net banking) on its own page.
    if (dashboardProvider.isPackageCheckout) {
      return [
        _PaymentOption(
          title: 'SSLCommerz',
          subtitle: 'bKash, Nagad, Rocket, Visa, MasterCard, AMEX & net banking'.tr,
          icon: Icons.verified_user_rounded,
          iconColor: infoBlue,
          value: DashboardProvider.sslCommerzGateway,
        ),
      ];
    }

    // Wholesale order: the methods `GET /wholesale/checkout` accepts.
    final wholesaleMethods = dashboardProvider.wholesalePaymentMethods;
    if (wholesaleMethods.isNotEmpty) {
      return wholesaleMethods
          .map((method) => _PaymentOption(
                title: method.label,
                subtitle: method.description,
                icon: _iconFor(method.value),
                iconColor: _colorFor(method.value),
                value: method.value,
              ))
          .toList();
    }

    final apiMethods = dashboardProvider.paymentResponseModel?.data ?? [];
    if (apiMethods.isNotEmpty) {
      return apiMethods.map((method) {
        final name = method.typeLabel ?? method.name ?? 'Payment Method';
        return _PaymentOption(
          title: name,
          subtitle: method.maskedNumber != null ? '${method.label ?? ''} ${method.maskedNumber}' : method.description,
          icon: _iconFor(name),
          iconColor: _colorFor(name),
          value: method.code ?? method.type ?? method.id ?? name,
        );
      }).toList();
    }

    // Titles/subtitles are display-only (translated); [value]s are unchanged.
    return [
      _PaymentOption(
        title: 'SSLCommerz',
        subtitle: 'bKash, Nagad, Rocket, Visa, MasterCard, AMEX & net banking'.tr,
        icon: Icons.verified_user_rounded,
        iconColor: infoBlue,
        value: DashboardProvider.sslCommerzGateway,
      ),
      _PaymentOption(
        title: 'bKash',
        subtitle: 'bKash Online Payment'.tr,
        icon: Icons.account_balance_wallet_rounded,
        iconColor: bkashPink,
        value: 'bKash',
      ),
      _PaymentOption(
        title: 'Nagad',
        subtitle: 'Nagad Online Payment'.tr,
        icon: Icons.mobile_friendly_rounded,
        iconColor: nagadRed,
        value: 'Nagad',
      ),
      _PaymentOption(
        title: 'Credit / Debit Card'.tr,
        subtitle: 'Visa, MasterCard, AMEX, SSLCommerz',
        icon: Icons.credit_card_rounded,
        iconColor: infoBlue,
        value: 'Card',
      ),
      const _PaymentOption(
        title: 'PayPal',
        subtitle: null,
        icon: Icons.payment_rounded,
        iconColor: primaryOrange,
        value: 'PayPal',
      ),
      _PaymentOption(
        title: 'Other payment methods'.tr,
        subtitle: 'T/T\n${'Place order first, pay with your preferred method later.'.tr}',
        icon: Icons.account_balance_outlined,
        iconColor: AppColorsTheme.textMutedColor(context),
        value: 'Other payment methods',
      ),
    ];
  }

  static Color _colorFor(String val) {
    final lower = val.toLowerCase();
    if (lower.contains('bkash')) return bkashPink;
    if (lower.contains('nagad')) return nagadRed;
    if (lower.contains('card') || lower.contains('visa') || lower.contains('ssl')) return infoBlue;
    return primaryOrange;
  }

  static IconData _iconFor(String val) {
    final lower = val.toLowerCase();
    if (lower.contains('card') || lower.contains('visa') || lower.contains('master') || lower.contains('ssl')) {
      return Icons.credit_card_rounded;
    }
    if (lower.contains('bkash')) return Icons.account_balance_wallet_rounded;
    if (lower.contains('nagad')) return Icons.mobile_friendly_rounded;
    if (lower.contains('bank')) return Icons.account_balance_rounded;
    if (lower.contains('paypal')) return Icons.payment_rounded;
    return Icons.account_balance_outlined;
  }
}

class _PaymentShimmer extends StatelessWidget {
  const _PaymentShimmer();

  @override
  Widget build(BuildContext context) {
    final colors = CheckoutShimmerColors.of(context);

    return Shimmer.fromColors(
      baseColor: colors.base,
      highlightColor: colors.highlight,
      child: Column(
        children: List.generate(3, (index) {
          return Container(
            margin: EdgeInsets.only(bottom: index == 2 ? 0 : 10.h),
            height: 58.h,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r)),
          );
        }),
      ),
    );
  }
}
