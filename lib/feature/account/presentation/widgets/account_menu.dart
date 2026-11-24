import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common_widget/hero_page_header.dart';
import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';

/// One row of an [AccountMenuGroup].
class AccountMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;
  final bool isDanger;

  const AccountMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
    this.isDanger = false,
  });
}

/// Settings-style group: small caps heading, then a rounded card with
/// divided rows (icon box, title, subtitle, chevron).
class AccountMenuGroup extends StatelessWidget {
  final String? title;
  final List<AccountMenuItem> items;

  const AccountMenuGroup({super.key, this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = AppColorsTheme.borderColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.only(left: 6.w, bottom: 8.h),
            child: Text(
              title!.toUpperCase(),
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: AppColorsTheme.cardBg(context),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                blurRadius: 10.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) Divider(height: 1, thickness: 1, indent: 62.w, color: border),
                    _AccountMenuTile(item: items[i]),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountMenuTile extends StatelessWidget {
  final AccountMenuItem item;

  const _AccountMenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final accent = item.isDanger ? errorRed : (item.color ?? primaryOrange);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        item.onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(item.icon, size: 18.sp, color: accent),
            ),
            UIHelper.horizontalSpace(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: item.isDanger ? errorRed : AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(2.h),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.sp, height: 1.3, color: AppColorsTheme.textMutedColor(context)),
                  ),
                ],
              ),
            ),
            UIHelper.horizontalSpace(8.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: item.isDanger ? errorRed : AppColorsTheme.textMutedColor(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrollable, tablet-centred page body that leaves room at the bottom
/// (for the bottom navigation bar on the main Account page).
class AccountPageBody extends StatelessWidget {
  final Widget child;
  final double bottomPadding;

  const AccountPageBody({super.key, required this.child, this.bottomPadding = 100});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, bottomPadding.h),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: child,
        ),
      ),
    );
  }
}

/// Full screen for one Account section, opened from the Account list.
///
/// [builder] is re-run whenever [refresh] notifies, so the section keeps
/// showing the Account page's latest state (loading flags, switches, …).
class AccountSectionScreen extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Listenable refresh;
  final WidgetBuilder builder;

  const AccountSectionScreen({
    super.key,
    required this.title,
    required this.refresh,
    required this.builder,
    this.subtitle,
  });

  static Future<void> open(
    BuildContext context, {
    required String title,
    String? subtitle,
    required Listenable refresh,
    required WidgetBuilder builder,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountSectionScreen(title: title, subtitle: subtitle, refresh: refresh, builder: builder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(title: title, subtitle: subtitle),
            Expanded(
              child: SafeArea(
                top: false,
                child: AccountPageBody(
                  bottomPadding: 28,
                  child: ListenableBuilder(listenable: refresh, builder: (context, _) => builder(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
