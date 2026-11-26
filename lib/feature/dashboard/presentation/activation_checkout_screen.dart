import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/gradient_button.dart';
import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/packages_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../package/presentation/widgets/subscription/subscription_states.dart';
import '../model/checkout_response_model.dart';
import 'widgets/checkout/checkout_attention_card.dart';
import 'widgets/checkout/checkout_header_widgets.dart';
import 'widgets/checkout/checkout_payment_flow.dart';
import 'widgets/checkout/checkout_payment_section.dart';
import 'widgets/checkout/checkout_ui.dart';
import 'widgets/checkout/checkout_voucher_section.dart';

/// Package activation checkout — the `/checkout` APIs, kept apart from the
/// wholesale cart checkout:
///
/// `GET /checkout` (quote, gateways, deadline; `?coupon=` to preview) →
/// Pay → `POST /checkout` → SSLCommerz hosted page →
/// `POST /checkout/payment/verify` / `GET /checkout/payment` → result.
///
/// Opened after choosing a package (Packages) or from Subscription when an
/// activation payment is due. An attempt left open (app closed mid-payment)
/// can be resumed from here.
class ActivationCheckoutScreen extends StatefulWidget {
  const ActivationCheckoutScreen({super.key});

  @override
  State<ActivationCheckoutScreen> createState() => _ActivationCheckoutScreenState();
}

class _ActivationCheckoutScreenState extends State<ActivationCheckoutScreen> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final provider = context.read<DashboardProvider>();
      await provider.fetchActivationCheckout();
      if (mounted && _couponController.text.isEmpty) _couponController.text = provider.checkoutCoupon ?? '';
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _refresh() => context.read<DashboardProvider>().fetchActivationCheckout();

  Future<void> _pay(DashboardProvider provider, String amountText) async {
    final paid = await CheckoutPaymentFlow.runActivationPayment(
      context,
      provider,
      coupon: provider.checkoutCoupon,
      amountText: amountText,
    );
    if (!mounted) return;
    paid ? _afterPaid() : unawaited(provider.loadLatestPayment());
  }

  Future<void> _resume(DashboardProvider provider, String amountText) async {
    final paid = await CheckoutPaymentFlow.resumeActivationPayment(context, provider, amountText: amountText);
    if (!mounted) return;
    paid ? _afterPaid() : unawaited(provider.fetchActivationCheckout());
  }

  /// The backend confirmed the payment: reload what it unlocks, then go to a
  /// single dashboard.
  void _afterPaid() {
    unawaited(context.read<DashboardProvider>().onActivationPaid());
    unawaited(context.read<SubscriptionProvider>().fetchSubscription(force: true));
    unawaited(context.read<PackagesProvider>().fetchPackages(force: true));
    Navigator.pushNamedAndRemoveUntil(context, Routes.dashboardScreen, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final data = provider.checkoutResponseModel?.data;
    final totalText = data?.quote?.total?.formatted ?? data?.quote?.total?.amount ?? '—';
    final canPay = provider.hasPayableActivation && !provider.isLoadingActivation;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(
              title: 'Activate package'.tr,
              subtitle: 'Pay securely with SSLCommerz'.tr,
              bottom: const CheckoutTrustPill(),
            ),
            Expanded(
              child: RefreshIndicator(
                color: primaryOrange,
                onRefresh: _refresh,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final side = constraints.maxWidth > 760 ? (constraints.maxWidth - 720) / 2 : 16.w;
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(side, 16.h, side, 20.h),
                      children: _buildContent(provider, data, totalText),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: data == null
            ? null
            : _PayBar(
                totalText: totalText,
                canPay: canPay,
                isLoading: provider.isPaying,
                onPay: () => _pay(provider, totalText),
              ),
      ),
    );
  }

  List<Widget> _buildContent(DashboardProvider provider, CheckoutData? data, String totalText) {
    if (data == null && provider.isLoadingActivation) return const [SubscriptionShimmer()];

    final openPayment = provider.hasOpenPayment
        ? CheckoutOpenPaymentCard(
            status: provider.latestPayment?.status,
            onCheckStatus: () => _resume(provider, totalText),
          )
        : null;

    if (data == null) {
      return [
        if (openPayment != null) ...[openPayment, UIHelper.verticalSpace(14.h)],
        SubscriptionMessageView(
          icon: Icons.workspace_premium_outlined,
          title: 'No package to activate'.tr,
          message: provider.activationError ?? 'Choose a package first, then pay its activation here.'.tr,
          actionLabel: 'Choose a package'.tr,
          onAction: () => Navigator.pushReplacementNamed(context, Routes.packagesScreen),
        ),
      ];
    }

    Widget gap() => UIHelper.verticalSpace(14.h);
    return [
      if (openPayment != null) ...[openPayment, gap()],
      if (data.package != null) ...[CheckoutPackageBanner(package: data.package!), gap()],
      _QuoteCard(data: data, couponText: provider.checkoutCoupon),
      gap(),
      CheckoutVoucherSection(dashboardProvider: provider, couponController: _couponController, forActivation: true),
      gap(),
      CheckoutPaymentSection(dashboardProvider: provider, forActivation: true),
      if (_deadlineText(data.deadline) case final deadline?) ...[gap(), _DeadlineNote(text: deadline)],
    ];
  }

  /// "Complete this payment by 25 Nov 2026, 6:30 PM", or null.
  static String? _deadlineText(String? raw) {
    final date = raw == null ? null : DateTime.tryParse(raw);
    if (date == null) return null;
    return 'Complete this payment by @date'.trParams({'date': DateFormat('d MMM yyyy, h:mm a').format(date.toLocal())});
  }
}

