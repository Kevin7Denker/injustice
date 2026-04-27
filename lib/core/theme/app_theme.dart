import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);

  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  TextStyle withColor(Color color) => copyWith(color: color);

  TextStyle withSize(double size) => copyWith(fontSize: size);
}

class AppColors {
  AppColors._();

  static const Color neonCyan = Color(0xFFFF7A2F);
  static const Color cyanLight = Color(0xFFFFAA70);
  static const Color cyanDark = Color(0xFFCC5500);
  static const Color cyanGlow = Color(0x40FF7A2F);

  static const Color plasmaViolet = Color(0xFFFFBB00);
  static const Color plasmaVioletLight = Color(0xFFFFD54F);
  static const Color plasmaVioletMuted = Color(0xFFCC9500);

  static const Color hotMagenta = Color(0xFFFF3B7A);
  static const Color hotMagentaLight = Color(0xFFFF6A9A);
  static const Color hotMagentaMuted = Color(0xFFAA2850);

  static const Color limeScan = Color(0xFF78FF56);

  static const Color plasmaGold = Color(0xFFFFD740);

  static const Color void_ = Color(0xFF0A0907);
  static const Color surface = Color(0xFF13110F);
  static const Color surfaceVariant = Color(0xFF1C1916);
  static const Color surfaceElevated = Color(0xFF252119);

  static const Color coolWhite = Color(0xFFF2EDE4);
  static const Color coolWhiteMuted = Color(0xFF98897A);
  static const Color coolWhiteFaint = Color(0xFF685A4A);

  static const Color outline = Color(0xFF2A2218);
  static const Color outlineFaint = Color(0xFF201A12);

  static const Color success = Color(0xFF78FF56);
  static const Color warning = Color(0xFFFFD740);

  static const Color rarityTitanium = Color(0xFF8B95A5);
  static const Color rarityPlasmaGold = Color(0xFFFFD740);
  static const Color rarityLegendary = Color(0xFFFF7A2F);

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF7A2F), Color(0xFFFFBB00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF0F1218), Color(0xFF07090E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF161C26), Color(0xFF0F1218), Color(0xFF07090E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color ember = neonCyan;
  static const Color emberLight = cyanLight;
  static const Color emberDark = cyanDark;
  static const Color emberGlow = cyanGlow;
  static const LinearGradient emberGradient = accentGradient;

  static const Color combatRed = hotMagenta;
  static const Color combatRedLight = hotMagentaLight;
  static const Color combatRedMuted = hotMagentaMuted;

  static const Color techBlue = Color(0xFF3D8BF2);
  static const Color techBlueMuted = Color(0xFF2A5FAA);

  static const Color warmWhite = coolWhite;
  static const Color warmWhiteMuted = coolWhiteMuted;
  static const Color warmWhiteFaint = coolWhiteFaint;

  static const Color raritySilver = rarityTitanium;
  static const Color rarityGold = rarityPlasmaGold;
}

class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

class LightModeColors {
  static const lightPrimary = AppColors.neonCyan;
  static const lightOnPrimary = AppColors.void_;
  static const lightPrimaryContainer = Color(0xFF1E140A);
  static const lightOnPrimaryContainer = AppColors.cyanLight;

  static const lightSecondary = AppColors.plasmaViolet;
  static const lightOnSecondary = Color(0xFF1A1000);

  static const lightTertiary = AppColors.techBlue;
  static const lightOnTertiary = Color(0xFFFFFFFF);

  static const lightError = AppColors.hotMagenta;
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFF3D0A1E);
  static const lightOnErrorContainer = Color(0xFFFFB4CC);

  static const lightBackground = AppColors.void_;
  static const lightSurface = AppColors.surface;
  static const lightSurfaceVariant = AppColors.surfaceVariant;

  static const lightOnSurface = AppColors.coolWhite;
  static const lightOnSurfaceVariant = AppColors.coolWhiteMuted;

  static const lightOutline = AppColors.outline;
  static const lightShadow = Color(0xFF000000);
  static const lightInversePrimary = AppColors.cyanDark;
}

