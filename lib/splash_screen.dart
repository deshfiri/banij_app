import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'constants/app_constants.dart';
import 'constants/color.dart';
import 'constants/image_const.dart';
import 'helpers/all_routes.dart';
import 'helpers/di.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _scale = 0.0;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Hide status bar without triggering system immersive prompt alerts
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );

    // Trigger Logo scale & opacity animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _scale = 1.0;
          _opacity = 1.0;
        });
      }
    });

    // Complete splash duration then navigate cleanly
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        bool isLoggedIn = appData.read(kKeyIsLoggedIn) ?? false;
        Navigator.pushReplacementNamed(
          context,
          isLoggedIn ? Routes.dashboardScreen : Routes.loginScreen,
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
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Center(
          child: AnimatedOpacity(
            duration: const Duration(seconds: 1),
            opacity: _opacity,
            child: AnimatedScale(
              duration: const Duration(seconds: 1),
              scale: _scale,
              curve: Curves.easeInOut,
              child: Image.asset(
                isDark ? whiteLogo : logo,
                width: 200.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
