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

class _BrandColors {
  static const Color primaryOrange = Color(0xFFFF6900);
  static const Color secondaryOrange = Color(0xFFFF8A3D);
  static const Color background = Color(0xFFFFFAF7);
  static const Color primaryText = Color(0xFF151D32);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color border = Color(0xFFFFE1D0);
  static const Color blue = Color(0xFF1595DC);
  static const Color green = Color(0xFF10B981);
  static const Color purple = Color(0xFF9257F6);
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
                          userName,
                          style: TextStyle(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : _BrandColors.primaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      UIHelper.horizontalSpace(4.w),
                      Text('👏', style: TextStyle(fontSize: 17.sp)),
                    ],
                  ),
                  UIHelper.verticalSpace(4.h),
                  Text(
                    'Manage your business with ease',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF9CA3AF) : _BrandColors.secondaryText,
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
                  painter: _MetricCardWavePainter(color: color),
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
                            color: isDark ? Colors.white : _BrandColors.primaryText,
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
                            color: isDark ? const Color(0xFF9CA3AF) : _BrandColors.secondaryText,
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
        'color': _BrandColors.primaryOrange,
        'bg': const Color(0xFFFFF0E8),
        'onTap': () => ProductCategoryDetailSheet.show(context, 'hub_products'.tr, isCatalog: true),
      },
      {
        'title': 'Sales & Orders',
        'icon': Icons.shopping_cart_rounded,
        'color': _BrandColors.blue,
        'bg': const Color(0xFFEDF6FF),
        'onTap': () => OrderCategoryDetailSheet.show(context, 'hub_all_orders'.tr),
      },
      {
        'title': 'Finance',
        'icon': Icons.analytics_rounded,
        'color': _BrandColors.green,
        'bg': const Color(0xFFEFFFF6),
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
                      color: _BrandColors.primaryOrange,
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
                        color: _BrandColors.primaryOrange,
                      ),
                    ),
                    UIHelper.horizontalSpace(2.w),
                    Icon(Icons.arrow_forward_rounded, color: _BrandColors.primaryOrange, size: 14.sp),
                  ],
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(12.h),
          SizedBox(
            height: 118.h,
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
                      borderRadius: BorderRadius.circular(22.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 6.w),
                        decoration: BoxDecoration(
                          color: isDark ? AppColorsTheme.cardBg(context) : bg,
                          borderRadius: BorderRadius.circular(22.r),
                          border: Border.all(
                            color: isDark ? const Color(0xFF374151) : color.withValues(alpha: 0.2),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(11.w),
                              decoration: BoxDecoration(
                                color: isDark ? color.withValues(alpha: 0.2) : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  if (!isDark)
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.12),
                                      blurRadius: 6.r,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Icon(icon, color: color, size: 23.sp),
                            ),
                            UIHelper.verticalSpace(10.h),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : _BrandColors.primaryText,
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

  // 4. Products & My Products Full-Width Stacked Tiles matching reference screenshot
  Widget _buildFeaturedModulesList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        children: [
          // Tile 1: Products
          _buildFullWidthTileCard(
            context: context,
            title: 'Products',
            subtitle: 'Manage your catalog',
            iconData: Icons.inventory_2_rounded,
            iconColor: _BrandColors.primaryOrange,
            iconBg: const Color(0xFFFFF0E8),
            isDark: isDark,
            onTap: () => ProductCategoryDetailSheet.show(context, 'hub_products'.tr, isCatalog: true),
          ),
          UIHelper.verticalSpace(12.h),

          // Tile 2: My Products
          _buildFullWidthTileCard(
            context: context,
            title: 'My Products',
            subtitle: 'Your uploaded products',
            iconData: Icons.cloud_upload_rounded,
            iconColor: _BrandColors.purple,
            iconBg: const Color(0xFFF7F0FF),
            isDark: isDark,
            onTap: () => ProductCategoryDetailSheet.show(context, 'hub_my_products'.tr, isCatalog: false),
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthTileCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData iconData,
    required Color iconColor,
    required Color iconBg,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isDark ? AppColorsTheme.cardBg(context) : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                blurRadius: 10.r,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDark ? iconColor.withValues(alpha: 0.15) : iconBg,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 24.sp,
                ),
              ),
              UIHelper.horizontalSpace(14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : _BrandColors.primaryText,
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF9CA3AF) : _BrandColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B),
                size: 22.sp,
              ),
            ],
          ),
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

        // Main Dashboard Body Sections
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
                            color: _BrandColors.primaryOrange,
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
                            color: _BrandColors.blue,
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
                            color: _BrandColors.green,
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
                            color: _BrandColors.purple,
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

              // Quick Access Section (3 Cards)
              _buildQuickAccessSection(context),

              // Products & My Products Full-Width Stacked List Tiles
              _buildFeaturedModulesList(context),

              UIHelper.verticalSpace(90.h),
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

class _MetricCardWavePainter extends CustomPainter {
  final Color color;

  _MetricCardWavePainter({required this.color});

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
