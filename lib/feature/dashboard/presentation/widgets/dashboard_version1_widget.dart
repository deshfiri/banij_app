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

class _BrandColorsV1 {
  static const Color primaryOrange = Color(0xFFFF6900);
  static const Color secondaryOrange = Color(0xFFFF8A3D);
  static const Color background = Color(0xFFFFFAF7);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF151D32);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color border = Color(0xFFFFE1D0);
  static const Color blue = Color(0xFF1595DC);
  static const Color green = Color(0xFF10B981);
  static const Color purple = Color(0xFF9257F6);
}

class DashboardVersion1Widget extends StatefulWidget {
  final VoidCallback? onOpenDrawer;

  const DashboardVersion1Widget({
    super.key,
    this.onOpenDrawer,
  });

  @override
  State<DashboardVersion1Widget> createState() => _DashboardVersion1WidgetState();
}

class _DashboardVersion1WidgetState extends State<DashboardVersion1Widget> {
  CurrentUserModel? _currentUserModel;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
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
    final userName = _currentUserModel?.data?.name ?? 'Mohammad Hira';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Container(
        constraints: BoxConstraints(minHeight: 110.h),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2E221E), const Color(0xFF1E1E24)]
                : [_BrandColorsV1.background, _BrandColorsV1.secondaryOrange.withValues(alpha: 0.18)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : _BrandColorsV1.border,
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: _BrandColorsV1.primaryOrange.withValues(alpha: isDark ? 0.12 : 0.06),
              blurRadius: 14.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _WelcomeBannerWavePainterV1(isDark: isDark),
              ),
            ),
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
                      color: _BrandColorsV1.primaryOrange.withValues(alpha: 0.3),
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
                        color: _BrandColorsV1.primaryOrange,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF9CA3AF) : _BrandColorsV1.secondaryText,
                    ),
                  ),
                  UIHelper.verticalSpace(2.h),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          userName,
                          style: TextStyle(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : _BrandColorsV1.primaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      UIHelper.horizontalSpace(4.w),
                      Text('👏', style: TextStyle(fontSize: 17.sp)),
                    ],
                  ),
                  UIHelper.verticalSpace(2.h),
                  Text(
                    'Manage your business with ease',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF9CA3AF) : _BrandColorsV1.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color lightBg,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          constraints: BoxConstraints(minHeight: 78.h),
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isDark ? AppColorsTheme.cardBg(context) : lightBg,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.3 : 0.18),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDark ? 0.08 : 0.05),
                blurRadius: 10.r,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _MetricCardWavePainterV1(color: color),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(9.w),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Icon(icon, color: color, size: 20.sp),
                  ),
                  UIHelper.horizontalSpace(10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : _BrandColorsV1.primaryText,
                          ),
                        ),
                        UIHelper.verticalSpace(1.h),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF9CA3AF) : _BrandColorsV1.secondaryText,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: color,
                      size: 16.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final quickTiles = [
      {
        'title': 'Products',
        'icon': Icons.shopping_bag_rounded,
        'color': _BrandColorsV1.primaryOrange,
        'bg': const Color(0xFFFFF2EB),
        'onTap': () => ProductCategoryDetailSheet.show(context, 'hub_products'.tr, isCatalog: true),
      },
      {
        'title': 'Sales & Orders',
        'icon': Icons.inventory_2_rounded,
        'color': _BrandColorsV1.purple,
        'bg': const Color(0xFFF0EEFF),
        'onTap': () => OrderCategoryDetailSheet.show(context, 'hub_all_orders'.tr),
      },
      {
        'title': 'Finance',
        'icon': Icons.analytics_rounded,
        'color': _BrandColorsV1.green,
        'bg': const Color(0xFFEAFCEF),
        'onTap': () => InvoicesReceiptsSheet.show(context, initialTab: 'Invoices'),
      },
      {
        'title': 'Offers',
        'icon': Icons.percent_rounded,
        'color': const Color(0xFFEC4899),
        'bg': const Color(0xFFFFEBF3),
        'onTap': () => ProductCategoryDetailSheet.show(context, 'Offers', isCatalog: false),
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
                      color: _BrandColorsV1.primaryOrange,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  UIHelper.horizontalSpace(8.w),
                  Text(
                    'Quick Access',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : _BrandColorsV1.primaryText,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w800,
                        color: _BrandColorsV1.primaryOrange,
                      ),
                    ),
                    UIHelper.horizontalSpace(2.w),
                    Icon(Icons.arrow_forward_rounded, color: _BrandColorsV1.primaryOrange, size: 14.sp),
                  ],
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(12.h),
          SizedBox(
            height: 106.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: quickTiles.map((tile) {
                final color = tile['color'] as Color;
                final bg = tile['bg'] as Color;
                final icon = tile['icon'] as IconData;
                final title = tile['title'] as String;
                final onTap = tile['onTap'] as VoidCallback;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: isDark ? AppColorsTheme.cardBg(context) : _BrandColorsV1.cardBg,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isDark ? const Color(0xFF374151) : color.withValues(alpha: 0.18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.05),
                              blurRadius: 8.r,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(9.w),
                              decoration: BoxDecoration(
                                color: isDark ? color.withValues(alpha: 0.15) : bg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: color, size: 20.sp),
                            ),
                            UIHelper.verticalSpace(6.h),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : _BrandColorsV1.primaryText,
                                height: 1.15,
                              ),
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

  Widget _buildFeaturedModulesRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: _buildFeaturedModuleCardV1(
              context: context,
              title: 'Products',
              subtitle: 'Manage your catalog',
              buttonText: 'View Products',
              isDark: isDark,
              illustration: const _ProductsBagsIllustrationV1(),
              onPressed: () {
                ProductCategoryDetailSheet.show(
                  context,
                  'hub_products'.tr,
                  isCatalog: true,
                );
              },
            ),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: _buildFeaturedModuleCardV1(
              context: context,
              title: 'My Products',
              subtitle: 'Your uploaded products',
              buttonText: 'View My Products',
              isDark: isDark,
              illustration: const _MyProductsBoxIllustrationV1(),
              onPressed: () {
                ProductCategoryDetailSheet.show(
                  context,
                  'hub_my_products'.tr,
                  isCatalog: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedModuleCardV1({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String buttonText,
    required bool isDark,
    required Widget illustration,
    required VoidCallback onPressed,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: 145.h),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF30231E),
                  const Color(0xFF241C1A),
                ]
              : [
                  const Color(0xFFFFF8F4),
                  const Color(0xFFFFE8DC),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFF49362E)
              : const Color(0xFFFFDCCB),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6900).withValues(alpha: 0.08),
            blurRadius: 14.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -6.w,
            bottom: -6.h,
            child: SizedBox(
              width: 88.w,
              height: 88.h,
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
                child: illustration,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      color: isDark
                          ? Colors.white
                          : const Color(0xFF151D32),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFB8A69F)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpace(14.h),
              _CustomPillButtonV1(
                buttonText: buttonText,
                onPressed: onPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Container(
        constraints: BoxConstraints(minHeight: 125.h),
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF2E221E), const Color(0xFF1E1E24)]
                : [const Color(0xFFFFF2EB), const Color(0xFFFFDFD0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : _BrandColorsV1.border,
          ),
          boxShadow: [
            BoxShadow(
              color: _BrandColorsV1.primaryOrange.withValues(alpha: 0.08),
              blurRadius: 12.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Grow Your Business\nwith Banij',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColorsTheme.textMainColor(context),
                    height: 1.15,
                  ),
                ),
                UIHelper.verticalSpace(4.h),
                Text(
                  'Smart tools. Better growth.',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: AppColorsTheme.textMutedColor(context),
                  ),
                ),
                UIHelper.verticalSpace(10.h),
                _CustomPillButtonV1(
                  buttonText: 'Get Started',
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.partnerNetworkScreen);
                  },
                ),
              ],
            ),
            const _GrowthChartGraphicV1(),
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
        SliverAppBar(
          pinned: true,
          floating: true,
          snap: true,
          elevation: 1,
          backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
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
                    color: isDark ? Colors.white : _BrandColorsV1.primaryText,
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
                            color: isDark ? Colors.white : _BrandColorsV1.primaryText,
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
                        color: isDark ? Colors.white : _BrandColorsV1.primaryText,
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Active Products',
                            value: '12',
                            icon: Icons.shopping_bag_rounded,
                            color: _BrandColorsV1.primaryOrange,
                            lightBg: const Color(0xFFFFF0E8),
                            onTap: () => ProductCategoryDetailSheet.show(context, 'hub_products'.tr, isCatalog: true),
                          ),
                        ),
                        UIHelper.horizontalSpace(10.w),
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Pending Orders',
                            value: '4',
                            icon: Icons.format_list_bulleted_rounded,
                            color: _BrandColorsV1.blue,
                            lightBg: const Color(0xFFEDF6FF),
                            onTap: () => OrderCategoryDetailSheet.show(context, 'hub_orders'.tr),
                          ),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(10.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Revenue',
                            value: '৳ 45,800',
                            icon: Icons.account_balance_wallet_rounded,
                            color: _BrandColorsV1.green,
                            lightBg: const Color(0xFFEFFFF6),
                            onTap: () => InvoicesReceiptsSheet.show(context, initialTab: 'Receipts'),
                          ),
                        ),
                        UIHelper.horizontalSpace(10.w),
                        Expanded(
                          child: _buildMetricCard(
                            context: context,
                            title: 'Issued Invoices',
                            value: '8',
                            icon: Icons.receipt_long_rounded,
                            color: _BrandColorsV1.purple,
                            lightBg: const Color(0xFFF7F0FF),
                            onTap: () => InvoicesReceiptsSheet.show(context, initialTab: 'Invoices'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpace(12.h),
              _buildQuickAccessSection(context),
              _buildFeaturedModulesRow(context),
              _buildGrowthBanner(context),
              UIHelper.verticalSpace(90.h),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomPillButtonV1 extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const _CustomPillButtonV1({
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(25.r),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF6900),
                Color(0xFFFF4F00),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6900).withValues(alpha: 0.25),
                blurRadius: 8.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 13.w,
              vertical: 8.h,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      buttonText,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 13.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductsBagsIllustrationV1 extends StatelessWidget {
  const _ProductsBagsIllustrationV1();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      products3dIllustration,
      width: 88.w,
      height: 78.h,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.shopping_bag_rounded,
        color: const Color(0xFFFF6900),
        size: 44.sp,
      ),
    );
  }
}

