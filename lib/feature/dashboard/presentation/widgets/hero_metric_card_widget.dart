import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../helpers/ui_helpers.dart';

class HeroMetricCardWidget extends StatelessWidget {
  final String title;
  final String amount;
  final VoidCallback onTap;
  final String? iconPath;

  const HeroMetricCardWidget({
    super.key,
    required this.title,
    required this.amount,
    required this.onTap,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (iconPath != null) ...[
                  Container(
                    width: 24.w,
                    height: 24.w,
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      iconPath!,
                      color: Colors.white,
                      fit: BoxFit.contain,
                    ),
                  ),
                  UIHelper.horizontalSpace(6.w),
                ],
                Expanded(
                  child: Text(
                    title.tr,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpace(4.h),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
