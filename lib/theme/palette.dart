import 'package:flutter/material.dart';

/// VERIFACT "broadcast desk" palette — warm paper canvas under navy bands,
/// action blue for FACT, a hue-derived crimson for HOAX, ruled hairlines.
/// Never nested rounded cards.
class AppPalette extends ThemeExtension<AppPalette> {
  final Color canvas;
  final Color ink;
  final Color inkSoft;
  final Color surface;
  final Color surface2;
  final Color line;
  final Color lineStrong;
  final Color band;
  final Color bandDeep;
  final Color bandInk;
  final Color brand;
  final Color accent;
  final Color crimson;
  final Color crimsonAccent;
  final Color success;
  final Color successAccent;
  final Color warning;
  final Color warningAccent;

  const AppPalette({
    required this.canvas,
    required this.ink,
    required this.inkSoft,
    required this.surface,
    required this.surface2,
    required this.line,
    required this.lineStrong,
    required this.band,
    required this.bandDeep,
    required this.bandInk,
    required this.brand,
    required this.accent,
    required this.crimson,
    required this.crimsonAccent,
    required this.success,
    required this.successAccent,
    required this.warning,
    required this.warningAccent,
  });

  static const light = AppPalette(
    canvas: Color(0xFFFDF9F1),
    ink: Color(0xFF14122A),
    inkSoft: Color(0x9914122A),
    surface: Color(0xFFF6F0E1),
    surface2: Color(0xFFECE3CE),
    line: Color(0xFFDBD0B7),
    lineStrong: Color(0xFFB3A784),
    band: Color(0xFF1A1953),
    bandDeep: Color(0xFF080516),
    bandInk: Color(0xFFFDF9F1),
    brand: Color(0xFF162D93),
    accent: Color(0xFFABD2FB),
    crimson: Color(0xFF93162B),
    crimsonAccent: Color(0xFFFBB0C0),
    success: Color(0xFF1F7A54),
    successAccent: Color(0xFFB8E4CC),
    warning: Color(0xFFC98A2E),
    warningAccent: Color(0xFFF0D9A8),
  );

  static const dark = AppPalette(
    canvas: Color(0xFF080516),
    ink: Color(0xFFFDF9F1),
    inkSoft: Color(0x99FDF9F1),
    surface: Color(0xFF120F30),
    surface2: Color(0xFF1A1953),
    line: Color(0x1FFDF9F1),
    lineStrong: Color(0x3DFDF9F1),
    band: Color(0xFF1A1953),
    bandDeep: Color(0xFF080516),
    bandInk: Color(0xFFFDF9F1),
    brand: Color(0xFF2E4CD1),
    accent: Color(0xFFABD2FB),
    crimson: Color(0xFFB0263F),
    crimsonAccent: Color(0xFFFBB0C0),
    success: Color(0xFF2E9668),
    successAccent: Color(0xFFB8E4CC),
    warning: Color(0xFFD79B3E),
    warningAccent: Color(0xFFF0D9A8),
  );

  @override
  AppPalette copyWith({
    Color? canvas,
    Color? ink,
    Color? inkSoft,
    Color? surface,
    Color? surface2,
    Color? line,
    Color? lineStrong,
    Color? band,
    Color? bandDeep,
    Color? bandInk,
    Color? brand,
    Color? accent,
    Color? crimson,
    Color? crimsonAccent,
    Color? success,
    Color? successAccent,
    Color? warning,
    Color? warningAccent,
  }) {
    return AppPalette(
      canvas: canvas ?? this.canvas,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      line: line ?? this.line,
      lineStrong: lineStrong ?? this.lineStrong,
      band: band ?? this.band,
      bandDeep: bandDeep ?? this.bandDeep,
      bandInk: bandInk ?? this.bandInk,
      brand: brand ?? this.brand,
      accent: accent ?? this.accent,
      crimson: crimson ?? this.crimson,
      crimsonAccent: crimsonAccent ?? this.crimsonAccent,
      success: success ?? this.success,
      successAccent: successAccent ?? this.successAccent,
      warning: warning ?? this.warning,
      warningAccent: warningAccent ?? this.warningAccent,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      canvas: c(canvas, other.canvas),
      ink: c(ink, other.ink),
      inkSoft: c(inkSoft, other.inkSoft),
      surface: c(surface, other.surface),
      surface2: c(surface2, other.surface2),
      line: c(line, other.line),
      lineStrong: c(lineStrong, other.lineStrong),
      band: c(band, other.band),
      bandDeep: c(bandDeep, other.bandDeep),
      bandInk: c(bandInk, other.bandInk),
      brand: c(brand, other.brand),
      accent: c(accent, other.accent),
      crimson: c(crimson, other.crimson),
      crimsonAccent: c(crimsonAccent, other.crimsonAccent),
      success: c(success, other.success),
      successAccent: c(successAccent, other.successAccent),
      warning: c(warning, other.warning),
      warningAccent: c(warningAccent, other.warningAccent),
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
