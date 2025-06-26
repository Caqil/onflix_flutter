import 'package:flutter/material.dart';
import 'package:onflix/core/utils/responsive_helper.dart';


/// Responsive layout widget that renders different layouts based on screen size
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? ultraWide;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.ultraWide,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        if (ResponsiveHelper.isUltraWide(context) && ultraWide != null) {
          return ultraWide!;
        }
        
        if (ResponsiveHelper.isDesktop(context) && desktop != null) {
          return desktop!;
        }
        
        if (ResponsiveHelper.isTablet(context) && tablet != null) {
          return tablet!;
        }
        
        return mobile;
      },
    );
  }
}

/// Responsive value builder that provides different values based on screen size
class ResponsiveValue<T> extends StatelessWidget {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? ultraWide;
  final Widget Function(BuildContext context, T value) builder;

  const ResponsiveValue({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.ultraWide,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final value = ResponsiveHelper.responsive<T>(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      ultraWide: ultraWide,
    );

    return builder(context, value);
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry mobile;
  final EdgeInsetsGeometry? tablet;
  final EdgeInsetsGeometry? desktop;
  final EdgeInsetsGeometry? ultraWide;

  const ResponsivePadding({
    super.key,
    required this.child,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.ultraWide,
  });

  factory ResponsivePadding.symmetric({
    Key? key,
    required Widget child,
    double? horizontal,
    double? vertical,
    double? mobileHorizontal,
    double? mobileVertical,
    double? tabletHorizontal,
    double? tabletVertical,
    double? desktopHorizontal,
    double? desktopVertical,
    double? ultraWideHorizontal,
    double? ultraWideVertical,
  }) {
    return ResponsivePadding(
      key: key,
      mobile: EdgeInsets.symmetric(
        horizontal: mobileHorizontal ?? horizontal ?? 0,
        vertical: mobileVertical ?? vertical ?? 0,
      ),
      tablet: EdgeInsets.symmetric(
        horizontal: tabletHorizontal ?? horizontal ?? 0,
        vertical: tabletVertical ?? vertical ?? 0,
      ),
      desktop: EdgeInsets.symmetric(
        horizontal: desktopHorizontal ?? horizontal ?? 0,
        vertical: desktopVertical ?? vertical ?? 0,
      ),
      ultraWide: EdgeInsets.symmetric(
        horizontal: ultraWideHorizontal ?? horizontal ?? 0,
        vertical: ultraWideVertical ?? vertical ?? 0,
      ),
      child: child,
    );
  }

  factory ResponsivePadding.all({
    Key? key,
    required Widget child,
    double? value,
    double? mobile,
    double? tablet,
    double? desktop,
    double? ultraWide,
  }) {
    return ResponsivePadding(
      key: key,
      mobile: EdgeInsets.all(mobile ?? value ?? 0),
      tablet: EdgeInsets.all(tablet ?? value ?? 0),
      desktop: EdgeInsets.all(desktop ?? value ?? 0),
      ultraWide: EdgeInsets.all(ultraWide ?? value ?? 0),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveValue<EdgeInsetsGeometry>(
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      ultraWide: ultraWide,
      builder: (context, padding) {
        return Padding(
          padding: padding,
          child: child,
        );
      },
    );
  }
}

/// Responsive grid view with automatic column count
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final double? runSpacing;
  final double? childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? ultraWideColumns;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.spacing,
    this.runSpacing,
    this.childAspectRatio,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.ultraWideColumns,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveValue<int>(
      mobile: mobileColumns ?? ResponsiveHelper.getContentGridColumns(context),
      tablet: tabletColumns,
      desktop: desktopColumns,
      ultraWide: ultraWideColumns,
      builder: (context, crossAxisCount) {
        return GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: runSpacing ?? ResponsiveHelper.getGridSpacing(context),
          crossAxisSpacing: spacing ?? ResponsiveHelper.getGridSpacing(context),
          childAspectRatio: childAspectRatio ?? 16/9,
          padding: padding,
          physics: physics,
          shrinkWrap: shrinkWrap,
          scrollDirection: scrollDirection,
          children: children,
        );
      },
    );
  }
}

