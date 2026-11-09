import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'constants/app_constants.dart';
import 'constants/color.dart';
import 'constants/image_const.dart';
import 'helpers/all_routes.dart';
import 'helpers/di.dart';
import 'helpers/ui_helpers.dart';

/// 2-Phase (White -> Primary Orange) Logo Animation Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _arcDrawController;
  late AnimationController _bgWipeController;
  late AnimationController _shimmerController;
  late AnimationController _taglineController;

  late Animation<double> _arcProgress;
  late Animation<double> _bgWipeProgress;
  late Animation<double> _logoScale;
  late Animation<double> _logoCrossFade;
  late Animation<double> _taglineOpacity;
  late Animation<double> _taglineSpacing;

  bool _hasNavigated = false;
  bool _isOrangePhase = false;

  @override
  void initState() {
    super.initState();

    // Hide status bar during splash launch
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );

    // 1. Arc Stroke Circle Draw (Phase 1 on White Canvas)
    _arcDrawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // 2. Radial Background Wipe (White -> Primary Orange)
    _bgWipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    // 3. Continuous Metallic Light Beam Sweep across White Logo
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // 4. Tagline Unmask & Letter Spacing Tracking
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Arc Stroke Rotation
    _arcProgress = CurvedAnimation(
      parent: _arcDrawController,
      curve: Curves.easeInOutCubic,
    );

    // Expanding Circle Fill Wipe Progress
    _bgWipeProgress = CurvedAnimation(
      parent: _bgWipeController,
      curve: Curves.easeInOutCubic,
    );

    // Logo Spring Entrance Scale
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 1.15)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 40,
      ),
    ]).animate(_arcDrawController);

    // Cross-fade between initial brand mark and White Logo as screen turns orange
    _logoCrossFade = CurvedAnimation(
      parent: _bgWipeController,
      curve: const Interval(0.2, 0.9, curve: Curves.easeInOut),
    );

    // Tagline Fade-in & Translation
    _taglineOpacity = CurvedAnimation(
      parent: _taglineController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    // Tagline Dynamic Letter Spacing Expansion (0.5.sp -> 2.0.sp)
    _taglineSpacing = Tween<double>(begin: 0.5, end: 2.0).animate(
      CurvedAnimation(
        parent: _taglineController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Run Animation Pipeline
    _runAnimationSequence();
  }

  Future<void> _runAnimationSequence() async {
    // Phase 1: Draw Arc Ring on White Background
    await _arcDrawController.forward();
    await Future.delayed(const Duration(milliseconds: 150));

    // Phase 2: Radial Color Fill Wipe (White -> Primary Orange)
    if (mounted) setState(() => _isOrangePhase = true);
    await _bgWipeController.forward();

    // Phase 3: Reveal Tagline on Orange Background
    await _taglineController.forward();
    await Future.delayed(const Duration(milliseconds: 400));

    _navigateToNext();
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
    _arcDrawController.dispose();
    _bgWipeController.dispose();
    _shimmerController.dispose();
    _taglineController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _isOrangePhase ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            _isOrangePhase ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // 1. Expanding Radial Color Fill Wipe (White -> Primary Orange)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bgWipeProgress,
                builder: (context, child) {
                  return CustomPaint(
                    painter: RadialColorWipePainter(
                      progress: _bgWipeProgress.value,
                      fillColor: primaryOrange,
                    ),
                  );
                },
              ),
            ),

            // 2. Center Stage (Rotating Arc Ring + Logo Morph + Shimmer Beam)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 230.w,
                    height: 230.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Arc Ring Stroke Draw
                        AnimatedBuilder(
                          animation: Listenable.merge([_arcProgress, _bgWipeProgress]),
                          builder: (context, child) {
                            return CustomPaint(
                              size: Size(220.w, 220.h),
                              painter: ArcRingPainter(
                                progress: _arcProgress.value,
                                color: _isOrangePhase ? Colors.white : primaryOrange,
                              ),
                            );
                          },
                        ),

                        // Logo Cross-Fade & Shimmer Beam Transition
                        AnimatedBuilder(
                          animation: Listenable.merge(
                              [_logoScale, _logoCrossFade, _shimmerController]),
                          builder: (context, child) {
                            final crossFadeVal = _logoCrossFade.value;
                            return Transform.scale(
                              scale: _logoScale.value,
                              child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isOrangePhase ? Colors.white : primaryOrange)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 35.r,
                                      spreadRadius: 6.r,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Phase 1 Dark Brand Mark (Fades out)
                                    Opacity(
                                      opacity: (1.0 - crossFadeVal).clamp(0.0, 1.0),
                                      child: Image.asset(
                                        logo,
                                        width: 175.w,
                                        fit: BoxFit.contain,
                                      ),
                                    ),

                                    // Phase 2 Crisp White Logo with Shimmer Beam (Fades in)
                                    Opacity(
                                      opacity: crossFadeVal,
                                      child: ShaderMask(
                                        blendMode: BlendMode.srcATop,
                                        shaderCallback: (bounds) {
                                          final progress = _shimmerController.value;
                                          return LinearGradient(
                                            begin: Alignment(
                                              -2.5 + (progress * 5.0),
                                              -0.5,
                                            ),
                                            end: Alignment(
                                              -1.5 + (progress * 5.0),
                                              0.5,
                                            ),
                                            colors: const [
                                              Colors.white10,
                                              Colors.white,
                                              Colors.white10,
                                            ],
                                            stops: const [0.0, 0.5, 1.0],
                                          ).createShader(bounds);
                                        },
                                        child: Image.asset(
                                          whiteLogo,
                                          width: 175.w,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Image.asset(
                                              logo,
                                              width: 175.w,
                                              fit: BoxFit.contain,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  UIHelper.verticalSpace(26.h),

                  // 3. Tagline Unmasking on Orange Background
                  AnimatedBuilder(
                    animation: _taglineController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _taglineOpacity.value,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(30.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 10.r,
                              ),
                            ],
                          ),
                          child: Text(
                            'WHOLESALE & SUPPLY CHAIN ECOSYSTEM',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: _taglineSpacing.value.sp,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 4. Bottom Cinematic Loading & Copyright Label
            Positioned(
              bottom: 45.h,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _taglineController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _taglineOpacity.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 28.w,
                            height: 28.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5.w,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.95),
                              ),
                            ),
                          ),
                          UIHelper.verticalSpace(14.h),
                          Text(
                            'Powered by Banij Network · v1.0.0',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 0.8.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Radial Color Fill Wipe Custom Painter (White -> Primary Orange)
class RadialColorWipePainter extends CustomPainter {
  final double progress;
  final Color fillColor;

  RadialColorWipePainter({required this.progress, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = Offset(size.width / 2, size.height / 2 - 20.h);
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height);
    final currentRadius = maxRadius * progress;

    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, currentRadius, paint);
  }

  @override
  bool shouldRepaint(covariant RadialColorWipePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.fillColor != fillColor;
  }
}

/// Rotating Arc Accent Ring Painter
class ArcRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  ArcRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;

    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, trackPaint);

    final arcPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.2),
          color,
          Colors.white,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5.w;

    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant ArcRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
