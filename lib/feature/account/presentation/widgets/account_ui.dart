import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../dashboard/presentation/widgets/dashboard_card_decoration.dart';

/// Dashboard-style card with an orange accent title and optional subtitle.
class AccountSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const AccountSectionCard({super.key, required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: DashboardCardDecoration.of(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccountSectionTitle(title: title, subtitle: subtitle),
          UIHelper.verticalSpace(16.h),
          child,
        ],
      ),
    );
  }
}

/// Orange accent bar + bold title, muted subtitle below.
class AccountSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AccountSectionTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 17.h,
              decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(2.r)),
            ),
            UIHelper.horizontalSpace(8.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          UIHelper.verticalSpace(4.h),
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Text(
              subtitle!,
              style: TextStyle(fontSize: 12.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
            ),
          ),
        ],
      ],
    );
  }
}

/// Settings row in the drawer-tile style: tinted icon box, title, subtitle,
/// and a trailing switch (when [onChanged] is set) or chevron (when [onTap] is set).
/// [isDanger] renders the red logout/delete variant.
class AccountSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool? switchValue;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;
  final bool isDanger;

  const AccountSettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.switchValue,
    this.onChanged,
    this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDanger ? errorRed : primaryOrange;
    final radius = BorderRadius.circular(16.r);
    final hasSwitch = onChanged != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasSwitch ? null : onTap,
        borderRadius: radius,
        child: Ink(
          padding: EdgeInsets.fromLTRB(12.w, 12.h, hasSwitch ? 4.w : 12.w, 12.h),
          decoration: BoxDecoration(
            color: isDanger
                ? errorRed.withValues(alpha: isDark ? 0.1 : 0.06)
                : (isDark ? AppColorsTheme.innerCardBg(context) : lightBackground),
            borderRadius: radius,
            border: Border.all(
              color: isDanger
                  ? errorRed.withValues(alpha: 0.25)
                  : (isDark ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.15)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(icon, size: 19.sp, color: accent),
              ),
              UIHelper.horizontalSpace(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: isDanger ? errorRed : AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),
                    Text(
                      subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5.sp, color: AppColorsTheme.textMutedColor(context)),
                    ),
                  ],
                ),
              ),
              if (hasSwitch)
                Switch.adaptive(
                  value: switchValue ?? false,
                  activeThumbColor: primaryOrange,
                  activeTrackColor: primaryOrange.withValues(alpha: 0.3),
                  onChanged: onChanged,
                )
              else
                Icon(Icons.chevron_right_rounded, size: 20.sp, color: isDanger ? errorRed : AppColorsTheme.textMutedColor(context)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small rounded status label, e.g. "Enabled" / "Selected".
class AccountStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const AccountStatusChip({super.key, required this.label, required this.color, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: filled ? const LinearGradient(colors: [primaryOrange, secondaryOrange]) : null,
        color: filled ? null : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w800, color: filled ? Colors.white : color),
      ),
    );
  }
}
