import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';
import '../constants/image_const.dart';
import '../helpers/all_routes.dart';

class CustomHeaderAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onOpenDrawer;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const CustomHeaderAppBarWidget({
    super.key,
    this.onOpenDrawer,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        border: Border(
          bottom: BorderSide(
            color: AppColorsTheme.borderColor(context),
            width: 1.w,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 100% Dead-Centered Logo
            Center(
              child: Image.asset(
                isDark ? whiteLogo : logo,
                width: 105.w,
                height: 34.h,
                fit: BoxFit.contain,
              ),
            ),
            // Left Drawer Menu Icon
            if (onOpenDrawer != null)
              Positioned(
                left: 0,
                child: IconButton(
                  onPressed: onOpenDrawer,
                  icon: Icon(
                    Icons.menu_rounded,
                    color: AppColorsTheme.textMainColor(context),
                    size: 23.sp,
                  ),
                ),
              ),
            // Right Action Icons: Notifications & Profile
            Positioned(
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onNotificationTap ??
                        () => Navigator.pushNamed(context, Routes.notificationScreen),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          color: AppColorsTheme.textMainColor(context),
                          size: 21.sp,
                        ),
                        Positioned(
                          top: -2.h,
                          right: -2.w,
                          child: Container(
                            width: 7.w,
                            height: 7.h,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onProfileTap != null)
                    IconButton(
                      onPressed: onProfileTap,
                      icon: Icon(
                        Icons.person_outline_rounded,
                        color: AppColorsTheme.textMainColor(context),
                        size: 21.sp,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
