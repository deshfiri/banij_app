import 'package:flutter/material.dart';

const Color lightBackground = Color(0xFFFAFAFA);
const Color darkBackground = Color(0xFF111111);

const Color cardBorderColor = Color(0xFFE5E7EB);
const Color darkCardBorderColor = Color(0xFF262626);

const Color inputFillColor = Color(0xFFFFFFFF);
const Color darkInputFillColor = Color(0xFF1A1A1A);

const Color primaryOrange = Color(0xFFFD6B04);

const Color textMain = Color(0xFF111827);
const Color darkTextMain = Color(0xFFFFFFFF);

const Color textMuted = Color(0xFF6B7280);
const Color darkTextMuted = Color(0xFF8E8E93);

class AppColorsTheme {
  static Color background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkBackground : lightBackground;
  }

  static Color cardBg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkInputFillColor : inputFillColor;
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
