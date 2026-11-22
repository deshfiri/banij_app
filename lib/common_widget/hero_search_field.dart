import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';

/// Rounded search box used inside the hero header. Shows a clear button
/// while there is text; clearing calls [onChanged] with '' and [onCleared].
class HeroSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onCleared;

  const HeroSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.onSubmitted,
    this.onCleared,
  });

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10.r, offset: const Offset(0, 4)),
        ],
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMainColor(context)),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 13.sp, color: muted),
            prefixIcon: Icon(Icons.search_rounded, color: primaryOrange, size: 20.sp),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.close_rounded, color: muted, size: 18.sp),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                      onCleared?.call();
                    },
                  ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }
}

/// Square button next to [HeroSearchField] (e.g. advanced filters).
/// Shows a dot when [isActive] (filters applied).
class HeroSquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const HeroSquareButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColorsTheme.cardBg(context),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10.r, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: primaryOrange, size: 21.sp),
          ),
          if (isActive)
            Positioned(
              top: 8.w,
              right: 8.w,
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(color: primaryOrange, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }
}
