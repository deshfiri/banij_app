import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/color.dart';

/// One tab in [CustomBottomNavBar]. [index] is what `onTap` receives.
class _NavTab {
  final int index;
  final IconData icon;
  final IconData activeIcon;
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
    _NavTab(0, Icons.home_outlined, Icons.home_rounded, 'dashboard'),
    _NavTab(1, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'finance'),
  ];

  static const List<_NavTab> _rightTabs = [
    _NavTab(3, Icons.business_center_outlined, Icons.business_center_rounded, 'business'),
    _NavTab(4, Icons.person_outline_rounded, Icons.person_rounded, 'account'),
  ];

  @override
  Widget build(BuildContext context) {
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
        child: SizedBox(
          height: 72.h,
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
              width: isActive ? 46.w : 36.w,
              height: 30.h,
              decoration: BoxDecoration(
                gradient: isActive ? const LinearGradient(colors: [primaryOrange, secondaryOrange]) : null,
                borderRadius: BorderRadius.circular(15.r),
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
              child: Icon(
                isActive ? tab.activeIcon : tab.icon,
                size: 20.sp,
                color: isActive ? Colors.white : inactiveColor,
              ),
            ),
            SizedBox(height: 4.h),
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
          offset: Offset(0, -10.h),
          child: Container(
            width: 54.w,
            height: 54.w,
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
            child: Icon(Icons.add_rounded, color: Colors.white, size: 28.sp),
          ),
        ),
      ),
    );
  }
}
