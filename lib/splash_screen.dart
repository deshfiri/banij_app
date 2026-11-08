import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'constants/app_constants.dart';
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
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _driftController;
  late AnimationController _haloController;

  late Animation<double> _scaleXAnimation;
  late Animation<double> _scaleYAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _wobbleAnimation;
  late Animation<double> _haloAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // Hide status bar during splash launch animation
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // Squash & Stretch Spring Bounce X
    _scaleXAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.4, end: 1.18).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.18, end: 0.90).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 0.90, end: 1.05).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.05, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 15),
    ]).animate(_entranceController);

    // Squash & Stretch Spring Bounce Y
    _scaleYAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.4, end: 0.82).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 0.82, end: 1.10).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 1.10, end: 0.96).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 0.96, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 15),
    ]).animate(_entranceController);

    // Fade-in opacity
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    // Slide-up entrance translation
    _slideAnimation = Tween<double>(begin: 70.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Playful rotation wobble
    _wobbleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.08), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.08, end: -0.05), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: -0.05, end: 0.03), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: 0.03, end: 0.0), weight: 20),
    ]).animate(_entranceController);

    // Halo pulse animation
    _haloAnimation = Tween<double>(begin: 20.0, end: 50.0).animate(
      CurvedAnimation(
        parent: _haloController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Start entrance animation and navigate when completely finished
    _entranceController.forward().whenComplete(() {
      _navigateToNext();
    });
  }

  void _navigateToNext() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

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

  @override
  void dispose() {
    _entranceController.dispose();
    _driftController.dispose();
    _haloController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFB5A4),
                Color(0xFFFAA18F),
                Color(0xFFDE745B),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Drifting Water park & logistics background watermark pattern
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _driftController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: DriftingWaterParkPatternPainter(
                        driftOffset: _driftController.value * 65.0,
                      ),
                    );
                  },
                ),
              ),



              // Center Ultra-Premium Content with White Logo, Squash & Stretch, Wobble & Pulsing Halo
              Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_entranceController, _haloController]),
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.diagonal3Values(
                                _scaleXAnimation.value,
                                _scaleYAnimation.value,
                                1.0,
                              )
                            ..rotateZ(_wobbleAnimation.value),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Banij Primary Logo Image with ultra-radiant pulsing halo
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.5),
                                      blurRadius: _haloAnimation.value,
                                      spreadRadius: _haloAnimation.value / 2,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFC74B30).withValues(alpha: 0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  logo,
                                  width: 210.w,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              UIHelper.verticalSpace(24.h),
                              // Subtitle text without card
                              Text(
                                'Wholesale & Supply Chain',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.95),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Cinematic Loading Indicator
              Positioned(
                bottom: 50.h,
                left: 0,
                right: 0,
                child: Center(
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SizedBox(
                      width: 30.w,
                      height: 30.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.95),
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

class DriftingWaterParkPatternPainter extends CustomPainter {
  final double driftOffset;

  DriftingWaterParkPatternPainter({required this.driftOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.085)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..style = PaintingStyle.fill;

    double spacingX = 65.0;
    double spacingY = 65.0;

    canvas.save();
    canvas.translate(0, driftOffset);

    int index = 0;
    for (double x = 20; x < size.width; x += spacingX) {
      for (double y = -spacingY; y < size.height + spacingY; y += spacingY) {
        canvas.save();
        canvas.translate(x, y);

        if (index % 4 == 0) {
          // Water drop shape
          final path = Path();
          path.moveTo(0, -9);
          path.quadraticBezierTo(9, 4, 0, 11);
          path.quadraticBezierTo(-9, 4, 0, -9);
          canvas.drawPath(path, fillPaint);
        } else if (index % 4 == 1) {
          // Wave lines
          final path = Path();
          path.moveTo(-9, 0);
          path.quadraticBezierTo(-4, -5, 0, 0);
          path.quadraticBezierTo(4, 5, 9, 0);
          canvas.drawPath(path, paint);
        } else if (index % 4 == 2) {
          // Park tree / Pine shape
          final path = Path();
          path.moveTo(0, -11);
          path.lineTo(7, 4);
          path.lineTo(3, 4);
          path.lineTo(7, 9);
          path.lineTo(-7, 9);
          path.lineTo(-3, 4);
          path.lineTo(-7, 4);
          path.close();
          canvas.drawPath(path, fillPaint);
        } else {
          // Small store box / diamond
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: 13, height: 13),
            paint,
          );
        }

        canvas.restore();
        index++;
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DriftingWaterParkPatternPainter oldDelegate) {
    return oldDelegate.driftOffset != driftOffset;
  }
}
