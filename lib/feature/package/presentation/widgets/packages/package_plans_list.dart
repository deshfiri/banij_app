import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
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
  /// Shows a "Your current plan: …" line above the cards.
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
    if (success) {
      // Keep the Subscription screen in sync.
      context.read<SubscriptionProvider>().fetchSubscription(force: true);
    }
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showCurrentPlan && currentName != null) ...[
          _CurrentPlanLine(name: currentName),
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

class _CurrentPlanLine extends StatelessWidget {
  final String name;

  const _CurrentPlanLine({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: primaryOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: primaryOrange.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_rounded, size: 18.sp, color: primaryOrange),
          UIHelper.horizontalSpace(8.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '${'pkg_your_current_plan'.tr}: ',
                children: [
                  TextSpan(
                    text: name,
                    style: TextStyle(fontWeight: FontWeight.w800, color: AppColorsTheme.textMainColor(context)),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
            ),
          ),
        ],
      ),
    );
  }
}