/// Package lines, tax notes, coupon and the total to pay.
class _QuoteCard extends StatelessWidget {
  final CheckoutData data;
  final String? couponText;

  const _QuoteCard({required this.data, required this.couponText});

  @override
  Widget build(BuildContext context) {
    final quote = data.quote;
    final muted = AppColorsTheme.textMutedColor(context);
    final main = AppColorsTheme.textMainColor(context);

    Widget row(String label, String? value, {Color? valueColor, bool bold = false}) => Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12.5.sp, height: 1.35, color: bold ? main : muted),
            ),
          ),
          if (value != null) ...[
            UIHelper.horizontalSpace(12.w),
            Text(
              value,
              style: TextStyle(
                fontSize: bold ? 16.sp : 12.5.sp,
                fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
                color: valueColor ?? main,
              ),
            ),
          ],
        ],
      ),
    );

    return CheckoutSectionCard(
      title: 'Payment summary'.tr,
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          for (final line in quote?.lineItems ?? const <CheckoutQuoteLine>[]) row(line.label, line.amount),
          for (final tax in quote?.tax ?? const <String>[]) row(tax, null),
          if (quote?.subtotal?.formatted != null) row('Subtotal'.tr, quote!.subtotal!.formatted),
          if (couponText != null) row('${'Coupon'.tr} ($couponText)', '✓', valueColor: successGreen),
          if (quote?.taxIncluded?.formatted != null) row('Tax included'.tr, quote!.taxIncluded!.formatted),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Divider(height: 1, color: AppColorsTheme.borderColor(context)),
          ),
          row(
            'Total'.tr,
            quote?.total?.formatted ?? quote?.total?.amount ?? '—',
            valueColor: primaryOrange,
            bold: true,
          ),
          if (quote?.isPayable == false) ...[
            UIHelper.verticalSpace(6.h),
            Text(
              'There is nothing to pay for this package right now.'.tr,
              style: TextStyle(fontSize: 11.5.sp, color: muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeadlineNote extends StatelessWidget {
  final String text;

  const _DeadlineNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.schedule_rounded, size: 15.sp, color: AppColorsTheme.textMutedColor(context)),
        UIHelper.horizontalSpace(6.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 11.5.sp, color: AppColorsTheme.textMutedColor(context)),
          ),
        ),
      ],
    );
  }
}

/// Total and the "Pay" button (disabled when there is nothing payable).
class _PayBar extends StatelessWidget {
  final String totalText;
  final bool canPay;
  final bool isLoading;
  final VoidCallback onPay;

  const _PayBar({required this.totalText, required this.canPay, required this.isLoading, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        border: Border(top: BorderSide(color: AppColorsTheme.borderColor(context))),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 10.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total'.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColorsTheme.textMutedColor(context),
                        ),
                      ),
                      UIHelper.horizontalSpace(8.w),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            totalText,
                            style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                          ),
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(10.h),
                  Opacity(
                    opacity: canPay || isLoading ? 1 : 0.5,
                    child: AbsorbPointer(
                      absorbing: !canPay,
                      child: GradientButton(
                        label: '${'Pay'.tr} $totalText',
                        trailingIcon: Icons.lock_rounded,
                        isLoading: isLoading,
                        onPressed: onPay,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
