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
import '../../../finance/presentation/widgets/invoices_receipts_sheet.dart';
import '../../model/current_user_model.dart';
import 'order_category_detail_sheet.dart';
import 'product_category_detail_sheet.dart';
import 'all_hub_cards_sheet.dart';
import 'summary_card_widget.dart';

class _BrandColors {
  static const Color primaryOrange = Color(0xFFFF6900);
  static const Color secondaryOrange = Color(0xFFFF8A3D);
  static const Color background = Color(0xFFFFFAF7);
  static const Color primaryText = Color(0xFF151D32);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color border = Color(0xFFFFE1D0);
}

class DashboardHubWidget extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const DashboardHubWidget({
    super.key,
    this.onOpenDrawer,
  });

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
    } catch (_) {}
  }

  Widget _buildWelcomeBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = _currentUserModel?.data?.name ?? 'Mohammad Ashraf';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Container(
        constraints: BoxConstraints(minHeight: 110.h),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2E221E), const Color(0xFF1E1E24)]
                : [_BrandColors.background, _BrandColors.secondaryOrange.withValues(alpha: 0.18)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : _BrandColors.border,
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: _BrandColors.primaryOrange.withValues(alpha: isDark ? 0.12 : 0.06),
              blurRadius: 14.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _WelcomeBannerWavePainter(isDark: isDark),
              ),
            ),
            // Right Side Emblem Card
            Positioned(
              right: 14.w,
              top: 14.h,
              bottom: 14.h,
              child: Container(
                width: 82.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 1.5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _BrandColors.primaryOrange.withValues(alpha: 0.3),
                      blurRadius: 14.r,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    banijIcon,
                    width: 48.w,
                    height: 48.h,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Text(
                      'B',
                      style: TextStyle(
                        fontSize: 38.sp,
                        fontWeight: FontWeight.w900,
                        color: _BrandColors.primaryOrange,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // User Greeting Details
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Good morning,\n $userName',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : _BrandColors.primaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(4.h),




                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Analytics Dashboard Section (Wallet/Paid Summary + Side-by-Side Charts Row)
  Widget _buildAnalyticsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // 1. Wallet Balance & Total Paid Summary Cards Row
          _buildWalletAndTotalPaidRow(context),
          UIHelper.verticalSpace(12.h),

          // 2. Side-by-Side Grid Row: Line Chart + Donut Chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildPaidLineChartCard(context),
              ),
              UIHelper.horizontalSpace(10.w),
              Expanded(
                child: _buildExpenseDonutChartCard(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletAndTotalPaidRow(BuildContext context) {
    return Row(
      children: [
        // Wallet Balance Card
        Expanded(
          flex: 1,
          child: SummaryCardWidget(
            title: 'Wallet balance'.tr,

            amount: '৳44,850.00',
            iconAsset: wallterAssets,
            onTap: () => Navigator.pushNamed(context, Routes.walletScreen),
          ),
        ),
        UIHelper.horizontalSpace(12.w),
        // Total Paid Card
        Expanded(
          flex: 1,
          child: SummaryCardWidget(
            title: 'Total paid'.tr,
            subtitle: 'Settled payments (6 mos)',
            amount: '৳150.00',
            iconAsset: financeIconAsset,
            onTap: () => InvoicesReceiptsSheet.show(context, initialTab: 'Receipts'),
          ),
        ),
      ],
    );
  }

  Widget _buildPaidLineChartCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(minHeight: 215.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: primaryOrange.withValues(alpha: 0.0),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
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
            'Settled payments'.tr,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColorsTheme.textMutedColor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          UIHelper.verticalSpace(14.h),
          SizedBox(
            height: 130.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColorsTheme.borderColor(context).withValues(alpha: 0.5),
                    strokeWidth: 0.8,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28.w,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        if (value == 0) text = '৳0';
                        if (value == 76) text = '৳76';
                        if (value == 152) text = '৳152';
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
                        const months = ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'];
                        int index = value.round();
                        if (index >= 0 && index < months.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              months[index],
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
                maxX: 5,
                minY: 0,
                maxY: 160,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 0),
                      FlSpot(1, 4.0 + (3.0 * math.sin(_chartTick * 0.7))),
                      FlSpot(2, 6.0 + (4.0 * math.cos(_chartTick * 0.6))),
                      FlSpot(3, 10.0 + (5.0 * math.sin(_chartTick * 0.8))),
                      FlSpot(4, 18.0 + (6.0 * math.cos(_chartTick * 0.5))),
                      FlSpot(5, 142.0 + (10.0 * math.sin(_chartTick * 0.9))),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.28,
                    color: primaryOrange,
                    barWidth: 2.2.w,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
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
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutCubic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseDonutChartCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainSlice = 82.0 + (8.0 * math.sin(_chartTick * 0.8));
    final subSlice = 100.0 - mainSlice;

    return Container(
      constraints: BoxConstraints(minHeight: 215.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: primaryOrange.withValues(alpha: 0.0),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
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
          Center(
            child: SizedBox(
              width: 82.w,
              height: 82.h,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 22.r,
                  sections: [
                    PieChartSectionData(
                      color: primaryOrange,
                      value: mainSlice,
                      title: '',
                      radius: 16.r,
                    ),
                    PieChartSectionData(
                      color: primaryOrange.withValues(alpha: 0.3),
                      value: subSlice,
                      title: '',
                      radius: 14.r,
                    ),
                  ],
                ),
                swapAnimationDuration: const Duration(milliseconds: 800),
                swapAnimationCurve: Curves.easeInOut,
              ),
            ),
          ),
          UIHelper.verticalSpace(12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7.w,
                    height: 7.h,
                    decoration: const BoxDecoration(
                      color: primaryOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  UIHelper.horizontalSpace(4.w),
                  Text(
                    'Wholesale'.tr,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ],
              ),
              Text(
                '৳150.00',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: primaryOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final quickTiles = [
      {
        'title': 'Products',
        'iconAsset': productIcon,
        'onTap': () => ProductCategoryDetailSheet.show(context, 'hub_products'.tr, isCatalog: true),
      },
      {
        'title': 'Order',
        'iconAsset': cartIconAsset,
        'onTap': () => OrderCategoryDetailSheet.show(context, 'hub_all_orders'.tr),
      },
      {
        'title': 'Finance',
        'iconAsset': financeIconAsset,
        'onTap': () => InvoicesReceiptsSheet.show(context, initialTab: 'Invoices'),
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  Text(
                    'Quick Access',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : _BrandColors.primaryText,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => AllHubCardsSheet.show(context),
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w800,
                        color: primaryOrange,
                      ),
                    ),
                    UIHelper.horizontalSpace(2.w),
                    Icon(Icons.arrow_forward_rounded, color: primaryOrange, size: 14.sp),
                  ],
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(10.h),
          SizedBox(
            height: 114.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: quickTiles.map((tile) {
                final iconAsset = tile['iconAsset']?.toString() ?? productIcon;
                final title = tile['title']?.toString() ?? '';
                final onTap = tile['onTap'] is VoidCallback ? tile['onTap'] as VoidCallback : () {};

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(22.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: isDark ? AppColorsTheme.cardBg(context) : const Color(0xFFFFF6F0),
                          borderRadius: BorderRadius.circular(22.r),
                          border: Border.all(
                            color: isDark ? const Color(0xFF374151) : primaryOrange.withValues(alpha: 0.22),
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
                        child: Stack(
                          children: [
                            // Arrow Pill on Top Right matching screenshot
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
                            // Center Icon & Bottom Title
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Container(
                                    padding: EdgeInsets.all(9.w),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryOrange.withValues(alpha: isDark ? 0.2 : 0.12),
                                          blurRadius: 8.r,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      iconAsset,
                                      width: 24.w,
                                      height: 24.h,
                                      fit: BoxFit.contain,
                                    ),
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
                                    color: isDark ? Colors.white : _BrandColors.primaryText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Products & My Products Banners Horizontally Side-by-Side (Flex Half-Half) in SizedBox
  Widget _buildFeaturedModulesList(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          // Banner 1: Products
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 102.h,
              child: _buildBannerCard(
                context: context,
                imagePath: productsImage,
                buttonText: 'Products view',
                onTap: () => ProductCategoryDetailSheet.show(context, 'hub_products'.tr, isCatalog: true),
              ),
            ),
          ),
          UIHelper.horizontalSpace(12.w),
          // Banner 2: My Products
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 102.h,
              child: _buildBannerCard(
                context: context,
                imagePath: myProductsImage,
                buttonText: 'My Products view',
                onTap: () => ProductCategoryDetailSheet.show(context, 'hub_my_products'.tr, isCatalog: false),
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
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : primaryOrange.withValues(alpha: 0.25),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryOrange.withValues(alpha: isDark ? 0.08 : 0.08),
              blurRadius: 8.r,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background 3D Illustration Image - BoxFit.cover to maintain natural aspect ratio
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            // Button inside Stack at bottom left over image
            Padding(
              padding: EdgeInsets.all(7.w),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    elevation: 2,
                  ),
                  child: Text(
                    buttonText,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardProvider = context.watch<DashboardProvider>();

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          pinned: true,
          floating: true,
          snap: true,
          elevation: 0,
          backgroundColor: AppColorsTheme.background(context),
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          toolbarHeight: 52.h,
          title: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Image.asset(
                  isDark ? whiteLogo : logo,
                  width: 105.w,
                  height: 34.h,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                left: 0,
                child: IconButton(
                  onPressed: widget.onOpenDrawer,
                  icon: Icon(
                    Icons.menu_rounded,
                    color: isDark ? Colors.white : _BrandColors.primaryText,
                    size: 23.sp,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.notificationScreen);
                      },
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            color: isDark ? Colors.white : _BrandColors.primaryText,
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
                        color: isDark ? Colors.white : _BrandColors.primaryText,
                        size: 21.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildWelcomeBanner(context),
              UIHelper.verticalSpace(4.h),

              _buildAnalyticsSection(context),

              UIHelper.verticalSpace(12.h),

              _buildQuickAccessSection(context),

              // Products & My Products Banners Side-by-Side (Flex Half-Half)
              _buildFeaturedModulesList(context),
              UIHelper.verticalSpace(15.h)

              
            ],
          ),
        ),
      ],
    );
  }
}

class _WelcomeBannerWavePainter extends CustomPainter {
  final bool isDark;

  _WelcomeBannerWavePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (isDark) return;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint1 = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFCC6BB).withValues(alpha: 0.5),
          const Color(0xFFFF8533).withValues(alpha: 0.85),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(size.width * 0.42, 0)
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.15,
        size.width * 0.46,
        size.height * 0.85,
        size.width * 0.7,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF7A00), Color(0xFFFF5500)],
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(size.width * 0.65, size.height)
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.35,
        size.width * 0.84,
        size.height * 0.88,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
