import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';

/// Flat top bar for sub-screens (KYC, verification history, notifications,
/// change password): back arrow + bold title on the card surface with a bottom
/// border, and an optional [trailing] action on the right.
class SubScreenTopBar extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final double horizontalPadding;
  final double verticalPadding;

  const SubScreenTopBar({
    super.key,
    required this.title,
    this.trailing,
    this.horizontalPadding = 16,
    this.verticalPadding = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w, vertical: verticalPadding.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        border: Border(
          bottom: BorderSide(
            color: AppColorsTheme.borderColor(context),
            width: 1.w,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: AppColorsTheme.textMainColor(context),
              size: 22.sp,
            ),
          ),
          UIHelper.horizontalSpace(8.w),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