class DarkModeColors {
  static const darkPrimary = Color(0xFFFF9050);
  static const darkOnPrimary = Color(0xFF090604);
  static const darkPrimaryContainer = Color(0xFF1E140A);
  static const darkOnPrimaryContainer = Color(0xFFFFAA70);

  static const darkSecondary = Color(0xFFFFD54F);
  static const darkOnSecondary = Color(0xFF2E1A00);

  static const darkTertiary = Color(0xFF5A9EF7);
  static const darkOnTertiary = Color(0xFF0A1F3D);

  static const darkError = Color(0xFFFF6A9A);
  static const darkOnError = Color(0xFF3D0515);
  static const darkErrorContainer = Color(0xFF6B0A25);
  static const darkOnErrorContainer = Color(0xFFFFD6E2);

  static const darkSurface = Color(0xFF0D0A07);
  static const darkOnSurface = Color(0xFFFAF3E8);
  static const darkSurfaceVariant = Color(0xFF171210);
  static const darkOnSurfaceVariant = Color(0xFFA8948A);

  static const darkOutline = Color(0xFF2A1E14);
  static const darkShadow = Color(0xFF000000);
  static const darkInversePrimary = Color(0xFFCC5500);
}

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: LightModeColors.lightPrimary,
    onPrimary: LightModeColors.lightOnPrimary,
    primaryContainer: LightModeColors.lightPrimaryContainer,
    onPrimaryContainer: LightModeColors.lightOnPrimaryContainer,
    secondary: LightModeColors.lightSecondary,
    onSecondary: LightModeColors.lightOnSecondary,
    tertiary: LightModeColors.lightTertiary,
    onTertiary: LightModeColors.lightOnTertiary,
    error: LightModeColors.lightError,
    onError: LightModeColors.lightOnError,
    errorContainer: LightModeColors.lightErrorContainer,
    onErrorContainer: LightModeColors.lightOnErrorContainer,
    surface: LightModeColors.lightSurface,
    onSurface: LightModeColors.lightOnSurface,
    surfaceContainerHighest: LightModeColors.lightSurfaceVariant,
    onSurfaceVariant: LightModeColors.lightOnSurfaceVariant,
    outline: LightModeColors.lightOutline,
    shadow: LightModeColors.lightShadow,
    inversePrimary: LightModeColors.lightInversePrimary,
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: LightModeColors.lightBackground,

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.neonCyan,
      foregroundColor: AppColors.void_,
      textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 15),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.neonCyan,
      foregroundColor: AppColors.void_,
      elevation: 0,
      textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 15),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.neonCyan,
      side: const BorderSide(color: AppColors.neonCyan, width: 1.5),
      textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 15),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.neonCyan,
      textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14),
    ),
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.coolWhite,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.rajdhani(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: AppColors.coolWhite,
      letterSpacing: 2.5,
    ),
  ),

  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: AppColors.outline.withOpacity(0.6), width: 1),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.neonCyan,
    foregroundColor: AppColors.void_,
    elevation: 4,
    shape: CircleBorder(),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: AppColors.surfaceVariant,
    selectedColor: AppColors.neonCyan.withOpacity(0.12),
    side: BorderSide(color: AppColors.outline, width: 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    labelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500),
    checkmarkColor: AppColors.neonCyan,
    showCheckmark: false,
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: AppColors.outline, width: 1),
    ),
    titleTextStyle: GoogleFonts.rajdhani(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.coolWhite,
      letterSpacing: 1.5,
    ),
    contentTextStyle: GoogleFonts.dmSans(
      fontSize: 14,
      color: AppColors.coolWhiteMuted,
    ),
  ),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.surfaceElevated,
    contentTextStyle: GoogleFonts.dmSans(
      fontSize: 14,
      color: AppColors.coolWhite,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    behavior: SnackBarBehavior.floating,
  ),

  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  ),

  popupMenuTheme: PopupMenuThemeData(
    color: AppColors.surfaceVariant,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: AppColors.outline, width: 1),
    ),
  ),

  dividerTheme: const DividerThemeData(
    color: AppColors.outline,
    thickness: 1,
    space: 1,
  ),

  iconTheme: const IconThemeData(color: AppColors.coolWhiteMuted, size: 24),

  textTheme: _buildTextTheme(),
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: DarkModeColors.darkPrimary,
    onPrimary: DarkModeColors.darkOnPrimary,
    primaryContainer: DarkModeColors.darkPrimaryContainer,
    onPrimaryContainer: DarkModeColors.darkOnPrimaryContainer,
    secondary: DarkModeColors.darkSecondary,
    onSecondary: DarkModeColors.darkOnSecondary,
    tertiary: DarkModeColors.darkTertiary,
    onTertiary: DarkModeColors.darkOnTertiary,
    error: DarkModeColors.darkError,
    onError: DarkModeColors.darkOnError,
    errorContainer: DarkModeColors.darkErrorContainer,
    onErrorContainer: DarkModeColors.darkOnErrorContainer,
    surface: DarkModeColors.darkSurface,
    onSurface: DarkModeColors.darkOnSurface,
    surfaceContainerHighest: DarkModeColors.darkSurfaceVariant,
    onSurfaceVariant: DarkModeColors.darkOnSurfaceVariant,
    outline: DarkModeColors.darkOutline,
    shadow: DarkModeColors.darkShadow,
    inversePrimary: DarkModeColors.darkInversePrimary,
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF040609),

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: DarkModeColors.darkOnSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.rajdhani(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: DarkModeColors.darkOnSurface,
      letterSpacing: 2.5,
    ),
  ),

  cardTheme: CardThemeData(
    elevation: 0,
    color: DarkModeColors.darkSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: DarkModeColors.darkOutline.withOpacity(0.5),
        width: 1,
      ),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: DarkModeColors.darkPrimary,
      foregroundColor: DarkModeColors.darkOnPrimary,
      textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 15),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: DarkModeColors.darkPrimary,
      foregroundColor: DarkModeColors.darkOnPrimary,
      elevation: 0,
      textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 15),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: DarkModeColors.darkPrimary,
    foregroundColor: DarkModeColors.darkOnPrimary,
    elevation: 4,
    shape: const CircleBorder(),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: DarkModeColors.darkSurfaceVariant,
    selectedColor: DarkModeColors.darkPrimary.withOpacity(0.12),
    side: BorderSide(color: DarkModeColors.darkOutline, width: 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    labelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500),
    checkmarkColor: DarkModeColors.darkPrimary,
    showCheckmark: false,
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: DarkModeColors.darkSurface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: DarkModeColors.darkOutline, width: 1),
    ),
  ),

  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: DarkModeColors.darkSurface,
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  ),

  popupMenuTheme: PopupMenuThemeData(
    color: DarkModeColors.darkSurfaceVariant,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: DarkModeColors.darkOutline, width: 1),
    ),
  ),

  textTheme: _buildTextTheme(),
);

TextTheme _buildTextTheme() {
  return TextTheme(
    displayLarge: GoogleFonts.rajdhani(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.w700,
      letterSpacing: 3,
    ),
    displayMedium: GoogleFonts.rajdhani(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
    ),
    displaySmall: GoogleFonts.rajdhani(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),

    headlineLarge: GoogleFonts.rajdhani(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
    headlineMedium: GoogleFonts.rajdhani(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w600,
      letterSpacing: 1,
    ),
    headlineSmall: GoogleFonts.rajdhani(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
    ),

    titleLarge: GoogleFonts.dmSans(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.dmSans(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.dmSans(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
    ),

    labelLarge: GoogleFonts.dmSans(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.dmSans(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.dmSans(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),

    bodyLarge: GoogleFonts.dmSans(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: GoogleFonts.dmSans(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
  );
}
