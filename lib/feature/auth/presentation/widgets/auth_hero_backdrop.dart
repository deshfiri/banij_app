import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/color.dart';

/// Hero gradient (orange / slate in dark mode) behind the top of an auth
/// screen, with soft decorative circles. Use inside a [Stack]; content can
/// overlap its rounded bottom edge. [height] is below the status bar.
class AuthHeroBackdrop extends StatelessWidget {
  final double height;

  const AuthHeroBackdrop({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.paddingOf(context).top + height,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColorsTheme.heroGradient(context),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(40.r)),
        ),
        child: Stack(
          children: [
            _circle(top: -50.h, right: -40.w, size: 170.w, alpha: 0.12),
            _circle(top: 70.h, left: -36.w, size: 110.w, alpha: 0.10),
            _circle(bottom: 30.h, right: 40.w, size: 18.w, alpha: 0.35),
            _circle(bottom: 60.h, left: 50.w, size: 10.w, alpha: 0.4),
          ],
        ),
      ),
    );
  }

  static Widget _circle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double alpha,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha)),
      ),
    );
  }
}
