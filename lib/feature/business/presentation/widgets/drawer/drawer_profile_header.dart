import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../common_widget/status_pill_widget.dart';
import '../../../../../constants/color.dart';
import '../../../../../constants/image_const.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../networks/api_access.dart';
import '../../../../dashboard/model/current_user_model.dart';

/// Hero-style header: logo, business avatar, business name, email and status.
/// Reads the signed-in user from the shared current-user stream.
class DrawerProfileHeader extends StatelessWidget {
  const DrawerProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder(
      stream: currentUserRxObj.getCurrentUserData,
      builder: (context, snapshot) {
        final user = snapshot.data is CurrentUserModel ? (snapshot.data as CurrentUserModel).data : null;
        final business = user?.businessAccount;
        final title = _firstNonEmpty([business?.name, user?.name]);
        final subtitle = _firstNonEmpty([user?.email, user?.mobile]);
        final status = business?.status;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColorsTheme.heroGradient(context),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.3) : primaryOrange.withValues(alpha: 0.25),
                blurRadius: 16.r,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(whiteLogo, width: 96.w, height: 30.h, fit: BoxFit.contain),
              UIHelper.verticalSpace(16.h),
              Row(
                children: [
                  _BusinessAvatar(name: title),
                  UIHelper.horizontalSpace(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title ?? '—',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          UIHelper.verticalSpace(2.h),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (status != null && status.isNotEmpty) ...[
                UIHelper.verticalSpace(12.h),
                StatusPillWidget(label: status.toLowerCase().tr.capitalizeFirst ?? status),
              ],
            ],
          ),
        );
      },
    );
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }
}

/// White circle with the business initial (or a shop icon when unknown).
class _BusinessAvatar extends StatelessWidget {
  final String? name;

  const _BusinessAvatar({this.name});

  @override
  Widget build(BuildContext context) {
    final initial = (name == null || name!.isEmpty) ? null : name!.characters.first.toUpperCase();

    return Container(
      width: 44.w,
      height: 44.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: initial == null
          ? Icon(Icons.storefront_rounded, color: primaryOrange, size: 22.sp)
          : Text(
              initial,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: primaryOrange,
              ),
            ),
    );
  }
}
