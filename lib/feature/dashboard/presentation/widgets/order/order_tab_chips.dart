import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';

class OrderTabChips extends StatelessWidget {
  final String selectedTypeTab;
  final Function(String type) onTabChanged;

  const OrderTabChips({
    super.key,
    required this.selectedTypeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          _buildOrderTabChip(context, 'all', 'All Orders'),
          _buildOrderTabChip(context, 'store', 'Store Orders'),
          _buildOrderTabChip(context, 'stores', 'Connected Stores'),
        ],
      ),
    );
  }

  Widget _buildOrderTabChip(BuildContext context, String value, String label) {
    final isSelected = selectedTypeTab == value;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: () => onTabChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isSelected ? primaryOrange : AppColorsTheme.cardBg(context),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isSelected ? primaryOrange : AppColorsTheme.borderColor(context),
              width: 1.w,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: primaryOrange.withValues(alpha: 0.3),
                  blurRadius: 6.r,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColorsTheme.textMainColor(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
