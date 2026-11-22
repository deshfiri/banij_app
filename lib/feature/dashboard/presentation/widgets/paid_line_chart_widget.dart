import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/color.dart';
import 'dashboard_chart_data.dart';

/// Monthly "what you have paid" line chart; grows in from zero with [animation].
class PaidLineChartWidget extends StatelessWidget {
  final List<ChartEntry> entries;
  final Animation<double> animation;

  const PaidLineChartWidget({
    super.key,
    required this.entries,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = DashboardChartData.niceMaxY(entries.map((e) => e.value));

    // A fixed height answers intrinsic queries (LineChart can't); inside the
    // card's Expanded the parent's tight constraints still stretch it to fill.
    return SizedBox(
      height: 130.h,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) => LineChart(
          duration: Duration.zero,
          _chartData(context, maxY, animation.value),
        ),
      ),
    );
  }

  LineChartData _chartData(BuildContext context, double maxY, double progress) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = AppColorsTheme.textMutedColor(context);
    final axisStyle = TextStyle(fontSize: 8.5.sp, color: mutedColor);

    return LineChartData(
      minX: 0,
      maxX: math.max(1, entries.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: maxY / 2,
        getDrawingHorizontalLine: (_) => FlLine(
          color: AppColorsTheme.borderColor(context).withValues(alpha: 0.5),
          strokeWidth: 0.8,
          dashArray: const [4, 4],
        ),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30.w,
            interval: maxY / 2,
            getTitlesWidget: (value, _) => Text(
              '${DashboardChartData.currency}${DashboardChartData.compact(value)}',
              style: axisStyle,
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 20.h,
            interval: 1,
            getTitlesWidget: (value, _) {
              final index = value.round();
              if (index < 0 || index >= entries.length) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  entries[index].label,
                  style: axisStyle.copyWith(fontWeight: FontWeight.w600),
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          tooltipRoundedRadius: 8.r,
          getTooltipColor: (_) => isDark ? AppColorsTheme.innerCardBg(context) : textMain,
          // Show the API's formatted amount, not the animated y value.
          getTooltipItems: (spots) => spots
              .map((spot) => LineTooltipItem(
                    entries[spot.x.round()].formatted,
                    TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.white),
                  ))
              .toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (int i = 0; i < entries.length; i++) FlSpot(i.toDouble(), entries[i].value * progress),
          ],
          isCurved: true,
          curveSmoothness: 0.28,
          preventCurveOverShooting: true,
          gradient: const LinearGradient(colors: [primaryOrange, secondaryOrange]),
          barWidth: 2.8.w,
          isStrokeCapRound: true,
          dotData: FlDotData(
            getDotPainter: (_, _, _, _) => FlDotCirclePainter(
              radius: 3.2.r * progress,
              color: primaryOrange,
              strokeWidth: 1.5.w,
              strokeColor: isDark ? AppColorsTheme.cardBg(context) : Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                primaryOrange.withValues(alpha: isDark ? 0.25 : 0.35),
                primaryOrange.withValues(alpha: 0.02),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
