import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/status_pill_widget.dart';
import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../finance/presentation/invoices_receipts_screen.dart';
import '../../model/dashboard_model.dart';
import 'dashboard_chart_data.dart';
import 'hero_metric_card_widget.dart';

/// Orange (light) / slate (dark) header: top bar, greeting, standing badge,
/// wallet balance and total paid cards.
class DashboardHeroHeaderWidget extends StatelessWidget {
  final DashboardDataModel? data;
  final String fallbackName;
  final VoidCallback? onOpenDrawer;
  final VoidCallback onProfileTap;

  const DashboardHeroHeaderWidget({
    super.key,
    required this.data,
    required this.fallbackName,
    required this.onProfileTap,
    this.onOpenDrawer,
  });

  // Greeting text per period; the English text is also the translation key.
  static const Map<String, String> _greetings = {
    'morning': 'Good morning',
    'afternoon': 'Good afternoon',
    'evening': 'Good evening',
  };

  /// Uses the API's period when it is one we can translate, otherwise the device clock.
  String _greeting() {
    var period = data?.greeting?.period?.toLowerCase();
    if (!_greetings.containsKey(period)) {
      final hour = DateTime.now().hour;
      period = hour < 12 ? 'morning' : (hour < 17 ? 'afternoon' : 'evening');
    }
    final name = data?.greeting?.name ?? fallbackName;
    final hello = _greetings[period]!.tr;
    return name.isEmpty ? hello : '$hello, $name';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusLabel = data?.standing?.label;
    final walletAmount = data?.walletUsable?.formatted;
    final totalPaid = DashboardChartData.formatTotal(data?.spend?.total);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColorsTheme.heroGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : primaryOrange.withValues(alpha: 0.28),
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
              _buildTopBar(context),
              UIHelper.verticalSpace(10.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _greeting(),
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (statusLabel != null && statusLabel.isNotEmpty)
                    StatusPillWidget(label: statusLabel.tr),
                ],
              ),
              UIHelper.verticalSpace(16.h),
              Row(
                children: [
                  Expanded(
                    child: HeroMetricCardWidget(
                      title: 'Wallet balance'.tr,
                      amount: _orDash(walletAmount),
                      iconPath: walletIconAsset,
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.walletScreen),
                    ),
                  ),
                  UIHelper.horizontalSpace(10.w),
                  Expanded(
                    child: HeroMetricCardWidget(
                      title: 'Total paid'.tr,
                      amount: _orDash(totalPaid),
                      iconPath: paidMediaIconAsset,
                      onTap: () => InvoicesReceiptsScreen.open(
                        context,
                        initialTab: 'Receipts',
                      ),
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

  // Placeholder while the amount is loading or missing.
  static String _orDash(String? value) =>
      (value == null || value.isEmpty) ? '—' : value;

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _HeaderIconButton(
          icon: Icons.menu_rounded,
          size: 24.sp,
          onPressed: onOpenDrawer,
        ),
        Image.asset(whiteLogo, width: 105.w, height: 34.h, fit: BoxFit.contain),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HeaderIconButton(
              icon: Icons.notifications_none_rounded,
              onPressed: () =>
                  Navigator.pushNamed(context, Routes.notificationScreen),
            ),
            _HeaderIconButton(
              icon: Icons.person_outline_rounded,
              onPressed: onProfileTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double? size;

  const _HeaderIconButton({required this.icon, this.onPressed, this.size});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: size ?? 22.sp),
    );
  }
}
