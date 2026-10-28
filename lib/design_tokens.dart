// Design tokens, three layers:
//   Primitive  -> raw values, never used directly by widgets
//   Semantic   -> purpose aliases, switch per theme (PhaseColors)
//   Component  -> per-component specs (CardTokens, ChipTokens, ...)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ───────────────────────── Primitive ─────────────────────────
abstract final class Prim {
  // Greens (primary)
  static const green50 = Color(0xFFEAF5EE);
  static const green100 = Color(0xFFCDE7D7);
  static const green300 = Color(0xFF7FC39A);
  static const green500 = Color(0xFF3E9C68);
  static const green600 = Color(0xFF2F7F54);
  static const green700 = Color(0xFF246542);
  static const green900 = Color(0xFF123323);

  // Amber (streaks, momentum)
  static const amber100 = Color(0xFFFFEBC2);
  static const amber400 = Color(0xFFF2B544);
  static const amber600 = Color(0xFFC98A12);

  // Coral (alarm, escapes)
  static const coral100 = Color(0xFFFFE0DB);
  static const coral500 = Color(0xFFE5685A);
  static const coral700 = Color(0xFFB03D30);

  // Indigo (night mode)
  static const indigo200 = Color(0xFFB9BEF0);
  static const indigo800 = Color(0xFF2B2F63);

  // Neutrals, warm
  static const sand50 = Color(0xFFFAF8F3);
  static const sand100 = Color(0xFFF2EFE7);
  static const sand200 = Color(0xFFE6E1D5);
  static const sand400 = Color(0xFFAEA89A);
  static const sand600 = Color(0xFF6E685C);
  static const ink700 = Color(0xFF2E3133);
  static const ink800 = Color(0xFF1E2123);
  static const ink850 = Color(0xFF17191B);
  static const ink900 = Color(0xFF101213);

  // Spacing, 4px base
  static const space1 = 4.0;
  static const space2 = 8.0;
  static const space3 = 12.0;
  static const space4 = 16.0;
  static const space5 = 20.0;
  static const space6 = 24.0;
  static const space8 = 32.0;
  static const space12 = 48.0;

  // Radius
  static const radiusSm = 8.0;
  static const radiusMd = 14.0;
  static const radiusLg = 22.0;
  static const radiusFull = 999.0;

  // Type scale (1.25 ratio from 14)
  static const fontXs = 12.0;
  static const fontSm = 14.0;
  static const fontBase = 16.0;
  static const fontLg = 18.0;
  static const fontXl = 22.0;
  static const font2xl = 28.0;
  static const font3xl = 36.0;

  // Motion
  static const durFast = Duration(milliseconds: 150);
  static const durBase = Duration(milliseconds: 250);
  static const durSlow = Duration(milliseconds: 600);
  static const easeOut = Curves.easeOutCubic;
}

// ───────────────────────── Semantic ─────────────────────────
@immutable
class PhaseColors extends ThemeExtension<PhaseColors> {
  const PhaseColors({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.foreground,
    required this.muted,
    required this.primary,
    required this.primaryHover,
    required this.primaryForeground,
    required this.primarySoft,
    required this.momentum,
    required this.momentumSoft,
    required this.alarm,
    required this.alarmSoft,
    required this.alarmForeground,
    required this.night,
    required this.nightSoft,
    required this.heroGradient,
  });

  final Color background, surface, surfaceRaised, border, foreground, muted;
  final Color primary, primaryHover, primaryForeground, primarySoft;
  final Color momentum, momentumSoft;
  final Color alarm, alarmSoft, alarmForeground;
  final Color night, nightSoft;
  final List<Color> heroGradient;

  static const light = PhaseColors(
    background: Prim.sand50,
    surface: Colors.white,
    surfaceRaised: Prim.sand100,
    border: Prim.sand200,
    foreground: Prim.ink800,
    muted: Prim.sand600,
    primary: Prim.green600,
    primaryHover: Prim.green700,
    primaryForeground: Colors.white,
    primarySoft: Prim.green50,
    momentum: Prim.amber600,
    momentumSoft: Prim.amber100,
    alarm: Prim.coral700,
    alarmSoft: Prim.coral100,
    alarmForeground: Prim.coral700,
    night: Prim.indigo800,
    nightSoft: Prim.indigo200,
    heroGradient: [Prim.green600, Prim.green500],
  );

