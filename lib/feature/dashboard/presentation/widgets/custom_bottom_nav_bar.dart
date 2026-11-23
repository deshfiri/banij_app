import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';

/// One tab in [CustomBottomNavBar]. [index] is what `onTap` receives.
class _NavTab {
  final int index;
  final String icon;
  final String activeIcon;
  final String labelKey;

  const _NavTab(this.index, this.icon, this.activeIcon, this.labelKey);
}

/// App bottom bar in the dashboard style: rounded card surface, orange
/// gradient pill behind the active tab's icon, and a raised orange gradient
/// "+" quick-action button in the center (index 2).
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  static const int quickActionIndex = 2;

  static const List<_NavTab> _leftTabs = [
    _NavTab(0, navHomeIcon, navHomeActiveIcon, 'dashboard'),
    _NavTab(1, navFinanceIcon, navFinanceActiveIcon, 'finance'),
  ];

  static const List<_NavTab> _rightTabs = [
    _NavTab(3, navBusinessIcon, navBusinessActiveIcon, 'business'),
    _NavTab(4, navAccountIcon, navAccountActiveIcon, 'account'),
  ];

  static const List<String> _allIconAssets = [
    navHomeIcon,
    navHomeActiveIcon,
    navFinanceIcon,
    navFinanceActiveIcon,
    navBusinessIcon,
    navBusinessActiveIcon,
    navAccountIcon,
    navAccountActiveIcon,
    navPlusIcon,
  ];

  /// Decodes every nav icon up front (cheap after the first call: images are
  /// cached), so switching tabs never shows an empty pill while a PNG loads.
  static void _precacheIcons(BuildContext context) {
    for (final asset in _allIconAssets) {
      precacheImage(AssetImage(asset), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    _precacheIcons(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget tab(_NavTab t) => Expanded(
      child: _NavItem(tab: t, isActive: currentIndex == t.index, onTap: () => onTap(t.index)),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border(
          top: BorderSide(color: isDark ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.15), width: 1.w),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.35) : primaryOrange.withValues(alpha: 0.10),
            blurRadius: 24.r,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 66.h,
          padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 4.h),
          child: Row(
            children: [
              ..._leftTabs.map(tab),
              Expanded(child: _QuickActionButton(onTap: () => onTap(quickActionIndex))),
              ..._rightTabs.map(tab),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _NavTab tab;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({required this.tab, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final inactiveColor = AppColorsTheme.textMutedColor(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      // Scales down instead of overflowing on very short/landscape screens.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              width: isActive ? 50.w : 40.w,
              height: 32.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: isActive ? const LinearGradient(colors: [primaryOrange, secondaryOrange]) : null,
                borderRadius: BorderRadius.circular(16.w),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: primaryOrange.withValues(alpha: 0.35),
                          blurRadius: 10.r,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              // Outline icon when inactive, solid icon on the gradient pill when active.
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Image.asset(
                  isActive ? tab.activeIcon : tab.icon,
                  key: ValueKey(isActive),
                  width: 19.w,
                  height: 19.w,
                  color: isActive ? Colors.white : inactiveColor,
                  excludeFromSemantics: true,
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  tab.labelKey.tr,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                    color: isActive ? primaryOrange : inactiveColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Raised circular "+" button with the brand gradient and a soft glow.
class _QuickActionButton extends StatelessWidget {
  final VoidCallback onTap;

  const _QuickActionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Transform.translate(
          offset: Offset(0, -12.h),
          child: Container(
            // .r (min of width/height scale) keeps the circle inside the 56.h row on short/wide screens.
            width: 56.r,
            height: 56.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [primaryOrange, secondaryOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: AppColorsTheme.cardBg(context), width: 4.w),
              boxShadow: [
                BoxShadow(color: primaryOrange.withValues(alpha: 0.45), blurRadius: 16.r, offset: const Offset(0, 6)),
              ],
            ),
            child: Image.asset(
              navPlusIcon,
              width: 20.w,
              height: 20.w,
              color: Colors.white,
              semanticLabel: 'Quick action'.tr,
            ),
          ),
        ),
      ),
    );
  }
}
