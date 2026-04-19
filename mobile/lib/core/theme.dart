import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Nuvelo design tokens — matches NUVELO_MASTER_RULES brand colors.
abstract final class NuveloColors {
  static const Color primaryOrange = Color(0xFFF97316);
  static const Color darkNavy = Color(0xFF0D0A1E);
  static const Color cardBg = Color(0xFF13102A);
  static const Color deepCard = Color(0xFF1E1A35);
  static const Color purpleAccent = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFF8B5CF6);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderColor = Color(0xFF2A3347);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  /// Light-theme surfaces (used when brightness is light).
  static const Color lightScaffold = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
}

abstract final class NuveloRadii {
  static const double card = 16;
  static const double button = 12;
  static const double input = 10;
  static const double pill = 20;
}

abstract final class NuveloTypography {
  static TextStyle heading(TextTheme base, {double size = 22}) =>
      GoogleFonts.dmSans(
        fontSize: size.clamp(20.0, 24.0),
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  static TextStyle body(TextTheme base, {double size = 15}) =>
      GoogleFonts.dmSans(
        fontSize: size.clamp(14.0, 16.0),
        fontWeight: FontWeight.w400,
        height: 1.45,
      );

  static TextStyle caption(TextTheme base) => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.35,
      );
}

ThemeData nuveloThemeDark() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: NuveloColors.darkNavy,
    primaryColor: NuveloColors.primaryOrange,
    cardColor: NuveloColors.cardBg,
    dividerColor: NuveloColors.borderColor,
    colorScheme: const ColorScheme.dark(
      primary: NuveloColors.primaryOrange,
      secondary: NuveloColors.purpleAccent,
      surface: NuveloColors.cardBg,
      error: NuveloColors.danger,
      onPrimary: Colors.white,
      onSurface: NuveloColors.textPrimary,
      outline: NuveloColors.borderColor,
    ),
  );

  final tt = GoogleFonts.dmSansTextTheme(base.textTheme).apply(
    bodyColor: NuveloColors.textPrimary,
    displayColor: NuveloColors.textPrimary,
  );

  return base.copyWith(
    textTheme: tt,
    primaryTextTheme: tt,
    appBarTheme: AppBarTheme(
      backgroundColor: NuveloColors.darkNavy,
      foregroundColor: NuveloColors.textPrimary,
      elevation: 0,
      titleTextStyle: NuveloTypography.heading(tt,
          size: 18), // ignore: avoid_redundant_argument
    ),
    cardTheme: CardThemeData(
      color: NuveloColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NuveloRadii.card),
        side: const BorderSide(color: NuveloColors.borderColor),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: NuveloColors.primaryOrange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NuveloRadii.button),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: NuveloTypography.body(tt, size: 15).copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: NuveloColors.primaryOrange,
        side: const BorderSide(color: NuveloColors.primaryOrange),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NuveloRadii.button),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NuveloColors.deepCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NuveloRadii.input),
        borderSide: const BorderSide(color: NuveloColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NuveloRadii.input),
        borderSide: const BorderSide(color: NuveloColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NuveloRadii.input),
        borderSide: const BorderSide(color: NuveloColors.primaryOrange, width: 1.5),
      ),
      hintStyle: NuveloTypography.body(tt).copyWith(color: NuveloColors.textMuted),
      labelStyle: NuveloTypography.body(tt).copyWith(color: NuveloColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: NuveloColors.deepCard,
      selectedColor: NuveloColors.primaryOrange.withValues(alpha: 0.25),
      labelStyle: NuveloTypography.caption(tt),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NuveloRadii.pill),
        side: const BorderSide(color: NuveloColors.borderColor),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: NuveloColors.cardBg,
      selectedItemColor: NuveloColors.primaryOrange,
      unselectedItemColor: NuveloColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}

ThemeData nuveloThemeLight() {
  final base = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: NuveloColors.lightScaffold,
    primaryColor: NuveloColors.primaryOrange,
    cardColor: NuveloColors.lightCard,
    colorScheme: ColorScheme.light(
      primary: NuveloColors.primaryOrange,
      secondary: NuveloColors.purpleAccent,
      surface: NuveloColors.lightCard,
      error: NuveloColors.danger,
      onPrimary: Colors.white,
      onSurface: const Color(0xFF0F172A),
      outline: NuveloColors.borderColor,
    ),
  );

  final tt = GoogleFonts.dmSansTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: tt,
    primaryTextTheme: tt,
    appBarTheme: AppBarTheme(
      backgroundColor: NuveloColors.lightScaffold,
      foregroundColor: const Color(0xFF0F172A),
      elevation: 0,
      titleTextStyle: NuveloTypography.heading(tt, size: 18),
    ),
    cardTheme: CardThemeData(
      color: NuveloColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NuveloRadii.card),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: NuveloColors.primaryOrange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NuveloRadii.button),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NuveloRadii.input),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: NuveloColors.primaryOrange,
      unselectedItemColor: Color(0xFF64748B),
      type: BottomNavigationBarType.fixed,
    ),
  );
}
