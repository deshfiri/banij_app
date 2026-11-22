import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/image_const.dart';
import '../../../../helpers/ui_helpers.dart';

/// Auth screens: white logo centered on the hero gradient, optional back
/// button on the left, theme + language toggles on the right.
class AuthTopBar extends StatelessWidget {
  final bool isDark;
  final bool isBengali;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLanguage;
  final VoidCallback? onBack;
  final bool showToggles;

  const AuthTopBar({
    super.key,
    required this.isDark,
    required this.isBengali,
    required this.onToggleTheme,
    required this.onToggleLanguage,
    this.onBack,
    this.showToggles = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      // Full width so the toggles pin to the screen edge, not the logo's edge.
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox(width: double.infinity),
          Image.asset(whiteLogo, width: 116.w, height: 44.h, fit: BoxFit.contain),
          if (onBack != null)
            Positioned(
              left: 0,
              child: _GlassButton(
                onTap: onBack!,
                child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18.sp),
              ),
            ),
          if (showToggles)
            Positioned(
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _GlassButton(
                    onTap: onToggleTheme,
                    child: Icon(
                      isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_outlined,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                  UIHelper.horizontalSpace(6.w),
                  _GlassButton(
                    onTap: onToggleLanguage,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.g_translate, color: Colors.white, size: 14.sp),
                        UIHelper.horizontalSpace(4.w),
                        Text(
                          isBengali ? 'বাংলা' : 'EN',
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Translucent white pill/circle for controls on the hero gradient.
class _GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;

  const _GlassButton({required this.child, required this.onTap, this.padding});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? EdgeInsets.all(7.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: child,
      ),
    );
  }
}
