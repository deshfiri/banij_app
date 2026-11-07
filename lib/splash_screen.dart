import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'constants/app_constants.dart';
import 'constants/color.dart';
import 'constants/image_const.dart';
import 'helpers/all_routes.dart';
import 'helpers/di.dart';
import 'helpers/ui_helpers.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _scale = 0.7;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Hide status bar during splash launch animation
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );

    // Trigger Logo scale & opacity animation
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _scale = 1.0;
          _opacity = 1.0;
        });
      }
    });

    // Complete splash duration then navigate cleanly
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        bool isLoggedIn = appData.read(kKeyIsLoggedIn) ?? false;
        Navigator.pushReplacementNamed(
          context,
          isLoggedIn ? Routes.dashboardScreen : Routes.onboardingScreen,
        );
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      const Color(0xFF1E130B),
                      darkBackground,
                      const Color(0xFF0D0907),
                    ]
                  : [
                      const Color(0xFFFF8533),
                      const Color(0xFFFD6B04),
                      const Color(0xFFD15300),
                    ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative background glow circles
              Positioned(
                top: -60.h,
                right: -60.w,
                child: Container(
                  width: 200.w,
                  height: 200.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.12),
                  ),
                ),
              ),
              Positioned(
                bottom: -40.h,
                left: -40.w,
                child: Container(
                  width: 180.w,
                  height: 180.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.1),
                  ),
                ),
              ),

              // Center Branded Content
              Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 900),
                  opacity: _opacity,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 900),
                    scale: _scale,
                    curve: Curves.easeOutBack,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Container with Soft Glow
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 24.r,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            whiteLogo,
                            width: 150.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                        UIHelper.verticalSpace(18.h),
                        Text(
                          'Wholesale & Supply Chain',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Loader Indicator
              Positioned(
                bottom: 50.h,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 800),
                    opacity: _opacity,
                    child: SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
