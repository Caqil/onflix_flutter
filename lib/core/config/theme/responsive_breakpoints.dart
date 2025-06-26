class ResponsiveBreakpoints {
  // Breakpoint values in pixels
  static const double mobile = 0;
  static const double tablet = 600;
  static const double desktop = 1200;
  static const double ultraWide = 1920;

  // Helper method to get content grid columns based on screen width
  static int getContentGridColumns(double width) {
    if (width >= ultraWide) {
      return 6; // Ultra-wide displays
    } else if (width >= desktop) {
      return 4; // Desktop
    } else if (width >= tablet) {
      return 3; // Tablet
    } else {
      return 2; // Mobile
    }
  }

  // Helper method to determine device type
  static String getDeviceType(double width) {
    if (width >= ultraWide) {
      return 'ultraWide';
    } else if (width >= desktop) {
      return 'desktop';
    } else if (width >= tablet) {
      return 'tablet';
    } else {
      return 'mobile';
    }
  }

  // Get appropriate font scale for device
  static double getFontScale(double width) {
    if (width >= ultraWide) {
      return 1.2;
    } else if (width >= desktop) {
      return 1.1;
    } else if (width >= tablet) {
      return 1.0;
    } else {
      return 0.9;
    }
  }

  // Get appropriate padding scale for device
  static double getPaddingScale(double width) {
    if (width >= ultraWide) {
      return 1.5;
    } else if (width >= desktop) {
      return 1.2;
    } else if (width >= tablet) {
      return 1.0;
    } else {
      return 0.8;
    }
  }

  // Get maximum content width for different devices
  static double getMaxContentWidth(double screenWidth) {
    if (screenWidth >= ultraWide) {
      return 1600;
    } else if (screenWidth >= desktop) {
      return 1200;
    } else if (screenWidth >= tablet) {
      return 800;
    } else {
      return double.infinity;
    }
  }

  // Get sidebar width for different devices
  static double getSidebarWidth(double screenWidth) {
    if (screenWidth >= ultraWide) {
      return 280;
    } else if (screenWidth >= desktop) {
      return 240;
    } else if (screenWidth >= tablet) {
      return 200;
    } else {
      return 0; // Hidden on mobile
    }
  }

  // Get navigation height for different devices
  static double getNavigationHeight(double screenWidth) {
    if (screenWidth >= ultraWide) {
      return 72;
    } else if (screenWidth >= desktop) {
      return 68;
    } else if (screenWidth >= tablet) {
      return 64;
    } else {
      return 60;
    }
  }

  // Get grid spacing for different devices
  static double getGridSpacing(double screenWidth) {
    if (screenWidth >= ultraWide) {
      return 20;
    } else if (screenWidth >= desktop) {
      return 16;
    } else if (screenWidth >= tablet) {
      return 12;
    } else {
      return 8;
    }
  }

  // Check if screen width is mobile
  static bool isMobile(double width) => width < tablet;

  // Check if screen width is tablet
  static bool isTablet(double width) => width >= tablet && width < desktop;

  // Check if screen width is desktop
  static bool isDesktop(double width) => width >= desktop && width < ultraWide;

  // Check if screen width is ultra-wide
  static bool isUltraWide(double width) => width >= ultraWide;
}
