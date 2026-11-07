import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../constants/color.dart';
import '../../../../providers/theme_provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        border: Border.all(
          color: AppColorsTheme.borderColor(context),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 24.r,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Dashboard Tab
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 0,
                  icon: Icons.home_filled,
                  label: 'dashboard'.tr,
                  isActive: currentIndex == 0,
                ),
              ),

              // 2. Finance Tab
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 1,
                  icon: Icons.receipt_long_rounded,
                  label: 'finance'.tr,
                  isActive: currentIndex == 1,
                ),
              ),

              // 3. Center Quick Action Button (+)
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 50.w,
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: primaryOrange,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isDark ? primaryOrange : Colors.white,
                          width: 2.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryOrange.withValues(alpha: isDark ? 0.4 : 0.5),
                            blurRadius: 14.r,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Business Tab
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 3,
                  icon: Icons.business_center_outlined,
                  label: 'business'.tr,
                  isActive: currentIndex == 3,
                ),
              ),

              // 5. Account Tab
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 4,
                  icon: Icons.person_outline_rounded,
                  label: 'account'.tr,
                  isActive: currentIndex == 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    final inactiveColor = AppColorsTheme.textMutedColor(context);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isActive
                ? primaryOrange.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22.sp,
                color: isActive ? primaryOrange : inactiveColor,
              ),
              SizedBox(height: 3.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                    color: isActive ? primaryOrange : inactiveColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
