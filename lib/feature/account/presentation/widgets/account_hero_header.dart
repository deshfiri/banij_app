import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/status_pill_widget.dart';
import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../networks/api_access.dart';
import '../../../dashboard/model/current_user_model.dart';

/// Dashboard-style hero for the Account tab: back or menu button, white logo,
/// notifications button, and a profile summary (avatar, name, email, status).
class AccountHeroHeader extends StatelessWidget {
  /// Shown on the left when set (back takes priority over menu).
  final VoidCallback? onBack;
  final VoidCallback? onOpenDrawer;
  final VoidCallback onNotifications;

  /// Used when the current-user stream has no data yet.
  final String fallbackName;
  final String fallbackEmail;

  const AccountHeroHeader({
    super.key,
    required this.onNotifications,
    required this.fallbackName,
    required this.fallbackEmail,
    this.onBack,
    this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final leading = onBack != null
        ? _GlassIconButton(icon: Icons.arrow_back_rounded, onTap: onBack!)
        : (onOpenDrawer != null ? _GlassIconButton(icon: Icons.menu_rounded, onTap: onOpenDrawer!) : null);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColorsTheme.heroGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.35) : primaryOrange.withValues(alpha: 0.28),
            blurRadius: 18.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 20.h),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(width: double.infinity, height: 40),
                  Image.asset(whiteLogo, width: 105.w, height: 34.h, fit: BoxFit.contain),
                  if (leading != null) Positioned(left: 0, child: leading),
                  Positioned(
                    right: 0,
                    child: _GlassIconButton(icon: Icons.notifications_none_rounded, onTap: onNotifications, showDot: true),
                  ),
                ],
              ),
              UIHelper.verticalSpace(16.h),
              StreamBuilder(
                stream: currentUserRxObj.getCurrentUserData,
                builder: (context, snapshot) {
                  final user = snapshot.data is CurrentUserModel ? (snapshot.data as CurrentUserModel).data : null;
                  final name = _firstNonEmpty([user?.name, fallbackName]);
                  final email = _firstNonEmpty([user?.email, fallbackEmail]);
                  final status = user?.businessAccount?.status;
                  return _ProfileSummary(name: name, email: email, status: status);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }
}

class _ProfileSummary extends StatelessWidget {
  final String? name;
  final String? email;
  final String? status;

  const _ProfileSummary({this.name, this.email, this.status});

  @override
  Widget build(BuildContext context) {
    final initial = (name == null || name!.isEmpty) ? null : name!.characters.first.toUpperCase();

    return Row(
      children: [
        Container(
          width: 52.w,
          height: 52.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8.r, offset: const Offset(0, 3))],
          ),
          child: initial == null
              ? Icon(Icons.person_rounded, color: primaryOrange, size: 26.sp)
              : Text(initial, style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w900, color: primaryOrange)),
        ),
        UIHelper.horizontalSpace(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name ?? '—',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              if (email != null) ...[
                UIHelper.verticalSpace(2.h),
                Text(
                  email!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5.sp, color: Colors.white.withValues(alpha: 0.85)),
                ),
              ],
            ],
          ),
        ),
        if (status != null && status!.isNotEmpty) ...[
          UIHelper.horizontalSpace(8.w),
          StatusPillWidget(label: status!.toLowerCase().tr.capitalizeFirst ?? status!),
        ],
      ],
    );
  }
}

/// Translucent round button on the hero gradient, with an optional dot badge.
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  const _GlassIconButton({required this.icon, required this.onTap, this.showDot = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
          if (showDot)
            Positioned(
              top: 1.h,
              right: 1.w,
              child: Container(
                width: 9.w,
                height: 9.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryOrange, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
