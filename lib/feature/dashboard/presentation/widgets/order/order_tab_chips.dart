import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';

/// Segmented order type switcher styled like invoice tabs.
class OrderTabChips extends StatelessWidget {
  final String selectedTypeTab;
  final Function(String type) onTabChanged;

  const OrderTabChips({
    super.key,
    required this.selectedTypeTab,
    required this.onTabChanged,
  });

  /// (type sent to the API, chip label key).
  static const List<(String, String)> _tabs = [
    ('all', 'All Orders'),
    ('store', 'Store Orders'),
    ('stores', 'Connected Stores'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 38.h,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppColorsTheme.innerCardBg(context),
          borderRadius: BorderRadius.circular(19.r),
        ),
        child: Row(
          children: [
            for (final (value, label) in _tabs)
              Expanded(
                child: GestureDetector(
                  onTap: () => onTabChanged(value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: selectedTypeTab == value
                          ? primaryOrange
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(17.r),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label.tr,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: selectedTypeTab == value
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: selectedTypeTab == value
                              ? Colors.white
                              : AppColorsTheme.textMutedColor(context),
                        ),
                      ),
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
