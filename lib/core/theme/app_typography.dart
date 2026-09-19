import 'package:flutter/material.dart';

/// Vazirmatn is used for both Persian and English UI so the app never shows
/// two different typefaces side by side in a mixed-script string.
abstract final class AppTypography {
  static const String fontFamily = 'Vazirmatn';

  static TextTheme textTheme(ColorScheme scheme) {
    final base = Typography.material2021().black.apply(
      fontFamily: fontFamily,
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    // Persian glyphs sit taller than Latin ones; the default Material line
    // heights crowd them, so every role gets a slightly looser leading.
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(height: 1.4),
      headlineLarge: base.headlineLarge?.copyWith(height: 1.4),
      headlineMedium: base.headlineMedium?.copyWith(height: 1.4),
      headlineSmall: base.headlineSmall?.copyWith(
        height: 1.4,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(
        height: 1.5,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.titleMedium?.copyWith(
        height: 1.5,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        height: 1.5,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.7),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.7),
      bodySmall: base.bodySmall?.copyWith(height: 1.6),
      labelLarge: base.labelLarge?.copyWith(
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(height: 1.4),
      labelSmall: base.labelSmall?.copyWith(height: 1.4),
    );
  }
}
