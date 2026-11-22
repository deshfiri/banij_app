import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';

/// Small uppercase section label ("OVERVIEW", "ACCOUNT").
class DrawerSectionLabel extends StatelessWidget {
  final String title;

  const DrawerSectionLabel({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 8.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppColorsTheme.textMutedColor(context),
        ),
      ),
    );
  }
}

enum DrawerTileStyle { normal, danger }

/// Drawer row. Selected: orange gradient pill with white content.
/// Normal: tinted icon box like the dashboard's quick access tiles.
/// Danger: red tint (logout).
class DrawerMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final DrawerTileStyle style;

  const DrawerMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
    this.style = DrawerTileStyle.normal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDanger = style == DrawerTileStyle.danger;
    final accent = isDanger ? errorRed : primaryOrange;
    final radius = BorderRadius.circular(14.r);

    final Color textColor;
    final Color iconColor;
    final Color iconBoxColor;
    if (isSelected) {
      textColor = Colors.white;
      iconColor = Colors.white;
      iconBoxColor = Colors.white.withValues(alpha: 0.2);
    } else {
      textColor = isDanger ? errorRed : AppColorsTheme.textMainColor(context);
      iconColor = accent;
      iconBoxColor = accent.withValues(alpha: isDark ? 0.16 : 0.1);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: isSelected ? const LinearGradient(colors: [primaryOrange, secondaryOrange]) : null,
              color: isSelected ? null : (isDanger ? errorRed.withValues(alpha: isDark ? 0.1 : 0.06) : null),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primaryOrange.withValues(alpha: 0.3),
                        blurRadius: 10.r,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(color: iconBoxColor, borderRadius: BorderRadius.circular(10.r)),
                  child: Icon(icon, size: 18.sp, color: iconColor),
                ),
                UIHelper.horizontalSpace(12.w),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: isSelected || isDanger ? FontWeight.w800 : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                if (!isDanger)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18.sp,
                    color: isSelected ? Colors.white : AppColorsTheme.textMutedColor(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
