import 'package:flutter/material.dart';

/// Configuration for a mood-based theme.
class MoodThemeConfig {
  /// Optional: Provide a complete [ThemeData] object directly.
  final ThemeData? customTheme;

  /// Optional: The seed color used to generate the [ColorScheme].
  final Color? seedColor;

  /// Optional: The brightness of the theme.
  final Brightness? brightness;

  /// A factor (0.0 - 1.0) to apply to the surface tint.
  final double surfaceTintFactor;

  const MoodThemeConfig({
    this.customTheme,
    this.seedColor,
    this.brightness,
    this.surfaceTintFactor = 0.0,
  });

  /// Quick helper to create a config from a [ThemeData].
  factory MoodThemeConfig.fromTheme(ThemeData theme) =>
      MoodThemeConfig(customTheme: theme);

  /// Quick helper to create a config from a [Color].
  factory MoodThemeConfig.fromSeed(Color color, {Brightness? brightness}) =>
      MoodThemeConfig(seedColor: color, brightness: brightness);

  /// Generates the [ThemeData].
  ThemeData toThemeData() {
    if (customTheme != null) return customTheme!;

    final effectiveSeed = seedColor ?? Colors.blue;
    final effectiveBrightness = brightness ?? Brightness.light;

    var colorScheme = ColorScheme.fromSeed(
      seedColor: effectiveSeed,
      brightness: effectiveBrightness,
    );

    if (surfaceTintFactor > 0) {
      colorScheme = colorScheme.copyWith(
        surfaceTint: effectiveSeed.withValues(alpha: surfaceTintFactor),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: effectiveBrightness,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
    );
  }
}
