import 'package:flutter/material.dart';

/// Page route that reveals the next screen with a circle growing from the
/// bottom-center (where the onboarding "Get Started" button sits).
class WaveRevealRoute<T> extends PageRouteBuilder<T> {
  WaveRevealRoute({required Widget page})
      : super(
          pageBuilder: (_, _, _) => page,
          transitionDuration: const Duration(milliseconds: 1200),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, animation, _, child) => AnimatedBuilder(
            animation: animation,
            builder: (_, animatedChild) => ClipPath(
              clipper: _WaveClipper(animation.value),
              child: animatedChild,
            ),
            child: child,
          ),
        );
}

class _WaveClipper extends CustomClipper<Path> {
  final double progress;

  _WaveClipper(this.progress);

  @override
  Path getClip(Size size) {
    final radius = progress * size.height * 1.5;
    return Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.85),
        radius: radius,
      ));
  }

  @override
  bool shouldReclip(covariant _WaveClipper oldClipper) => oldClipper.progress != progress;
}
