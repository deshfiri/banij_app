import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/color.dart';

/// Flat (2D) sidebar: the [menu] sits behind while the [child] screen slides
/// right, scales down, tilts slightly (Z-axis rotation, no perspective) and gets
/// rounded corners. Two coloured "cards" fan out behind the screen.
///
/// Open/close it through a `GlobalKey<AnimatedSideMenuState>`:
/// `key.currentState?.open()`, `close()` or `toggle()`.
/// Also supports a left-edge swipe to open, swipe/tap to close and the back button.
class AnimatedSideMenu extends StatefulWidget {
  final Widget menu;
  final Widget child;
  final double? menuWidth;

  const AnimatedSideMenu({
    super.key,
    required this.menu,
    required this.child,
    this.menuWidth,
  });

  @override
  State<AnimatedSideMenu> createState() => AnimatedSideMenuState();
}

class AnimatedSideMenuState extends State<AnimatedSideMenu> with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 380);
  static const double _minScale = 0.8;
  static const double _tiltRadians = 0.16; // ~9° counter-clockwise tilt
  static const double _cardTiltStep = 0.09; // extra tilt per background card
  static const double _edgeDragWidth = 24;
  static const double _flingVelocity = 365;

  late final AnimationController _controller = AnimationController(vsync: this, duration: _duration);
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  bool get isOpen => _controller.value > 0;

  double get _menuWidth => widget.menuWidth ?? 255.w;

  void open() => _controller.forward();

  void close() => _controller.reverse();

  void toggle() => isOpen ? close() : open();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _controller.value += (details.primaryDelta ?? 0) / _menuWidth;
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() >= _flingVelocity) {
      velocity > 0 ? open() : close();
    } else {
      _controller.value > 0.5 ? open() : close();
    }
  }

  /// 2D transform for the screen ([layer] 0) and the cards behind it
  /// (layer 1, 2…): each deeper card is shifted a bit left and tilted more.
  Matrix4 _cardTransform(double t, {required int layer}) {
    final scale = 1 - (1 - _minScale) * t;
    final dx = (_menuWidth * 0.85 - layer * 18.w) * t;
    final angle = -(_tiltRadians + layer * _cardTiltStep) * t;
    return Matrix4.identity()
      ..translateByDouble(dx, 0, 0, 1)
      ..rotateZ(angle)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  Widget _backgroundCard(double t, {required int layer, required Color color}) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Transform(
          alignment: Alignment.center,
          transform: _cardTransform(t, layer: layer),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(28.r * t),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        final t = _progress.value;
        final menuOpen = _controller.value > 0;

        return PopScope(
          canPop: !menuOpen,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) close();
          },
          child: Material(
            color: AppColorsTheme.background(context),
            // Whole-screen drag only while open, so the page's own horizontal
            // scrolling keeps working when the menu is closed.
            child: GestureDetector(
              onHorizontalDragUpdate: menuOpen ? _onDragUpdate : null,
              onHorizontalDragEnd: menuOpen ? _onDragEnd : null,
              child: Stack(
                children: [
                  // Menu: slides in from slightly off-screen and fades in.
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    width: _menuWidth,
                    child: IgnorePointer(
                      ignoring: t < 0.5,
                      child: Opacity(
                        opacity: t,
                        child: Transform.translate(
                          offset: Offset(-_menuWidth * 0.3 * (1 - t), 0),
                          child: widget.menu,
                        ),
                      ),
                    ),
                  ),

                  // Background cards fanned out behind the screen.
                  if (t > 0) ...[
                    _backgroundCard(t, layer: 2, color: primaryOrange.withValues(alpha: 0.25)),
                    _backgroundCard(t, layer: 1, color: primaryOrange.withValues(alpha: 0.85)),
                  ],

                  // Main screen: slide + scale + flat tilt + rounded corners.
                  Transform(
                    alignment: Alignment.center,
                    transform: _cardTransform(t, layer: 0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28.r * t),
                        boxShadow: [
                          if (t > 0)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: (isDark ? 0.4 : 0.18) * t),
                              blurRadius: 30,
                              offset: const Offset(-8, 12),
                            ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28.r * t),
                        child: Stack(
                          children: [
                            AbsorbPointer(absorbing: menuOpen, child: widget.child),
                            // While open, tapping the screen closes the menu.
                            if (menuOpen)
                              Positioned.fill(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: close,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // A thin left-edge strip catches the swipe to open. It stays
                  // mounted while open too: removing it as soon as the menu starts
                  // moving would cancel the swipe mid-gesture. Translucent so taps
                  // still reach the widgets underneath.
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    width: _edgeDragWidth,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: _onDragUpdate,
                      onHorizontalDragEnd: _onDragEnd,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
