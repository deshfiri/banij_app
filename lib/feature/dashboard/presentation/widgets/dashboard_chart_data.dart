import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../constants/color.dart';
import '../../model/dashboard_model.dart';

/// One labelled amount from the dashboard spend API (a month or a category).
class ChartEntry {
  final String label;
  final String formatted;
  final double value;

  const ChartEntry({
    required this.label,
    required this.formatted,
    required this.value,
  });
}

/// Parsing and formatting helpers shared by the dashboard charts and hero cards.
class DashboardChartData {
  DashboardChartData._();

  static const String currency = '৳';

  /// Slice / legend colors; each entry keeps the same color in the pie and its legend.
  static const List<Color> palette = [
    primaryOrange,
    successGreen,
    infoBlue,
    purpleAccent,
    bkashPink,
    warningYellow,
    errorRed,
    textMuted,
  ];

  static Color colorAt(int index) => palette[index % palette.length];

  /// Monthly paid amounts (first series) for the line chart.
  static List<ChartEntry> monthlyPaid(SpendModel? spend) {
    final series = spend?.series;
    if (series == null || series.isEmpty) return const [];
    final first = series.first;
    return first is Map ? _parse(first['points']) : const [];
  }

  /// Category breakdown for the pie chart.
  static List<ChartEntry> breakdown(SpendModel? spend) => _parse(spend?.breakdown);

  static List<ChartEntry> _parse(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((item) {
      final formatted = (item['formatted'] ?? item['amount'] ?? '${currency}0').toString();
      return ChartEntry(
        label: item['label']?.toString() ?? '',
        formatted: formatted,
        value: parseAmount(formatted),
      );
    }).toList();
  }

  static double parseAmount(String text) {
    final value = double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    return math.max(0, value);
  }

  /// Formats the API's `spend.total`, which may be a map, a number or a string.
  static String formatTotal(dynamic total) {
    if (total == null) return '';
    if (total is Map) {
      final formatted = total['formatted']?.toString();
      if (formatted != null && formatted.isNotEmpty && !_isPlaceholder(formatted)) return formatted;
      final amount = total['amount']?.toString();
      return amount == null || amount.isEmpty ? '' : _withCurrency(amount);
    }
    final text = total.toString();
    return _isPlaceholder(text) ? '' : _withCurrency(text);
  }

  // Guards against the API returning an unformatted template/map string.
  static bool _isPlaceholder(String text) => text.contains('{') || text.contains('amount');

  static String _withCurrency(String amount) => amount.startsWith(currency) ? amount : '$currency$amount';

  /// Short axis label, e.g. 1200 -> 1.2k.
  static String compact(double value) {
    if (value >= 1000000) return '${_trim(value / 1000000)}M';
    if (value >= 1000) return '${_trim(value / 1000)}k';
    return value.toInt().toString();
  }

  static String _trim(double v) => v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1);

  /// Rounds the chart ceiling up to a readable number with ~20% headroom.
  static double niceMaxY(Iterable<double> values) {
    final max = values.isEmpty ? 0.0 : values.reduce(math.max);
    if (max <= 0) return 100;
    final raw = max * 1.2;
    final magnitude = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final step = magnitude / 2;
    return (raw / step).ceil() * step;
  }
}
