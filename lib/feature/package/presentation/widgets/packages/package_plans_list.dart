import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../helpers/all_routes.dart';
import '../../../../../providers/dashboard_provider.dart';
import '../../../../../providers/packages_provider.dart';
import '../../../../../providers/subscription_provider.dart';
import '../../../model/package_model.dart';
import '../subscription/subscription_states.dart';
import 'package_plan_card.dart';

/// Name of the plan the account is on: from `/packages`, else `/subscription`.
String? currentPackageName(BuildContext context, PackageResponseModel? data) {
  if (data?.currentPackageName != null) return data!.currentPackageName;
  final slug = data?.selectedSlug ?? context.read<PackagesProvider>().lastSelection?.selectedSlug;
  if (slug != null) {
    for (final pkg in data?.data ?? const <PackageItemModel>[]) {
      if (pkg.slug == slug) return pkg.name;
    }
  }
  return context.read<SubscriptionProvider>().subscription?.current?.package;
}

/// The list of plans from `GET /packages` with the full "Choose this plan"
/// flow (confirm → `POST /packages/{slug}/select` → refresh).
///
/// Not scrollable itself, so it can sit inside any scroll view (the
/// Packages screen or Account › Package). Loads the list on first build.
class PackagePlansList extends StatefulWidget {
  /// Shows the current-plan banner and an "All plans" heading above the
  /// cards (Account › Package; the Packages screen has its own header).
  final bool showCurrentPlan;

  const PackagePlansList({super.key, this.showCurrentPlan = false});

  @override
  State<PackagePlansList> createState() => _PackagePlansListState();
}

class _PackagePlansListState extends State<PackagePlansList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PackagesProvider>().fetchPackages(force: true);
    });
  }

  Future<void> _refresh() => context.read<PackagesProvider>().fetchPackages(force: true);

  bool _isCurrent(PackageItemModel pkg, PackageResponseModel data, String? currentName) {
    if (pkg.isCurrent == true) return true;
    final selected = data.selectedSlug ?? context.read<PackagesProvider>().lastSelection?.selectedSlug;
    if (selected != null) return pkg.slug == selected;
    return currentName != null && pkg.name?.toLowerCase() == currentName.toLowerCase();
  }

  Future<void> _choose(PackageItemModel pkg) async {
    final slug = pkg.slug;
    if (slug == null || slug.isEmpty) return;
    final confirmed = await _confirm(pkg);
    if (!confirmed || !mounted) return;

    final (success, error) = await context.read<PackagesProvider>().selectPackage(slug);
    if (!mounted) return;
    _showMessage(
      success ? 'pkg_selected'.trParams({'package': pkg.name ?? ''}) : (error ?? 'pkg_select_failed'.tr),
      success,
    );
    if (!success) return;
    // Keep the Subscription screen in sync.
    context.read<SubscriptionProvider>().fetchSubscription(force: true);

    // When the chosen package has an activation fee, continue to pay it.
    final dashboard = context.read<DashboardProvider>();
    await dashboard.fetchActivationCheckout();
    if (!mounted || !dashboard.hasPayableActivation) return;
    Navigator.pushNamed(context, Routes.activationCheckoutScreen);
  }

  Future<bool> _confirm(PackageItemModel pkg) async {
    final payable = pkg.payableNow?.formatted ?? pkg.activationTotal?.formatted;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColorsTheme.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text(
          'pkg_confirm_title'.trParams({'package': pkg.name ?? ''}),
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColorsTheme.textMainColor(context)),
        ),
        content: Text(
          payable == null
              ? 'pkg_confirm_message'.tr
              : '${'pkg_confirm_message'.tr}\n\n${'pkg_payable_now'.tr}: $payable',
          style: TextStyle(fontSize: 13.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('acc_cancel'.tr, style: TextStyle(color: AppColorsTheme.textMainColor(context))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: primaryOrange),
            child: Text('pkg_choose_plan'.tr, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showMessage(String message, bool success) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        content: Text(message),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PackagesProvider>();
    final data = provider.packages;
    final currentName = currentPackageName(context, data);

    if (data == null && provider.isLoading) return const SubscriptionShimmer();
    if (data == null) {
      return SubscriptionMessageView(
        icon: Icons.cloud_off_rounded,
        title: 'pkg_error_title'.tr,
        message: provider.error ?? 'pkg_error_title'.tr,
        actionLabel: 'sub_try_again'.tr,
        onAction: _refresh,
      );
    }

    final plans = data.data ?? const <PackageItemModel>[];
    if (plans.isEmpty) {
      return SubscriptionMessageView(
        icon: Icons.inventory_2_outlined,
        title: 'pkg_empty_title'.tr,
        message: 'pkg_empty_message'.tr,
      );
    }

    final currentPlan = plans.where((pkg) => _isCurrent(pkg, data, currentName)).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showCurrentPlan) ...[
          if (currentName != null) ...[
            _CurrentPlanBanner(name: currentName, plan: currentPlan),
            UIHelper.verticalSpace(22.h),
          ],
          _PlansHeading(count: plans.length),
          UIHelper.verticalSpace(12.h),
        ],
        for (final pkg in plans) ...[
          PackagePlanCard(
            package: pkg,
            isCurrent: _isCurrent(pkg, data, currentName),
            isSelecting: provider.selectingSlug == pkg.slug,
            isDisabled: provider.isSelecting,
            onChoose: () => _choose(pkg),
          ),
          UIHelper.verticalSpace(14.h),
        ],
      ],
    );
  }
}

