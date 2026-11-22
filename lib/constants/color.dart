import 'package:flutter/material.dart';

// Primary Brand Colors
const Color lightBackground = Color(0xFFFFF8F5);
const Color darkBackground = Color(0xFF121214);

const Color cardBorderColor = Color(0xFFE2E8F0);
const Color darkCardBorderColor = Color(0xFF374151);

const Color inputFillColor = Color(0xFFFFFFFF);
const Color darkInputFillColor = Color(0xFF111827);

const Color primaryOrange = Color(0xFFFD6B04);
const Color secondaryOrange = Color(0xFFFF8A3D);

const Color textMain = Color(0xFF0F172A);
const Color darkTextMain = Color(0xFFF8FAFC);

const Color textMuted = Color(0xFF64748B);
const Color darkTextMuted = Color(0xFF9CA3AF);

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

// Hero header gradient (dashboard header, drawer header)
const Color heroDarkStart = Color(0xFF1E293B);
const Color heroDarkEnd = Color(0xFF0F172A);

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
    return isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9);
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
