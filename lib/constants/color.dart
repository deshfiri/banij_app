import 'package:flutter/material.dart';

// Primary Brand Colors
const Color lightBackground = Color(0xFFFFF8F5);

// Dark theme: a deep navy-charcoal page with cards one step lighter and
// raised elements one more step up, so surfaces separate by tone rather
// than by borders. Orange stays the only accent.
const Color darkBackground = Color(0xFF1A1B2D);
const Color darkSurface = Color(0xFF232536);
const Color darkSurfaceRaised = Color(0xFF2C2E42);
const Color darkInputFill = Color(0xFF1E1F32);
const Color darkShimmerBase = Color(0xFF2A2C40);
const Color darkShimmerHighlight = Color(0xFF36384F);

// Form controls (switches, checkboxes, radios) in their "off" state, so
// they stay visible on dark cards.
const Color darkControlOutline = Color(0xFF5C5F7E);
const Color darkSwitchTrackOff = Color(0xFF3A3C56);
const Color darkSwitchThumbOff = Color(0xFFA4A7BF);
const Color lightControlOutline = Color(0xFFCBD5E1);

const Color cardBorderColor = Color(0xFFE2E8F0);
const Color darkCardBorderColor = Color(0xFF30324A);

const Color inputFillColor = Color(0xFFFFFFFF);

/// Dark card surface (kept under its old name; `AppColorsTheme.cardBg`).
const Color darkInputFillColor = darkSurface;

const Color primaryOrange = Color(0xFFFD6B04);
const Color secondaryOrange = Color(0xFFFF8A3D);

const Color textMain = Color(0xFF0F172A);
const Color darkTextMain = Color(0xFFF3F4F8);

const Color textMuted = Color(0xFF64748B);
const Color darkTextMuted = Color(0xFF8F92A8);

// System Status & Module Accent Colors
const Color successGreen = Color(0xFF10B981);
const Color successGreenDark = Color(0xFF059669);
const Color successGreenLight = Color(0xFFD1FAE5);

const Color infoBlue = Color(0xFF0284C7);
const Color infoBlueLight = Color(0xFFEDF6FF);

const Color warningYellow = Color(0xFFD97706);
const Color warningYellowLight = Color(0xFFFEF3C7);

const Color errorRed = Color(0xFFDC2626);
const Color errorRedLight = Color(0xFFFEE2E2);

const Color purpleAccent = Color(0xFF8B5CF6);
const Color purpleAccentLight = Color(0xFFF7F0FF);

// Hero header gradient in dark mode (dashboard header, drawer header…):
// slightly lighter than the page so headers still read as a band.
const Color heroDarkStart = Color(0xFF2B2D45);
const Color heroDarkEnd = Color(0xFF202134);

// Payment Brand Colors
const Color bkashPink = Color(0xFFE2136E);
const Color nagadRed = Color(0xFFED1C24);

class AppColorsTheme {
  static Color background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkBackground : lightBackground;
  }

  static Color cardBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkInputFillColor : inputFillColor;
  }

  static Color innerCardBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkSurfaceRaised : const Color(0xFFF1F5F9);
  }

  /// Text-field fill: white in light mode, a recessed tone in dark mode so a
  /// field still reads as a field on a card.
  static Color inputFill(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkInputFill : inputFillColor;
  }

  /// Outline of an unchecked checkbox / unselected radio.
  static Color controlOutline(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkControlOutline : lightControlOutline;
  }

  /// Loading-shimmer colours that sit naturally on the page.
  static Color shimmerBase(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkShimmerBase : const Color(0xFFE0E0E0);
  }

  static Color shimmerHighlight(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkShimmerHighlight : const Color(0xFFF5F5F5);
  }

  static Color borderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkCardBorderColor : cardBorderColor;
  }

  static Color textMainColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkTextMain : textMain;
  }

  /// Orange in light mode, slate in dark mode.
  static List<Color> heroGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const [heroDarkStart, heroDarkEnd] : const [primaryOrange, secondaryOrange];
  }

  static Color textMutedColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkTextMuted : textMuted;
  }
}
