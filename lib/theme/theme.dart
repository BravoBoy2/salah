import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SalahTheme {
  // Core fallback brand colors (used for accents/buttons, not text)
  static const Color _brandSeedColor = Color(0xFF32BB56);

  static final ColorScheme _lightFallback = ColorScheme.fromSeed(
    seedColor: _brandSeedColor,
    brightness: Brightness.light,
  );

  static final ColorScheme _darkFallback = ColorScheme.fromSeed(
    seedColor: _brandSeedColor,
    brightness: Brightness.dark,
  );

  /// Master builder for Light Themes
  static ThemeData light(ColorScheme? dynamicColors) {
    final scheme = dynamicColors ?? _lightFallback;
    return _buildTheme(scheme, Brightness.light);
  }

  /// Master builder for Dark Themes
  static ThemeData dark(ColorScheme? dynamicColors) {
    final scheme = dynamicColors ?? _darkFallback;
    return _buildTheme(scheme, Brightness.dark);
  }

  /// Build base typography configuration.
  static TextTheme _buildTextTheme(ColorScheme scheme) {
    // Generate text themes with a clean default structure
    final primaryTextTheme = GoogleFonts.juliusSansOneTextTheme();
    final secondaryTextTheme = GoogleFonts.montserratTextTheme();

    // Map your Montserrat text modifications cleanly
    final customTextTheme = primaryTextTheme.copyWith(
      displaySmall: secondaryTextTheme.displaySmall,
      displayMedium: secondaryTextTheme.displayMedium,
      displayLarge: secondaryTextTheme.displayLarge,
    );

    // Apply the perfect neutral text color based on the current context (light or dark mode)
    return customTextTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
  }

  /// Common internal configuration structure
  static ThemeData _buildTheme(ColorScheme scheme, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: _buildTextTheme(scheme),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        // This is the fix! Title and icons use the neutral surface color,
        // completely avoiding the loud brand green.
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
    );
  }
}