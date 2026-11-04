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
        border: Border(
          top: BorderSide(color: AppColorsTheme.borderColor(context), width: 1.w),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68.h,
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
                  icon: Icons.euro_symbol_rounded,
                  label: 'finance'.tr,
                  isActive: currentIndex == 1,
                ),
              ),

              // 3. Center Plush / Plus Quick Action Button
              Expanded(
                child: GestureDetector(
                  onTap: () => onTap(2),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 52.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: primaryOrange,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isDark ? primaryOrange : Colors.white,
                          width: 1.5.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryOrange.withValues(alpha: isDark ? 0.3 : 0.4),
                            blurRadius: 10.r,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 26.sp,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Active Indicator Line
          Container(
            height: 3.h,
            width: 30.w,
            decoration: BoxDecoration(
              color: isActive ? primaryOrange : Colors.transparent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(2.r),
                bottomRight: Radius.circular(2.r),
              ),
            ),
          ),
          const Spacer(),
          Icon(
            icon,
            size: 22.sp,
            color: isActive ? primaryOrange : inactiveColor,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? primaryOrange : inactiveColor,
            ),
          ),
          SizedBox(height: 6.h),
        ],
      ),
    );
  }
}
