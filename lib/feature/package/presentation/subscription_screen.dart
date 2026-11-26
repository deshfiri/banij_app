import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/subscription_provider.dart';
import 'widgets/subscription/current_subscription_card.dart';
import 'widgets/subscription/previous_terms_section.dart';
import 'widgets/subscription/subscription_states.dart';

/// Business tools › Subscription: the current package, its entitlements and
/// the account's previous terms. Data comes from `GET /subscription`.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SubscriptionProvider>().fetchSubscription(force: true);
      // Is an activation payment due (or one left open)?
      context.read<DashboardProvider>().fetchActivationCheckout();
    });
  }

  Future<void> _refresh() => Future.wait([
        context.read<SubscriptionProvider>().fetchSubscription(force: true),
        context.read<DashboardProvider>().fetchActivationCheckout(),
      ]);

  void _openActivation() {
    Navigator.pushNamed(context, Routes.activationCheckoutScreen).then((_) {
      if (mounted) _refresh();
    });
  }

  void _openPackages() {
    Navigator.pushNamed(context, Routes.packagesScreen).then((_) {
      if (mounted) _refresh();
    });
  }

  Future<void> _renew() async {
    final error = await context.read<SubscriptionProvider>().renewSubscription();
    _showResult(error, 'sub_renewed'.tr);
  }

  Future<void> _cancel(String packageName) async {
    final confirmed = await showCancelSubscriptionDialog(context, packageName);
    if (!confirmed || !mounted) return;
    final error = await context.read<SubscriptionProvider>().cancelSubscription();
    _showResult(error, 'sub_cancelled'.tr);
  }

  void _showResult(String? error, String successMessage) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error == null ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        content: Text(error ?? successMessage),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubscriptionProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(title: 'subscription'.tr, subtitle: 'sub_subtitle'.tr),
            Expanded(
              child: RefreshIndicator(
                color: primaryOrange,
                onRefresh: _refresh,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Keep content readable on tablets.
                    final side = constraints.maxWidth > 760 ? (constraints.maxWidth - 720) / 2 : 16.w;
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(side, 18.h, side, 28.h),
                      children: _buildContent(provider),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(SubscriptionProvider provider) {
    final data = provider.subscription;

    if (data == null && provider.isLoading) return const [SubscriptionShimmer()];

    if (data == null) {
      return [
        SubscriptionMessageView(
          icon: Icons.cloud_off_rounded,
          title: 'sub_error_title'.tr,
          message: provider.error ?? 'sub_error_title'.tr,
          actionLabel: 'sub_try_again'.tr,
          onAction: _refresh,
        ),
      ];
    }

    final current = data.current;
    final dashboard = context.watch<DashboardProvider>();
    // Only for an account that has not activated yet: an active plan's
    // renewal is handled by Renew, not by the activation checkout.
    final activationDue = (current == null || !current.isActive) &&
        (dashboard.hasPayableActivation || dashboard.hasOpenPayment);
    final previous = data.previousTerms;

    return [
      if (activationDue) ...[
        _ActivationDueCard(
          packageName: dashboard.checkoutResponseModel?.data?.package?.name,
          amountText: dashboard.checkoutResponseModel?.data?.quote?.total?.formatted,
          inProgress: dashboard.hasOpenPayment,
          onTap: _openActivation,
        ),
        SizedBox(height: 16.h),
      ],
      if (current == null)
        SubscriptionMessageView(
          icon: Icons.workspace_premium_outlined,
          title: 'sub_no_package_title'.tr,
          message: 'sub_no_package_message'.tr,
          actionLabel: 'sub_choose_package'.tr,
          onAction: _openPackages,
        )
      else
        CurrentSubscriptionCard(
          term: current,
          canRenew: data.canRenew,
          renewalBlocker: data.renewalBlocker,
          isRenewing: provider.isRenewing,
          isCancelling: provider.isCancelling,
          onChangePackage: _openPackages,
          onRenew: _renew,
          onCancel: () => _cancel(current.displayName),
        ),
      if (previous.isNotEmpty) ...[
        SizedBox(height: 22.h),
        PreviousTermsSection(terms: previous),
      ],
    ];
  }
}

/// "Complete your activation" call-to-action shown above the plan.
class _ActivationDueCard extends StatelessWidget {
  final String? packageName;
  final String? amountText;
  final bool inProgress;
  final VoidCallback onTap;

  const _ActivationDueCard({
    required this.packageName,
    required this.amountText,
    required this.inProgress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final details = [packageName, amountText].whereType<String>().join(' · ');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColorsTheme.heroGradient(context)),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  inProgress ? Icons.sync_rounded : Icons.lock_open_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (inProgress ? 'Activation payment in progress' : 'Complete your activation').tr,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    if (details.isNotEmpty)
                      Text(
                        details,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.5.sp, color: Colors.white.withValues(alpha: 0.9)),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22.sp),
            ],
          ),
        ),
      ),
    );
  }
}
