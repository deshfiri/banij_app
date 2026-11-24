import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';
import '../helpers/ui_helpers.dart';

/// Small outlined status badge coloured by an API "tone"
/// (`success`, `danger`, `warning`, `info`, anything else = neutral).
/// Example: `ToneBadge(label: 'Active', tone: 'success')`.
class ToneBadge extends StatelessWidget {
  final String label;
  final String? tone;

  const ToneBadge({super.key, required this.label, this.tone});

  static (Color, IconData) styleFor(String? tone) => switch (tone?.toLowerCase()) {
        'success' => (const Color(0xFF10B981), Icons.check_circle_outline_rounded),
        'danger' || 'error' => (const Color(0xFFEF4444), Icons.cancel_outlined),
        'warning' => (primaryOrange, Icons.schedule_rounded),
        'info' => (const Color(0xFF3B82F6), Icons.info_outline_rounded),
        _ => (const Color(0xFF94A3B8), Icons.radio_button_checked_rounded),
      };

  @override
  Widget build(BuildContext context) {
    final (color, icon) = styleFor(tone);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          UIHelper.horizontalSpace(4.w),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
