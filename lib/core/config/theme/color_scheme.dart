import 'package:flutter/widgets.dart';

class OnflixColors {
  // Netflix Brand Colors
  static const Color primary = Color(0xFFE50914);
  static const Color primaryLight = Color(0xFFFF4458);
  static const Color primaryDark = Color(0xFFB20710);

  // Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color darkGray = Color(0xFF141414);
  static const Color mediumGray = Color(0xFF333333);
  static const Color lightGray = Color(0xFF8C8C8C);
  static const Color veryLightGray = Color(0xFFE5E5E5);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);

  // Glass Effect Colors
  static const Color glass = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x1A000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE50914), Color(0xFFB20710)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkOverlay = LinearGradient(
    colors: [Color(0x00000000), Color(0x99000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
