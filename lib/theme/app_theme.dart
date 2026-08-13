import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'palette.dart';

/// Text helpers bound to the current theme — Libre Franklin for reading,
/// JetBrains Mono for anything numeric/data (scores, counters, card IDs).
extension AppTypography on BuildContext {
  TextStyle get displayLg => GoogleFonts.libreFranklin(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: palette.ink,
        letterSpacing: -0.5,
        height: 1.05,
      );

  TextStyle get title => GoogleFonts.libreFranklin(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: palette.ink,
        height: 1.15,
      );

  TextStyle get body => GoogleFonts.libreFranklin(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        color: palette.ink,
        height: 1.5,
      );

  TextStyle get bodySoft => body.copyWith(color: palette.inkSoft);

  TextStyle get label => GoogleFonts.libreFranklin(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.2,
        color: palette.brand,
      );

  TextStyle get eyebrowOnBand => GoogleFonts.libreFranklin(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.4,
        color: palette.accent,
      );

  TextStyle mono({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? palette.ink,
        letterSpacing: letterSpacing,
      );
}

class AppTheme {
  AppTheme._();

  static const _chamfer = BeveledRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(3)),
  );

  static ThemeData light() => _build(AppPalette.light, Brightness.light);
  static ThemeData dark() => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final textTheme = GoogleFonts.libreFranklinTextTheme().apply(
      bodyColor: p.ink,
      displayColor: p.ink,
    );

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: p.canvas,
      primaryColor: p.brand,
      fontFamily: GoogleFonts.libreFranklin().fontFamily,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: p.brand,
        onPrimary: p.bandInk,
        secondary: p.accent,
        onSecondary: p.bandDeep,
        error: p.crimson,
        onError: p.bandInk,
        surface: p.canvas,
        onSurface: p.ink,
      ),
      dividerTheme: DividerThemeData(
        color: p.line,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.band,
        foregroundColor: p.bandInk,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.libreFranklin(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: p.bandInk,
          letterSpacing: 1.6,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.brand,
          foregroundColor: p.bandInk,
          disabledBackgroundColor: p.line,
          disabledForegroundColor: p.inkSoft,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: _chamfer,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          textStyle: GoogleFonts.libreFranklin(
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
            letterSpacing: 1.6,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.brand,
          side: BorderSide(color: p.lineStrong, width: 1.4),
          shape: _chamfer,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          textStyle: GoogleFonts.libreFranklin(
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
            letterSpacing: 1.6,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.brand,
          textStyle: GoogleFonts.libreFranklin(fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: p.ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        hintStyle: GoogleFonts.libreFranklin(color: p.inkSoft, fontSize: 14.5),
        labelStyle: GoogleFonts.libreFranklin(color: p.inkSoft, fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: p.line, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: p.line, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: p.brand, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.canvas,
        surfaceTintColor: Colors.transparent,
        shape: BeveledRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          side: BorderSide(color: p.lineStrong),
        ),
        titleTextStyle: GoogleFonts.libreFranklin(
          fontWeight: FontWeight.w800,
          fontSize: 17,
          color: p.ink,
        ),
        contentTextStyle: GoogleFonts.libreFranklin(
          fontSize: 14,
          color: p.inkSoft,
          height: 1.5,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.band,
        contentTextStyle: GoogleFonts.libreFranklin(
          color: p.bandInk,
          fontWeight: FontWeight.w600,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        behavior: SnackBarBehavior.fixed,
      ),
      extensions: [p],
    );
  }
}
