import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import 'dashboard_chart_data.dart';

/// Expense breakdown donut with legend. Sweeps in with [animation];
/// tapping a slice enlarges it and shows its share in the center.
class ExpensePieChartWidget extends StatefulWidget {
  final List<ChartEntry> entries;
  final Animation<double> animation;

  const ExpensePieChartWidget({
    super.key,
    required this.entries,
    required this.animation,
  });

  @override
  State<ExpensePieChartWidget> createState() => _ExpensePieChartWidgetState();
}

class _ExpensePieChartWidgetState extends State<ExpensePieChartWidget> {
  static double get _sliceRadius => 16.r;
  static double get _touchedSliceRadius => 21.r;

  int _touchedIndex = -1;

  double get _total => widget.entries.fold(0, (sum, e) => sum + e.value);

  @override
  void didUpdateWidget(covariant ExpensePieChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldValues = oldWidget.entries.map((e) => e.value).toList();
    final newValues = widget.entries.map((e) => e.value).toList();
    if (!listEquals(oldValues, newValues)) _touchedIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 96.w,
            height: 96.w,
            child: AnimatedBuilder(
              animation: widget.animation,
              builder: (context, _) => _buildPie(context),
            ),
          ),
        ),
        UIHelper.verticalSpace(8.h),
        for (int i = 0; i < widget.entries.length; i++)
          _PieLegendRow(
            entry: widget.entries[i],
            color: DashboardChartData.colorAt(i),
          ),
      ],
    );
  }

  Widget _buildPie(BuildContext context) {
    // Clamp so the sweep remainder never divides by zero.
    final progress = math.max(widget.animation.value, 0.001);
    final total = _total;
    final sections = <PieChartSectionData>[];
    final sectionToEntry = <int>[]; // drawn section index -> entry index (-1 = filler)

    if (total <= 0) {
      // No spend yet: neutral ring instead of fake equal slices.
      sections.add(_section(AppColorsTheme.borderColor(context), 1));
      sectionToEntry.add(-1);
    } else {
      for (int i = 0; i < widget.entries.length; i++) {
        final value = widget.entries[i].value;
        if (value <= 0) continue;
        sections.add(_section(DashboardChartData.colorAt(i), value, touched: i == _touchedIndex));
        sectionToEntry.add(i);
      }
    }

    // Sweep-in: an invisible remainder that shrinks to zero as the animation runs.
    if (progress < 1) {
      final drawn = total <= 0 ? 1.0 : total;
      sections.add(_section(Colors.transparent, drawn * (1 - progress) / progress));
      sectionToEntry.add(-1);
    }

    final visibleSlices = sectionToEntry.where((i) => i >= 0).length;
    final hasTouched = total > 0 && _touchedIndex >= 0 && _touchedIndex < widget.entries.length;

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          swapAnimationDuration: Duration.zero,
          PieChartData(
            startDegreeOffset: -90,
            sectionsSpace: visibleSlices > 1 ? 2 : 0,
            centerSpaceRadius: 24.r,
            sections: sections,
            pieTouchData: PieTouchData(
              touchCallback: (event, response) {
                final index = response?.touchedSection?.touchedSectionIndex ?? -1;
                final next = event.isInterestedForInteractions && index >= 0 && index < sectionToEntry.length
                    ? sectionToEntry[index]
                    : -1;
                if (next != _touchedIndex) setState(() => _touchedIndex = next);
              },
            ),
          ),
        ),
        if (hasTouched)
          Text(
            '${(widget.entries[_touchedIndex].value / total * 100).round()}%',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              color: DashboardChartData.colorAt(_touchedIndex),
            ),
          ),
      ],
    );
  }

  PieChartSectionData _section(Color color, double value, {bool touched = false}) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: '',
      radius: touched ? _touchedSliceRadius : _sliceRadius,
      borderSide: touched
          ? BorderSide(color: Colors.white.withValues(alpha: 0.9), width: 1.5)
          : const BorderSide(color: Colors.transparent, width: 0),
    );
  }
}

class _PieLegendRow extends StatelessWidget {
  final ChartEntry entry;
  final Color color;

  const _PieLegendRow({required this.entry, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          UIHelper.horizontalSpace(4.w),
          Expanded(
            child: Text(
              entry.label.tr,
              style: TextStyle(
                fontSize: 8.5.sp,
                fontWeight: FontWeight.w600,
                color: AppColorsTheme.textMainColor(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            entry.formatted,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