  static const dark = PhaseColors(
    background: Prim.ink900,
    surface: Prim.ink850,
    surfaceRaised: Prim.ink800,
    border: Prim.ink700,
    foreground: Prim.sand100,
    muted: Prim.sand400,
    primary: Prim.green500,
    primaryHover: Prim.green300,
    primaryForeground: Prim.ink900,
    primarySoft: Color(0xFF1B3528),
    momentum: Prim.amber400,
    momentumSoft: Color(0xFF3A2E12),
    alarm: Prim.coral500,
    alarmSoft: Color(0xFF3D1F1B),
    alarmForeground: Color(0xFFFFB4A9),
    night: Prim.indigo200,
    nightSoft: Prim.indigo800,
    heroGradient: [Prim.green700, Prim.green900],
  );

  @override
  PhaseColors copyWith() => this;

  @override
  PhaseColors lerp(PhaseColors? other, double t) => t < 0.5 ? this : (other ?? this);
}

extension PhaseColorsX on BuildContext {
  PhaseColors get pc => Theme.of(this).extension<PhaseColors>()!;
}

// ───────────────────────── Component ─────────────────────────
abstract final class CardTokens {
  static const padding = EdgeInsets.all(Prim.space5);
  static const radius = Prim.radiusLg;
  static const gap = Prim.space4; // between cards
}

abstract final class HabitTileTokens {
  static const padding = EdgeInsets.symmetric(horizontal: Prim.space4, vertical: Prim.space3);
  static const radius = Prim.radiusMd;
  static const checkSize = 28.0;
}

abstract final class GateTokens {
  static const padding = EdgeInsets.symmetric(horizontal: Prim.space4, vertical: Prim.space3);
  static const radius = Prim.radiusMd;
}

abstract final class RingTokens {
  static const size = 132.0;
  static const stroke = 12.0;
}

