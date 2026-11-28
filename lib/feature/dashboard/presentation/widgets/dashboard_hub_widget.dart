import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../networks/api_access.dart';
import '../../../../providers/dashboard_provider.dart';
import '../../../finance/presentation/invoices_receipts_screen.dart';
import '../../model/current_user_model.dart';
import '../../model/dashboard_model.dart';
import '../products_screen.dart';
import 'hero_metric_card_widget.dart';
import 'quick_access_section_widget.dart';

class DashboardHubWidget extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const DashboardHubWidget({super.key, this.onOpenDrawer});

  @override
  State<DashboardHubWidget> createState() => _DashboardHubWidgetState();
}

class _DashboardHubWidgetState extends State<DashboardHubWidget> {
  CurrentUserModel? _currentUserModel;
  Timer? _chartAnimationTimer;
  int _chartTick = 0;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _chartAnimationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _chartTick++;
        });
      }
    });
  }

  @override
  void dispose() {
    _chartAnimationTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final res = await currentUserRxObj.fetchCurrentUser();
      if (mounted) {
        setState(() {
          _currentUserModel = res;
        });
      }
    } catch (error) {
      debugPrint('Dashboard current-user request failed: $error');
    }
  }

  Widget _buildIntegratedHeroHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardProvider = context.watch<DashboardProvider>();
    final model = dashboardProvider.dashboardModel;
    final greeting = model?.data?.greeting;
    final standing = model?.data?.standing;
    final walletUsable = model?.data?.walletUsable;
    final spend = model?.data?.spend;

    final userName =
        greeting?.name ?? _currentUserModel?.data?.name ?? 'Mohammad';
    final period = greeting?.period ?? 'afternoon';
    final walletFormatted = walletUsable?.formatted ?? '';
    final totalPaidFormatted = _formatSpendTotal(spend?.total);
    final statusLabel = standing?.label ?? 'Active';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [primaryOrange, secondaryOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: isDark ? 0.2 : 0.28),
            blurRadius: 18.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Integrated Top Bar (Menu Icon, Logo, Notification Bell, Profile)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: widget.onOpenDrawer,
                    icon: Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  Image.asset(
                    whiteLogo,
                    width: 105.w,
                    height: 34.h,
                    fit: BoxFit.contain,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.notificationScreen,
                          );
                        },
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 22.sp,
                            ),
                            Positioned(
                              top: -2.h,
                              right: -2.w,
                              child: Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.redAccent,
                                ),
                                child: Text(
                                  '1',
                                  style: TextStyle(
                                    fontSize: 8.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          dashboardProvider.setBottomNavIndex(4);
                        },
                        icon: Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              UIHelper.verticalSpace(10.h),

              // 2. User Greeting Row + Active Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good ${period.capitalizeFirst}, $userName',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        UIHelper.verticalSpace(2.h),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                        UIHelper.horizontalSpace(4.w),
                        Text(
                          statusLabel.tr,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpace(16.h),

              // 3. Integrated Inner Metrics Row: Wallet Balance & Total Paid Cards
              Row(
                children: [
                  Expanded(
                    child: HeroMetricCardWidget(
                      title: 'Wallet balance',
                      amount: walletFormatted,
                      iconPath: walletIconAsset,
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.walletScreen),
                    ),
                  ),
                  UIHelper.horizontalSpace(10.w),
                  Expanded(
                    child: HeroMetricCardWidget(
                      title: 'Total paid',
                      amount: totalPaidFormatted,
                      iconPath: paidMediaIconAsset,
                      onTap: () => InvoicesReceiptsScreen.open(
                        context,
                        initialTab: 'Receipts',
                      ),
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpace(12.h),

              // 4. Seated Action Buttons (Customer & Product)
            ],
          ),
        ),
      ),
    );
  }

  String _formatSpendTotal(dynamic total) {
    if (total == null) return '';
    if (total is Map) {
      final formatted = total['formatted']?.toString();
      if (formatted != null &&
          formatted.isNotEmpty &&
          !formatted.contains('amount')) {
        return formatted;
      }
      final amt = total['amount']?.toString();
      if (amt != null && amt.isNotEmpty) {
        return amt.startsWith('৳') ? amt : '৳$amt';
      }
      return '';
    }
    if (total is num) {
      return '৳$total';
    }
    final str = total.toString();
    if (str.startsWith('৳')) return str;
    if (str.contains('amount') || str.contains('{')) {
      return '';
    }
    return '৳$str';
  }

  // Analytics Dashboard Section (Side-by-Side Professional Charts Row)
  Widget _buildAnalyticsSection(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final dashboardModel = dashboardProvider.dashboardModel;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildPaidLineChartCard(context, dashboardModel)),
          UIHelper.horizontalSpace(10.w),
          Expanded(child: _buildExpenseDonutChartCard(context, dashboardModel)),
        ],
      ),
    );
  }

  Widget _buildPaidLineChartCard(BuildContext context, DashboardModel? model) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spend = model?.data?.spend;
    List<dynamic> points = [];
    if (spend?.series is List && (spend?.series as List).isNotEmpty) {
      final firstSeries = spend?.series?[0];
      if (firstSeries is Map && firstSeries['points'] is List) {
        points = firstSeries['points'] as List;
      }
    }

    List<FlSpot> spots = [];
    List<String> monthLabels = [];

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      if (pt is Map) {
        final label = pt['label']?.toString() ?? '';
        monthLabels.add(label);
        final formatted =
            pt['formatted']?.toString() ?? pt['amount']?.toString() ?? '0';
        final cleanVal = formatted.replaceAll(RegExp(r'[^0-9.]'), '');
        double val = double.tryParse(cleanVal) ?? 0.0;
        if (i == points.length - 1 && val > 0) {
          val += (5.0 * math.sin(_chartTick * 0.8));
        }
        spots.add(FlSpot(i.toDouble(), math.max(0.0, val)));
      }
    }

    double maxYVal = 160.0;
    if (spots.isNotEmpty) {
      final maxSpotY = spots.map((s) => s.y).reduce(math.max);
      maxYVal = math.max(160.0, maxSpotY * 1.25);
    }

    return Container(
      constraints: BoxConstraints(minHeight: 215.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColorsTheme.cardBg(context)
            : const Color(0xFFFFF7F2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFF374151)
              : primaryOrange.withValues(alpha: 0.25),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What you have paid'.tr,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w900,
              color: AppColorsTheme.textMainColor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          UIHelper.verticalSpace(2.h),
          Text(
            spend?.months != null
                ? 'Settled payments over the last ${spend?.months} months.'
                : 'Settled payments',
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColorsTheme.textMutedColor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          UIHelper.verticalSpace(14.h),
          if (spots.isEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.h),
              child: Center(
                child: Text(
                  'No payment history data available'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColorsTheme.textMutedColor(context),
                  ),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              height: 130.h,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColorsTheme.borderColor(context)
                          .withValues(alpha: 0.5),
                      strokeWidth: 0.8,
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28.w,
                        getTitlesWidget: (value, meta) {
                          String text = '';
                          if (value == 0) {
                            text = '৳0';
                          }
                          if (value == (maxYVal * 0.5).round()) {
                            text = '৳${(maxYVal * 0.5).toInt()}';
                          }
                          if (value == maxYVal.round()) {
                            text = '৳${maxYVal.toInt()}';
                          }
                          return Text(
                            text,
                            style: TextStyle(
                              fontSize: 8.5.sp,
                              color: AppColorsTheme.textMutedColor(context),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 20.h,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int index = value.round();
                          if (index >= 0 && index < monthLabels.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                monthLabels[index],
                                style: TextStyle(
                                  fontSize: 8.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColorsTheme.textMutedColor(context),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: math.max(1.0, (spots.length - 1).toDouble()),
                  minY: 0,
                  maxY: maxYVal,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.28,
                      gradient: LinearGradient(
                        colors: [primaryOrange, secondaryOrange],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      barWidth: 2.8.w,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 3.2.r,
                              color: primaryOrange,
                              strokeWidth: 1.5.w,
                              strokeColor: Colors.white,
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            primaryOrange.withValues(alpha: 0.35),
                            primaryOrange.withValues(alpha: 0.02),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpenseDonutChartCard(
    BuildContext context,
    DashboardModel? model,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final breakdown = model?.data?.spend?.breakdown;

    List<Map<String, dynamic>> breakdownList = [];
    if (breakdown is List && breakdown.isNotEmpty) {
      for (var item in breakdown) {
        if (item is Map) {
          final label = item['label']?.toString() ?? '';
          final formatted =
              item['formatted']?.toString() ??
              item['amount']?.toString() ??
              '৳0.00';
          final cleanVal = formatted.replaceAll(RegExp(r'[^0-9.]'), '');
          final val = double.tryParse(cleanVal) ?? 0.0;
          breakdownList.add({
            'label': label,
            'formatted': formatted,
            'value': val,
          });
        }
      }
    }

    return Container(
      constraints: BoxConstraints(minHeight: 215.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColorsTheme.cardBg(context)
            : const Color(0xFFFFF7F2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFF374151)
              : primaryOrange.withValues(alpha: 0.25),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What it went on'.tr,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w900,
              color: AppColorsTheme.textMainColor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          UIHelper.verticalSpace(2.h),
          Text(
            'Expense breakdown'.tr,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColorsTheme.textMutedColor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          UIHelper.verticalSpace(14.h),
          if (breakdownList.isEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.h),
              child: Center(
                child: Text(
                  'No expense breakdown data available'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColorsTheme.textMutedColor(context),
                  ),
                ),
              ),
            ),
          ] else ...[
            Center(
              child: SizedBox(
                width: 82.w,
                height: 82.h,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 22.r,
                    sections: List.generate(breakdownList.length, (index) {
                      final colors = [
                        primaryOrange,
                        successGreen,
                        infoBlue,
                        purpleAccent,
                      ];
                      final val = breakdownList[index]['value'] as double;
                      return PieChartSectionData(
                        color: colors[index % colors.length],
                        value: val > 0
                            ? val + (2.0 * math.sin(_chartTick * 0.8))
                            : 100,
                        title: '',
                        radius: 16.r,
                      );
                    }),
                  ),
                ),
              ),
            ),
            UIHelper.verticalSpace(8.h),
            Column(
              children: breakdownList.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final colors = [
                  primaryOrange,
                  successGreen,
                  infoBlue,
                  purpleAccent,
                ];
                final itemColor = colors[index % colors.length];

                return Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: itemColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            UIHelper.horizontalSpace(4.w),
                            Expanded(
                              child: Text(
                                item['label'].toString().tr,
                                style: TextStyle(
                                  fontSize: 8.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColorsTheme.textMainColor(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item['formatted'].toString(),
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w900,
                          color: itemColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return const QuickAccessSectionWidget();
  }

  /// Products / My Products banner art is 1059 x 594. Sizing the cards to
  /// this ratio shows the whole image on every screen width (a fixed height
  /// made BoxFit.cover crop the sides, cutting into the banner titles).
  static const double _bannerAspectRatio = 1059 / 594;

  Widget _buildFeaturedModulesList(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: AspectRatio(
              aspectRatio: _bannerAspectRatio,
              child: _buildBannerCard(
                context: context,
                imagePath: productsImage,
                buttonText: 'Products view',
                onTap: () => ProductsScreen.open(
                  context,
                  'hub_products'.tr,
                  isCatalog: true,
                ),
              ),
            ),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            flex: 1,
            child: AspectRatio(
              aspectRatio: _bannerAspectRatio,
              child: _buildBannerCard(
                context: context,
                imagePath: myProductsImage,
                buttonText: 'My Products view',
                onTap: () => ProductsScreen.open(
                  context,
                  'hub_my_products'.tr,
                  isCatalog: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCard({
    required BuildContext context,
    required String imagePath,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : primaryOrange.withValues(alpha: 0.12),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // Foreground, so the image does not paint over the border.
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isDark
                ? const Color(0xFF374151)
                : primaryOrange.withValues(alpha: 0.25),
            width: 1.w,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              // Same ratio as the card, so cover fills it without cropping.
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.medium,
            ),
            Padding(
              padding: EdgeInsets.all(7.w),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 3.h,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    buttonText,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildIntegratedHeroHeader(context),
          UIHelper.verticalSpace(12.h),

          _buildAnalyticsSection(context),

          UIHelper.verticalSpace(12.h),

          _buildQuickAccessSection(context),

          _buildFeaturedModulesList(context),
          UIHelper.verticalSpace(90.h),
        ],
      ),
    );
  }
}