/// Hero-style card at the top of Account › Package: the plan the account is
/// on, with its price and validity when the plan is in the list.
class _CurrentPlanBanner extends StatelessWidget {
  final String name;
  final PackageItemModel? plan;

  const _CurrentPlanBanner({required this.name, required this.plan});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final price = plan?.fee?.formatted ?? plan?.activationTotal?.formatted;
    final days = plan?.validityDays;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColorsTheme.heroGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : primaryOrange).withValues(alpha: isDark ? 0.35 : 0.25),
            blurRadius: 16.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40.h,
            right: -30.w,
            child: _circle(130.w, 0.1),
          ),
          Positioned(
            bottom: -30.h,
            right: 60.w,
            child: _circle(70.w, 0.07),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46.w,
                      height: 46.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                      ),
                      child: Icon(Icons.workspace_premium_rounded, size: 24.sp, color: Colors.white),
                    ),
                    UIHelper.horizontalSpace(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'pkg_your_current_plan'.tr,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          UIHelper.verticalSpace(2.h),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: const BoxDecoration(color: successGreen, shape: BoxShape.circle),
                          ),
                          UIHelper.horizontalSpace(4.w),
                          Text(
                            'active'.tr,
                            style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w800, color: successGreenDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (price != null || days != null) ...[
                  UIHelper.verticalSpace(14.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      if (price != null) _GlassChip(icon: Icons.payments_outlined, text: price),
                      if (days != null)
                        _GlassChip(icon: Icons.schedule_rounded, text: '@days Days'.trParams({'days': days})),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _circle(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha)),
      );
}

class _GlassChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GlassChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.white),
          UIHelper.horizontalSpace(6.w),
          Text(text, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}

/// "All plans · 3" heading with the compare hint.
class _PlansHeading extends StatelessWidget {
  final int count;

  const _PlansHeading({required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 17.h,
              decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(2.r)),
            ),
            UIHelper.horizontalSpace(8.w),
            Text(
              'pkg_all_plans'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.horizontalSpace(8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppColorsTheme.innerCardBg(context),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColorsTheme.textMutedColor(context),
                ),
              ),
            ),
          ],
        ),
        UIHelper.verticalSpace(4.h),
        Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: Text(
            'pkg_subtitle'.tr,
            style: TextStyle(fontSize: 12.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
          ),
        ),
      ],
    );
  }
}
