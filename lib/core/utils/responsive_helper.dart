import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../config/theme/responsive_breakpoints.dart';

class ResponsiveHelper {
  // Private constructor to prevent instantiation
  ResponsiveHelper._();

  // Breakpoint checks
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < ResponsiveBreakpoints.tablet;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.tablet &&
        width < ResponsiveBreakpoints.desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.desktop;
  }

  static bool isUltraWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.ultraWide;
  }

  // Content grid columns
  static int getContentGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ResponsiveBreakpoints.getContentGridColumns(width);
  }

  // Responsive values
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? ultraWide,
  }) {
    if (isUltraWide(context) && ultraWide != null) return ultraWide;
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  // Font size scaling
  static double getScaledFontSize(BuildContext context, double baseFontSize) {
    return responsive(
      context,
      mobile: baseFontSize * 0.9,
      tablet: baseFontSize,
      desktop: baseFontSize * 1.1,
      ultraWide: baseFontSize * 1.2,
    );
  }

  // Padding scaling
  static double getScaledPadding(BuildContext context, double basePadding) {
    return responsive(
      context,
      mobile: basePadding * 0.8,
      tablet: basePadding,
      desktop: basePadding * 1.2,
      ultraWide: basePadding * 1.5,
    );
  }

  // Icon size scaling
  static double getScaledIconSize(BuildContext context, double baseIconSize) {
    return responsive(
      context,
      mobile: baseIconSize * 0.9,
      tablet: baseIconSize,
      desktop: baseIconSize * 1.1,
      ultraWide: baseIconSize * 1.2,
    );
  }

  // Content width constraints
  static double getMaxContentWidth(BuildContext context) {
    return responsive(
      context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1200,
      ultraWide: 1600,
    );
  }

  // Sidebar width
  static double getSidebarWidth(BuildContext context) {
    return responsive(
      context,
      mobile: 0, // Hidden on mobile
      tablet: 200,
      desktop: 240,
      ultraWide: 280,
    );
  }

  // Navigation height
  static double getNavigationHeight(BuildContext context) {
    return responsive(
      context,
      mobile: 60,
      tablet: 64,
      desktop: 68,
      ultraWide: 72,
    );
  }

  // Card dimensions
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = getContentGridColumns(context);
    final padding = getScaledPadding(context, 16);

    return (screenWidth - (padding * (columns + 1))) / columns;
  }

  static double getCardHeight(BuildContext context) {
    final cardWidth = getCardWidth(context);
    return cardWidth * (9 / 16); // 16:9 aspect ratio
  }

  // Modal dimensions
  static double getModalWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return responsive(
      context,
      mobile: screenWidth * 0.95,
      tablet: math.min(600, screenWidth * 0.8),
      desktop: math.min(800, screenWidth * 0.7),
      ultraWide: math.min(1000, screenWidth * 0.6),
    );
  }

  static double getModalHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return responsive(
      context,
      mobile: screenHeight * 0.9,
      tablet: screenHeight * 0.8,
      desktop: screenHeight * 0.85,
      ultraWide: screenHeight * 0.8,
    );
  }

  // Player dimensions
  static double getPlayerAspectRatio(BuildContext context) {
    return responsive(
      context,
      mobile: 16 / 9,
      tablet: 16 / 9,
      desktop: 21 / 9, // Ultra-wide for desktop
      ultraWide: 21 / 9,
    );
  }

  // Grid spacing
  static double getGridSpacing(BuildContext context) {
    return responsive(
      context,
      mobile: 8,
      tablet: 12,
      desktop: 16,
      ultraWide: 20,
    );
  }

  // Animation durations
  static Duration getAnimationDuration(BuildContext context) {
    return responsive(
      context,
      mobile: const Duration(milliseconds: 200),
      tablet: const Duration(milliseconds: 250),
      desktop: const Duration(milliseconds: 300),
      ultraWide: const Duration(milliseconds: 350),
    );
  }

  // Text scaling
  static double getTextScaleFactor(BuildContext context) {
    return responsive(
      context,
      mobile: 0.9,
      tablet: 1.0,
      desktop: 1.1,
      ultraWide: 1.2,
    );
  }

  // Safe area handling
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final basePadding = getScaledPadding(context, 16);

    return EdgeInsets.only(
      left: math.max(padding.left, basePadding),
      top: math.max(padding.top, basePadding),
      right: math.max(padding.right, basePadding),
      bottom: math.max(padding.bottom, basePadding),
    );
  }

  // Orientation helpers
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  // Device pixel ratio
  static double getDevicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  // High DPI detection
  static bool isHighDPI(BuildContext context) {
    return getDevicePixelRatio(context) > 2.0;
  }
}
