import 'package:flutter/material.dart';

/// Bundled locally as assets (see pubspec.yaml `fonts:`) rather than fetched
/// at runtime via `google_fonts` — this app is local-only, no cloud (spec),
/// and a device with no/blocked internet (or, as shipped, no `INTERNET`
/// permission at all — never needed for anything else) silently fell back
/// to the system font on every real device, changing every weight/size in
/// the app without changing a single number in this file.
const _archivo = 'Archivo';
const _ibmPlexMono = 'IBM Plex Mono';

/// Design tokens lifted directly from `docs/screens.html`'s `:root` CSS
/// variables. One dark theme — the mockup never designed a light mode, so
/// this app doesn't pretend to have one either.
class AppColors {
  const AppColors._();

  static const ground = Color(0xFF14110F);
  static const surface = Color(0xFF1D1917);
  static const surface2 = Color(0xFF262120);
  static const line = Color(0xFF332C29);
  static const lineStrong = Color(0xFF463D39);
  static const ink = Color(0xFFEDE7DC);
  static const ink2 = Color(0xFF9C938A);
  static const ink3 = Color(0xFF6B635C);
  static const accent = Color(0xFF3C6FB4);
  static const accentBg = Color(0xFF18283F);
  static const accentInk = Color(0xFF8FB6E8);
  static const gold = Color(0xFFD9A441);
  static const red = Color(0xFFC2503A);
  static const onAccent = Color(0xFFF2F7FF);
}

/// `--r:10px` — the one corner radius the mockup uses almost everywhere.
const appRadius = 10.0;

TextStyle monoStyle({
  double fontSize = 13,
  Color color = AppColors.ink,
  FontWeight fontWeight = FontWeight.w400,
}) =>
    TextStyle(
      fontFamily: _ibmPlexMono,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

/// `.eyebrow` — uppercase, wide-tracked, muted.
TextStyle eyebrowStyle({Color color = AppColors.ink3}) => TextStyle(
      fontFamily: _archivo,
      fontSize: 10,
      letterSpacing: 1.3,
      color: color,
      fontWeight: FontWeight.w500,
    );

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: _archivo,
    scaffoldBackgroundColor: AppColors.ground,
    canvasColor: AppColors.ground,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.ground,
      onSurface: AppColors.ink,
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.accent,
      secondaryContainer: AppColors.accentBg,
      onSecondaryContainer: AppColors.accentInk,
      error: AppColors.red,
    ),
    textTheme: Typography.material2021(platform: TargetPlatform.android)
        .white
        .apply(fontFamily: _archivo, bodyColor: AppColors.ink, displayColor: AppColors.ink),
    dividerColor: AppColors.line,
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 1),
    iconTheme: const IconThemeData(color: AppColors.ink2),
    splashFactory: NoSplash.splashFactory,
    highlightColor: AppColors.surface2,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(appRadius)),
        textStyle: const TextStyle(fontFamily: _archivo, fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink2,
        side: const BorderSide(color: AppColors.lineStrong),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(appRadius)),
        textStyle: const TextStyle(fontFamily: _archivo, fontSize: 13),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accentInk,
        textStyle: const TextStyle(fontFamily: _archivo, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.ink,
      iconColor: AppColors.ink2,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface2,
      hintStyle: const TextStyle(color: AppColors.ink3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(appRadius),
        borderSide: BorderSide.none,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface2,
      selectedColor: AppColors.accent,
      labelStyle: const TextStyle(color: AppColors.ink2, fontSize: 13),
      secondaryLabelStyle: const TextStyle(color: AppColors.onAccent, fontSize: 13),
      side: const BorderSide(color: AppColors.lineStrong),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(21)),
      ),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
  );
}