// ───────────────────────── Theme builder ─────────────────────────
ThemeData buildTheme(Brightness b) {
  final c = b == Brightness.dark ? PhaseColors.dark : PhaseColors.light;
  final scheme = ColorScheme(
    brightness: b,
    primary: c.primary,
    onPrimary: c.primaryForeground,
    primaryContainer: c.primarySoft,
    onPrimaryContainer: c.foreground,
    secondary: c.momentum,
    onSecondary: Prim.ink900,
    secondaryContainer: c.momentumSoft,
    onSecondaryContainer: c.foreground,
    tertiary: c.night,
    onTertiary: c.nightSoft,
    tertiaryContainer: c.nightSoft,
    onTertiaryContainer: c.foreground,
    error: c.alarm,
    onError: Colors.white,
    errorContainer: c.alarmSoft,
    onErrorContainer: c.alarmForeground,
    surface: c.background,
    onSurface: c.foreground,
    surfaceContainerLowest: c.surface,
    surfaceContainerLow: c.surface,
    surfaceContainer: c.surface,
    surfaceContainerHigh: c.surfaceRaised,
    surfaceContainerHighest: c.surfaceRaised,
    onSurfaceVariant: c.muted,
    outline: c.border,
    outlineVariant: c.border,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: c.foreground,
    onInverseSurface: c.background,
    inversePrimary: c.primaryHover,
  );

  final body = GoogleFonts.interTextTheme();
  final heading = GoogleFonts.manrope();
  TextStyle h(double size, FontWeight w, {double? height, double ls = -0.3}) =>
      heading.copyWith(fontSize: size, fontWeight: w, color: c.foreground, height: height ?? 1.15, letterSpacing: ls);
  TextStyle t(double size, FontWeight w, {Color? color, double height = 1.45}) =>
      body.bodyMedium!.copyWith(fontSize: size, fontWeight: w, color: color ?? c.foreground, height: height);

  final text = TextTheme(
    displaySmall: h(Prim.font3xl, FontWeight.w800, ls: -0.8),
    headlineMedium: h(Prim.font2xl, FontWeight.w800, ls: -0.6),
    headlineSmall: h(Prim.fontXl, FontWeight.w700),
    titleLarge: h(Prim.fontLg, FontWeight.w700, ls: -0.1),
    titleMedium: h(Prim.fontBase, FontWeight.w700, ls: 0),
    titleSmall: h(Prim.fontSm, FontWeight.w700, ls: 0),
    bodyLarge: t(Prim.fontLg, FontWeight.w400),
    bodyMedium: t(Prim.fontBase, FontWeight.w400),
    bodySmall: t(Prim.fontSm, FontWeight.w400, color: c.muted),
    labelLarge: t(Prim.fontSm, FontWeight.w600, height: 1.2),
    labelMedium: t(Prim.fontXs, FontWeight.w600, color: c.muted, height: 1.2),
    labelSmall: t(Prim.fontXs, FontWeight.w500, color: c.muted, height: 1.2),
  );

  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(Prim.radiusMd));

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.background,
    textTheme: text,
    extensions: [c],
    splashFactory: InkSparkle.splashFactory,
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CardTokens.radius),
        side: BorderSide(color: c.border),
      ),
    ),
    dividerTheme: DividerThemeData(color: c.border, space: 1, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: shape,
        padding: const EdgeInsets.symmetric(horizontal: Prim.space5, vertical: Prim.space3 + 2),
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: shape,
        side: BorderSide(color: c.border),
        foregroundColor: c.foreground,
        padding: const EdgeInsets.symmetric(horizontal: Prim.space4, vertical: Prim.space3 + 2),
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: shape, textStyle: text.labelLarge),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceRaised,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: Prim.space4, vertical: Prim.space3 + 2),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(Prim.radiusMd), borderSide: BorderSide(color: c.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Prim.radiusMd), borderSide: BorderSide(color: c.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Prim.radiusMd), borderSide: BorderSide(color: c.primary, width: 2)),
      hintStyle: text.bodyMedium?.copyWith(color: c.muted),
      helperStyle: text.labelSmall,
      labelStyle: text.bodySmall,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Prim.radiusFull)),
      side: BorderSide(color: c.border),
      backgroundColor: c.surface,
      selectedColor: c.primarySoft,
      labelStyle: text.labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: Prim.space3, vertical: Prim.space2),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.primarySoft,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStatePropertyAll(text.labelMedium?.copyWith(color: c.foreground)),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(color: s.contains(WidgetState.selected) ? c.primary : c.muted, size: 22),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: c.surface,
      indicatorColor: c.primarySoft,
      selectedIconTheme: IconThemeData(color: c.primary),
      unselectedIconTheme: IconThemeData(color: c.muted),
      selectedLabelTextStyle: text.labelMedium?.copyWith(color: c.foreground),
      unselectedLabelTextStyle: text.labelMedium,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.primaryForeground : c.muted),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.primary : c.surfaceRaised),
      trackOutlineColor: WidgetStatePropertyAll(c.border),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide(color: c.muted, width: 1.5),
      fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.primary : Colors.transparent),
      checkColor: WidgetStatePropertyAll(c.primaryForeground),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.primary,
      linearTrackColor: c.surfaceRaised,
      borderRadius: BorderRadius.circular(Prim.radiusFull),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CardTokens.radius)),
      titleTextStyle: text.titleLarge,
      contentTextStyle: text.bodyMedium,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: shape,
      backgroundColor: c.foreground,
      contentTextStyle: text.bodyMedium?.copyWith(color: c.background),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.zero,
      titleTextStyle: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      subtitleTextStyle: text.bodySmall,
    ),
    expansionTileTheme: const ExpansionTileThemeData(tilePadding: EdgeInsets.zero, shape: Border()),
  );
}