class _MyProductsBoxIllustrationV1 extends StatelessWidget {
  const _MyProductsBoxIllustrationV1();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      myProducts3dIllustration,
      width: 88.w,
      height: 78.h,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.grid_view_rounded,
        color: const Color(0xFFFF6900),
        size: 44.sp,
      ),
    );
  }
}

class _GrowthChartGraphicV1 extends StatelessWidget {
  const _GrowthChartGraphicV1();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86.w,
      height: 64.h,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(width: 11.w, height: 20.h, decoration: BoxDecoration(color: const Color(0xFFFFAB91), borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)))),
              UIHelper.horizontalSpace(3.w),
              Container(width: 11.w, height: 32.h, decoration: BoxDecoration(color: const Color(0xFFFF7043), borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)))),
              UIHelper.horizontalSpace(3.w),
              Container(width: 11.w, height: 44.h, decoration: BoxDecoration(color: const Color(0xFFF4511E), borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)))),
              UIHelper.horizontalSpace(3.w),
              Container(width: 11.w, height: 58.h, decoration: BoxDecoration(color: const Color(0xFFD84315), borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)))),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Icon(Icons.north_east_rounded, color: _BrandColorsV1.primaryOrange, size: 32.sp),
          ),
        ],
      ),
    );
  }
}

class _WelcomeBannerWavePainterV1 extends CustomPainter {
  final bool isDark;

  _WelcomeBannerWavePainterV1({required this.isDark});

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

class _MetricCardWavePainterV1 extends CustomPainter {
  final Color color;

  _MetricCardWavePainterV1({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.4, size.height)
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.55,
        size.width,
        size.height * 0.65,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
