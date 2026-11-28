import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';

/// Card with a switch for "Supplier registration mode".
class SupplierModeSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const SupplierModeSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 6.h, 6.w, 6.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: isDark ? 0.18 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.storefront_rounded, color: primaryOrange, size: 16.sp),
          ),
          UIHelper.horizontalSpace(10.w),
          Expanded(
            child: Text(
              'supplier_registration_mode'.tr,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch.adaptive(
              value: value,
              // Solid orange when on (also used by the iOS switch); the
              // off state comes from the app's switch theme.
              activeThumbColor: Colors.white,
              activeTrackColor: primaryOrange,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