/// Responsive text with automatic scaling
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? mobileSize;
  final double? tabletSize;
  final double? desktopSize;
  final double? ultraWideSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.mobileSize,
    this.tabletSize,
    this.desktopSize,
    this.ultraWideSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveValue<double?>(
      mobile: mobileSize,
      tablet: tabletSize,
      desktop: desktopSize,
      ultraWide: ultraWideSize,
      builder: (context, fontSize) {
        return Text(
          text,
          style: (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
            fontSize: fontSize,
          ),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

/// Responsive container with automatic sizing
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final double? ultraWideWidth;
  final double? mobileHeight;
  final double? tabletHeight;
  final double? desktopHeight;
  final double? ultraWideHeight;
  final EdgeInsetsGeometry? mobilePadding;
  final EdgeInsetsGeometry? tabletPadding;
  final EdgeInsetsGeometry? desktopPadding;
  final EdgeInsetsGeometry? ultraWidePadding;
  final EdgeInsetsGeometry? mobileMargin;
  final EdgeInsetsGeometry? tabletMargin;
  final EdgeInsetsGeometry? desktopMargin;
  final EdgeInsetsGeometry? ultraWideMargin;
  final Decoration? decoration;
  final AlignmentGeometry? alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
    this.ultraWideWidth,
    this.mobileHeight,
    this.tabletHeight,
    this.desktopHeight,
    this.ultraWideHeight,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.ultraWidePadding,
    this.mobileMargin,
    this.tabletMargin,
    this.desktopMargin,
    this.ultraWideMargin,
    this.decoration,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final width = ResponsiveHelper.responsive<double?>(
      context,
      mobile: mobileWidth,
      tablet: tabletWidth,
      desktop: desktopWidth,
      ultraWide: ultraWideWidth,
    );

    final height = ResponsiveHelper.responsive<double?>(
      context,
      mobile: mobileHeight,
      tablet: tabletHeight,
      desktop: desktopHeight,
      ultraWide: ultraWideHeight,
    );

    final padding = ResponsiveHelper.responsive<EdgeInsetsGeometry?>(
      context,
      mobile: mobilePadding,
      tablet: tabletPadding,
      desktop: desktopPadding,
      ultraWide: ultraWidePadding,
    );

    final margin = ResponsiveHelper.responsive<EdgeInsetsGeometry?>(
      context,
      mobile: mobileMargin,
      tablet: tabletMargin,
      desktop: desktopMargin,
      ultraWide: ultraWideMargin,
    );

    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }
}

/// Responsive wrap widget with automatic spacing
class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final WrapAlignment alignment;
  final WrapAlignment runAlignment;
  final WrapCrossAlignment crossAxisAlignment;
  final double? mobileSpacing;
  final double? tabletSpacing;
  final double? desktopSpacing;
  final double? ultraWideSpacing;
  final double? mobileRunSpacing;
  final double? tabletRunSpacing;
  final double? desktopRunSpacing;
  final double? ultraWideRunSpacing;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.mobileSpacing,
    this.tabletSpacing,
    this.desktopSpacing,
    this.ultraWideSpacing,
    this.mobileRunSpacing,
    this.tabletRunSpacing,
    this.desktopRunSpacing,
    this.ultraWideRunSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.responsive<double>(
      context,
      mobile: mobileSpacing ?? 8.0,
      tablet: tabletSpacing ?? 12.0,
      desktop: desktopSpacing ?? 16.0,
      ultraWide: ultraWideSpacing ?? 20.0,
    );

    final runSpacing = ResponsiveHelper.responsive<double>(
      context,
      mobile: mobileRunSpacing ?? 8.0,
      tablet: tabletRunSpacing ?? 12.0,
      desktop: desktopRunSpacing ?? 16.0,
      ultraWide: ultraWideRunSpacing ?? 20.0,
    );

    return Wrap(
      direction: direction,
      alignment: alignment,
      runAlignment: runAlignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: children,
    );
  }
}

/// Responsive column with automatic spacing
class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double? mobileSpacing;
  final double? tabletSpacing;
  final double? desktopSpacing;
  final double? ultraWideSpacing;

  const ResponsiveColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.mobileSpacing,
    this.tabletSpacing,
    this.desktopSpacing,
    this.ultraWideSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.responsive<double>(
      context,
      mobile: mobileSpacing ?? 8.0,
      tablet: tabletSpacing ?? 12.0,
      desktop: desktopSpacing ?? 16.0,
      ultraWide: ultraWideSpacing ?? 20.0,
    );

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spacedChildren,
    );
  }
}

/// Responsive row with automatic spacing
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double? mobileSpacing;
  final double? tabletSpacing;
  final double? desktopSpacing;
  final double? ultraWideSpacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.mobileSpacing,
    this.tabletSpacing,
    this.desktopSpacing,
    this.ultraWideSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.responsive<double>(
      context,
      mobile: mobileSpacing ?? 8.0,
      tablet: tabletSpacing ?? 12.0,
      desktop: desktopSpacing ?? 16.0,
      ultraWide: ultraWideSpacing ?? 20.0,
    );

    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing));
      }
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: spacedChildren,
    );
  }
}

/// Responsive safe area with automatic padding
class ResponsiveSafeArea extends StatelessWidget {
  final Widget child;
  final bool left;
  final bool top;
  final bool right;
  final bool bottom;
  final EdgeInsetsGeometry? minimum;

  const ResponsiveSafeArea({
    super.key,
    required this.child,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      minimum: (minimum ?? ResponsiveHelper.getResponsivePadding(context)) as EdgeInsets,
      child: child,
    );
  }
}