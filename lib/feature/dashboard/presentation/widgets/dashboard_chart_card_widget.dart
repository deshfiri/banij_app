import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import 'dashboard_card_decoration.dart';

/// Card shell for a dashboard chart: title, subtitle, then the chart.
/// [title] and [subtitle] are expected to be translated already.
/// Place it in a height-bounded parent (e.g. IntrinsicHeight row): the chart
/// expands so side-by-side cards line up.
class DashboardChartCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const DashboardChartCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 215.h),
      padding: EdgeInsets.all(14.w),
      decoration: DashboardCardDecoration.of(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
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
            subtitle,
            style: TextStyle(
              fontSize: 10.sp,
              height: 1.3,
              color: AppColorsTheme.textMutedColor(context),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          UIHelper.verticalSpace(12.h),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Centered muted message shown when a chart has no data.
class ChartEmptyState extends StatelessWidget {
  final String message;

  const ChartEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColorsTheme.textMutedColor(context),
          ),
        ),
      ),
    );
  }
}
