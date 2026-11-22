import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';
import '../helpers/ui_helpers.dart';

/// Selectable pill: orange gradient when selected, card surface otherwise.
/// [compact] gives a smaller variant for secondary rows (e.g. categories).
class PillChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  const PillChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? Colors.white : AppColorsTheme.textMainColor(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: compact ? 12.w : 14.w),
        decoration: BoxDecoration(
          gradient: isSelected ? const LinearGradient(colors: [primaryOrange, secondaryOrange]) : null,
          color: isSelected ? null : AppColorsTheme.cardBg(context),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColorsTheme.borderColor(context),
            width: 1.w,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: primaryOrange.withValues(alpha: 0.3), blurRadius: 8.r, offset: const Offset(0, 3))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14.sp, color: isSelected ? Colors.white : AppColorsTheme.textMutedColor(context)),
              UIHelper.horizontalSpace(6.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 11.sp : 12.sp,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontally scrolling row of [PillChip]s.
class PillChipBar extends StatelessWidget {
  final List<Widget> chips;
  final bool compact;

  const PillChipBar({super.key, required this.chips, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 32.h : 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: chips.length,
        separatorBuilder: (_, _) => UIHelper.horizontalSpace(8.w),
        itemBuilder: (_, index) => chips[index],
      ),
    );
  }
}
