import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../constants/image_const.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../networks/api_access.dart';
import '../../../../providers/dashboard_provider.dart';
import '../../model/current_user_model.dart';
import '../../model/dashboard_model.dart';
import 'dashboard_chart_card_widget.dart';
import 'dashboard_chart_data.dart';
import 'dashboard_hero_header_widget.dart';
import 'expense_pie_chart_widget.dart';
import 'paid_line_chart_widget.dart';
import 'product_banner_card_widget.dart';
import '../products_screen.dart';
import 'quick_access_section_widget.dart';

/// Main dashboard for approved accounts: hero header, spend charts,
/// quick access tiles and product banners.
class DashboardHubWidget extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const DashboardHubWidget({super.key, this.onOpenDrawer});

  @override
  State<DashboardHubWidget> createState() => _DashboardHubWidgetState();
}

class _DashboardHubWidgetState extends State<DashboardHubWidget> with SingleTickerProviderStateMixin {
  CurrentUserModel? _currentUser;
  late final AnimationController _chartController;
  late final Animation<double> _chartAnimation;
  String? _chartDataKey;
  int? _lastTabIndex;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _chartController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _chartAnimation = CurvedAnimation(parent: _chartController, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final user = await currentUserRxObj.fetchCurrentUser();
      if (mounted) setState(() => _currentUser = user);
    } catch (_) {
      // Name is optional; the greeting falls back to the API greeting or no name.
    }
  }

  /// Replays the chart entrance animation when the chart data changes or the
  /// user comes back to the Dashboard tab (the IndexedStack keeps this widget alive).
  void _playChartAnimationIfNeeded(SpendModel? spend, int tabIndex) {
    final key = '${spend?.series}|${spend?.breakdown}';
    final dataChanged = key != _chartDataKey;
    final returnedToTab = tabIndex == 0 && _lastTabIndex != null && _lastTabIndex != 0;
    _chartDataKey = key;
    _lastTabIndex = tabIndex;
    if (!dataChanged && !returnedToTab) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _chartController.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final data = dashboardProvider.dashboardModel?.data;
    _playChartAnimationIfNeeded(data?.spend, dashboardProvider.currentIndex);

    return SingleChildScrollView(
      child: Column(
        children: [
          DashboardHeroHeaderWidget(
            data: data,
            fallbackName: _currentUser?.data?.name ?? '',
            onOpenDrawer: widget.onOpenDrawer,
            onProfileTap: () => dashboardProvider.setBottomNavIndex(4),
          ),
          UIHelper.verticalSpace(12.h),
          _buildAnalyticsSection(data?.spend),
          UIHelper.verticalSpace(12.h),
          const QuickAccessSectionWidget(),
          _buildProductBanners(),
          UIHelper.verticalSpace(90.h),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(SpendModel? spend) {
    final monthly = DashboardChartData.monthlyPaid(spend);
    final breakdown = DashboardChartData.breakdown(spend);
    final months = spend?.months;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DashboardChartCardWidget(
                title: 'What you have paid'.tr,
                subtitle: months != null
                    ? 'Settled payments over the last @months months.'.trParams({'months': months})
                    : 'Settled payments'.tr,
                child: monthly.isEmpty
                    ? ChartEmptyState(message: 'No payment history yet'.tr)
                    : PaidLineChartWidget(entries: monthly, animation: _chartAnimation),
              ),
            ),
            UIHelper.horizontalSpace(10.w),
            Expanded(
              child: DashboardChartCardWidget(
                title: 'What it went on'.tr,
                subtitle: 'Expense breakdown'.tr,
                child: breakdown.isEmpty
                    ? ChartEmptyState(message: 'No expense breakdown yet'.tr)
                    : ExpensePieChartWidget(entries: breakdown, animation: _chartAnimation),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductBanners() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: ProductBannerCardWidget(
              imagePath: productsImage,
              buttonText: 'Products view'.tr,
              onTap: () => ProductsScreen.open(context, 'hub_products'.tr, isCatalog: true),
            ),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: ProductBannerCardWidget(
              imagePath: myProductsImage,
              buttonText: 'My Products view'.tr,
              onTap: () => ProductsScreen.open(context, 'hub_my_products'.tr, isCatalog: false),
            ),
          ),
        ],
      ),
    );
  }
}
