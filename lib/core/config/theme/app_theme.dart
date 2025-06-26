import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppTheme {
  static const Color netflixRed = Color(0xFFE50914);
  static const Color netflixBlack = Color(0xFF000000);
  static const Color netflixDarkGray = Color(0xFF141414);
  static const Color netflixMediumGray = Color(0xFF333333);
  static const Color netflixLightGray = Color(0xFF8C8C8C);
  static const Color netflixWhite = Color(0xFFFFFFFF);

  static ShadThemeData get lightTheme {
    return ShadThemeData(
      brightness: Brightness.light,
      colorScheme: const ShadNeutralColorScheme.light(
        primary: netflixRed,
        primaryForeground: netflixWhite,
        secondary: Color(0xFFF8F9FA),
        secondaryForeground: Color(0xFF212529),
        destructive: Color(0xFFDC3545),
        destructiveForeground: netflixWhite,
        muted: Color(0xFFF8F9FA),
        mutedForeground: Color(0xFF6C757D),
        accent: Color(0xFFF8F9FA),
        accentForeground: Color(0xFF212529),
        popover: netflixWhite,
        popoverForeground: Color(0xFF212529),
        card: netflixWhite,
        cardForeground: Color(0xFF212529),
        border: Color(0xFFDEE2E6),
        input: Color(0xFFDEE2E6),
        background: netflixWhite,
        foreground: Color(0xFF212529),
      ),
      textTheme: ShadTextTheme(
        family: 'NetflixSans',
        package: null,
      ),
      radius: BorderRadius.circular(8.0),
    );
  }

  static ShadThemeData get darkTheme {
    return ShadThemeData(
      brightness: Brightness.dark,
      colorScheme: const ShadNeutralColorScheme.dark(
        primary: netflixRed,
        primaryForeground: netflixWhite,
        secondary: netflixDarkGray,
        secondaryForeground: Color(0xFFF8F9FA),
        destructive: Color(0xFFDC3545),
        destructiveForeground: netflixWhite,
        muted: netflixMediumGray,
        mutedForeground: netflixLightGray,
        accent: netflixDarkGray,
        accentForeground: Color(0xFFF8F9FA),
        popover: netflixDarkGray,
        popoverForeground: Color(0xFFF8F9FA),
        card: netflixDarkGray,
        cardForeground: Color(0xFFF8F9FA),
        border: netflixMediumGray,
        input: netflixMediumGray,
        background: netflixBlack,
        foreground: Color(0xFFF8F9FA),
      ),
      primaryColorScheme:
          ShadColorScheme.fromName('red', brightness: Brightness.dark),
      textTheme: const ShadTextTheme(
        family: 'NetflixSans',
        package: null,
      ),
      radius: 8.0,
    );
  }
}
