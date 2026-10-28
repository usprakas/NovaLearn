import 'package:flutter/material.dart';

/// One shared theme for the whole app: friendly enough for a 5-8-year-old to tap around in,
/// polished enough for the parent-facing screens (dashboard, auth). Centralized here so every
/// screen's cards/buttons/inputs stay visually consistent without each one hardcoding shapes.
class AppTheme {
  const AppTheme._();

  static const Color seed = Color(0xff6246ea);

  static ThemeData light() =>
      _themeFrom(ColorScheme.fromSeed(seedColor: seed), Brightness.light);

  static ThemeData dark() => _themeFrom(
      ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark), Brightness.dark);

  static ThemeData _themeFrom(ColorScheme colorScheme, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: _textTheme(
          brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.primary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.error, width: 1.5)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 2,
        height: 68,
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
        backgroundColor: colorScheme.secondaryContainer,
        labelStyle: TextStyle(
            color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.w600),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colorScheme.primary),
    );
  }

  static TextTheme _textTheme(TextTheme base) => base.copyWith(
        displaySmall: base.displaySmall?.copyWith(fontWeight: FontWeight.w800),
        headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      );

  /// Fixed per-subject color so a subject reads consistently everywhere it appears (lesson list,
  /// dashboard). `OTHER`/unknown subjects fall back to the theme's primary color.
  static Color subjectColor(BuildContext context, String subject) {
    switch (subject) {
      case 'MATH':
        return const Color(0xff2563eb);
      case 'ENGLISH':
        // Not the "textbook" green (#16a34a) — that fails WCAG's 3:1 non-text contrast
        // threshold against its own tinted icon-circle background (verified: 2.62:1). This
        // shade keeps the same hue family at 3.5:1+ in both light and dark.
        return const Color(0xff12883e);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  static IconData subjectIcon(String subject) {
    switch (subject) {
      case 'MATH':
        return Icons.calculate_rounded;
      case 'ENGLISH':
        return Icons.menu_book_rounded;
      default:
        return Icons.school_rounded;
    }
  }
}
