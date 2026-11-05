import 'package:flutter/material.dart';

const Color lightBackground = Color(0xFFFFF8F5);
const Color darkBackground = Color(0xFF121214);

const Color cardBorderColor = Color(0xFFE2E8F0);
const Color darkCardBorderColor = Color(0xFF374151);

const Color inputFillColor = Color(0xFFFFFFFF);
const Color darkInputFillColor = Color(0xFF111827);

const Color primaryOrange = Color(0xFFFD6B04);

const Color textMain = Color(0xFF0F172A);
const Color darkTextMain = Color(0xFFF8FAFC);

const Color textMuted = Color(0xFF64748B);
const Color darkTextMuted = Color(0xFF9CA3AF);

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

  static Color textMutedColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkTextMuted : textMuted;
  }
}
