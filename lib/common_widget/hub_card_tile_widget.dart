import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';
import '../helpers/ui_helpers.dart';

class HubCardTileWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final VoidCallback? onTap;

  const HubCardTileWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColorsTheme.cardBg(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColorsTheme.borderColor(context),
            width: 1.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top row: Icon Box & Chevron Right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECE0),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    iconData,
                    color: primaryOrange,
                    size: 22.sp,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColorsTheme.textMutedColor(context),
                  size: 20.sp,
                ),
              ],
            ),
            // Bottom texts: Title & Subtitle Tag
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                UIHelper.verticalSpace(2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColorsTheme.textMutedColor(context),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
