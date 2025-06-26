import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
/// Gradient overlay widget for creating various gradient effects over content
class GradientOverlay extends StatelessWidget {
  final Widget? child;
  final Gradient? gradient;
  final GradientType type;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<Color>? colors;
  final List<double>? stops;
  final double opacity;
  final BlendMode blendMode;
  final bool isAnimated;
  final Duration animationDuration;
  final Curve animationCurve;

  const GradientOverlay({
    super.key,
    this.child,
    this.gradient,
    this.type = GradientType.linear,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.colors,
    this.stops,
    this.opacity = 1.0,
    this.blendMode = BlendMode.srcOver,
    this.isAnimated = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  // Named constructors for common overlay types
  const GradientOverlay.dark({
    super.key,
    this.child,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.opacity = 0.7,
    this.blendMode = BlendMode.srcOver,
    this.isAnimated = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.stops,
  })  : type = GradientType.linear,
        gradient = null,
        colors = const [Colors.transparent, Colors.black];

  const GradientOverlay.darkTop({
    super.key,
    this.child,
    this.opacity = 0.7,
    this.blendMode = BlendMode.srcOver,
    this.isAnimated = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.stops,
  })  : type = GradientType.linear,
        gradient = null,
        colors = const [Colors.black, Colors.transparent],
        begin = Alignment.topCenter,
        end = Alignment.bottomCenter;

  const GradientOverlay.darkBottom({
    super.key,
    this.child,
    this.opacity = 0.7,
    this.blendMode = BlendMode.srcOver,
    this.isAnimated = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.stops,
  })  : type = GradientType.linear,
        gradient = null,
        colors = const [Colors.transparent, Colors.black],
        begin = Alignment.topCenter,
        end = Alignment.bottomCenter;

  const GradientOverlay.darkRadial({
    super.key,
    this.child,
    this.opacity = 0.6,
    this.blendMode = BlendMode.srcOver,
    this.isAnimated = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.stops,
  })  : type = GradientType.radial,
        gradient = null,
        colors = const [Colors.transparent, Colors.black87],
        begin = Alignment.center,
        end = Alignment.bottomRight;

  const GradientOverlay.primary({
    super.key,
    this.child,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.opacity = 0.8,
    this.blendMode = BlendMode.srcOver,
    this.isAnimated = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.stops,
  })  : type = GradientType.linear,
        gradient = null,
        colors = const [OnflixColors.primary, OnflixColors.primaryDark];

  const GradientOverlay.heroOverlay({
    super.key,
    this.child,
    this.opacity = 1.0,
    this.blendMode = BlendMode.srcOver,
    this.isAnimated = true,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeOut,
    this.stops,
  })  : type = GradientType.linear,
        gradient = null,
        colors = const [
          Colors.transparent,
          Color(0x30000000),
          Color(0x80000000),
        ],
        begin = Alignment.topCenter,
        end = Alignment.bottomCenter;

  const GradientOverlay.glass({
    super.key,
    this.child,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.opacity = 0.1,
    this.blendMode = BlendMode.srcOver,
    this.isAnimated = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.stops,
  })  : type = GradientType.linear,
        gradient = null,
        colors = const [OnflixColors.glass, Colors.transparent];

  const GradientOverlay.shimmer({
    super.key,
    this.child,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.opacity = 0.3,
    this.blendMode = BlendMode.srcOver,
    this.isAnimated = true,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.animationCurve = Curves.easeInOut,
    this.stops = const [0.0, 0.5, 1.0],
  })  : type = GradientType.linear,
        gradient = null,
        colors = const [
          Colors.transparent,
          Colors.white24,
          Colors.transparent,
        ];

  @override
  Widget build(BuildContext context) {
    Widget overlayWidget = Container(
      decoration: BoxDecoration(
        gradient: _buildGradient(),
      ),
      child: child,
    );

    if (isAnimated) {
      overlayWidget = _buildAnimatedOverlay(overlayWidget);
    }

    if (opacity < 1.0) {
      overlayWidget = Opacity(
        opacity: opacity,
        child: overlayWidget,
      );
    }

    return overlayWidget;
  }

  Widget _buildAnimatedOverlay(Widget child) {
    switch (type) {
      case GradientType.linear:
        if (colors != null && colors!.contains(Colors.white24)) {
          // Shimmer effect
          return child
              .animate(
                onPlay: (controller) => controller.repeat(),
              )
              .shimmer(
                duration: animationDuration,
                curve: animationCurve,
              );
        }
        break;
      case GradientType.radial:
      case GradientType.sweep:
        // Pulse effect for radial/sweep gradients
        return child
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .fadeIn(
              duration: animationDuration,
              curve: animationCurve,
            );
    }

    // Default fade animation
    return child.animate().fadeIn(
          duration: animationDuration,
          curve: animationCurve,
        );
  }

  Gradient _buildGradient() {
    if (gradient != null) {
      return gradient!;
    }

    final effectiveColors = colors ?? [Colors.transparent, Colors.black];
    final effectiveStops = stops;

    switch (type) {
      case GradientType.linear:
        return LinearGradient(
          begin: begin,
          end: end,
          colors: effectiveColors,
          stops: effectiveStops,
        );
      case GradientType.radial:
        return RadialGradient(
          center: begin,
          colors: effectiveColors,
          stops: effectiveStops,
          radius: 1.0,
        );
      case GradientType.sweep:
        return SweepGradient(
          center: begin,
          colors: effectiveColors,
          stops: effectiveStops,
        );
    }
  }
}

/// Multi-layer gradient overlay for complex effects
class MultiLayerGradientOverlay extends StatelessWidget {
  final Widget? child;
  final List<GradientLayer> layers;
  final bool isAnimated;
  final Duration animationDuration;

  const MultiLayerGradientOverlay({
    super.key,
    this.child,
    required this.layers,
    this.isAnimated = false,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child ?? const SizedBox.expand();

    for (final layer in layers.reversed) {
      content = Stack(
        children: [
          content,
          Positioned.fill(
            child: GradientOverlay(
              gradient: layer.gradient,
              type: layer.type,
              begin: layer.begin,
              end: layer.end,
              colors: layer.colors,
              stops: layer.stops,
              opacity: layer.opacity,
              blendMode: layer.blendMode,
              isAnimated: isAnimated,
              animationDuration: animationDuration,
            ),
          ),
        ],
      );
    }

    return content;
  }
}

/// Animated gradient overlay with dynamic color transitions
class AnimatedGradientOverlay extends StatefulWidget {
  final Widget? child;
  final List<List<Color>> colorSets;
  final Duration duration;
  final Curve curve;
  final GradientType type;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double>? stops;
  final bool autoReverse;
  final bool repeat;

  const AnimatedGradientOverlay({
    super.key,
    this.child,
    required this.colorSets,
    this.duration = const Duration(seconds: 3),
    this.curve = Curves.easeInOut,
    this.type = GradientType.linear,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.stops,
    this.autoReverse = true,
    this.repeat = true,
  }) : assert(colorSets.length >= 2, 'At least 2 color sets are required');

  @override
  State<AnimatedGradientOverlay> createState() =>
      _AnimatedGradientOverlayState();
}

class _AnimatedGradientOverlayState extends State<AnimatedGradientOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.colorSets.length - 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.repeat) {
      if (widget.autoReverse) {
        _controller.repeat(reverse: true);
      } else {
        _controller.repeat();
      }
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentColors = _interpolateColors(_animation.value);

        return GradientOverlay(
          type: widget.type,
          begin: widget.begin,
          end: widget.end,
          colors: currentColors,
          stops: widget.stops,
          child: widget.child,
        );
      },
    );
  }

  List<Color> _interpolateColors(double t) {
    final index = t.floor();
    final fraction = t - index;

    if (index >= widget.colorSets.length - 1) {
      return widget.colorSets.last;
    }

    final startColors = widget.colorSets[index];
    final endColors = widget.colorSets[index + 1];

    return List.generate(startColors.length, (i) {
      if (i >= endColors.length) return startColors[i];
      return Color.lerp(startColors[i], endColors[i], fraction)!;
    });
  }
}

/// Gradient overlay with blend modes for special effects
class BlendModeGradientOverlay extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final BlendMode blendMode;
  final double opacity;

  const BlendModeGradientOverlay({
    super.key,
    required this.child,
    required this.gradient,
    this.blendMode = BlendMode.overlay,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Opacity(
            opacity: opacity,
            child: Container(
              decoration: BoxDecoration(gradient: gradient),
            ),
          ),
        ),
      ],
    );
  }
}

/// Directional gradient overlay for specific UI patterns
class DirectionalGradientOverlay extends StatelessWidget {
  final Widget? child;
  final GradientDirection direction;
  final Color startColor;
  final Color endColor;
  final double opacity;
  final double intensity;

  const DirectionalGradientOverlay({
    super.key,
    this.child,
    required this.direction,
    this.startColor = Colors.transparent,
    this.endColor = Colors.black,
    this.opacity = 0.7,
    this.intensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final adjustedEndColor = Color.lerp(
      startColor,
      endColor,
      intensity,
    )!;

    return GradientOverlay(
      begin: _getBeginAlignment(),
      end: _getEndAlignment(),
      colors: [startColor, adjustedEndColor],
      opacity: opacity,
      child: child,
    );
  }

  AlignmentGeometry _getBeginAlignment() {
    switch (direction) {
      case GradientDirection.topToBottom:
        return Alignment.topCenter;
      case GradientDirection.bottomToTop:
        return Alignment.bottomCenter;
      case GradientDirection.leftToRight:
        return Alignment.centerLeft;
      case GradientDirection.rightToLeft:
        return Alignment.centerRight;
      case GradientDirection.topLeftToBottomRight:
        return Alignment.topLeft;
      case GradientDirection.topRightToBottomLeft:
        return Alignment.topRight;
      case GradientDirection.bottomLeftToTopRight:
        return Alignment.bottomLeft;
      case GradientDirection.bottomRightToTopLeft:
        return Alignment.bottomRight;
    }
  }

  AlignmentGeometry _getEndAlignment() {
    switch (direction) {
      case GradientDirection.topToBottom:
        return Alignment.bottomCenter;
      case GradientDirection.bottomToTop:
        return Alignment.topCenter;
      case GradientDirection.leftToRight:
        return Alignment.centerRight;
      case GradientDirection.rightToLeft:
        return Alignment.centerLeft;
      case GradientDirection.topLeftToBottomRight:
        return Alignment.bottomRight;
      case GradientDirection.topRightToBottomLeft:
        return Alignment.bottomLeft;
      case GradientDirection.bottomLeftToTopRight:
        return Alignment.topRight;
      case GradientDirection.bottomRightToTopLeft:
        return Alignment.topLeft;
    }
  }
}

/// Gradient layer model for multi-layer overlays
class GradientLayer {
  final Gradient? gradient;
  final GradientType type;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<Color>? colors;
  final List<double>? stops;
  final double opacity;
  final BlendMode blendMode;

  const GradientLayer({
    this.gradient,
    this.type = GradientType.linear,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.colors,
    this.stops,
    this.opacity = 1.0,
    this.blendMode = BlendMode.srcOver,
  });
}

/// Gradient type enumeration
enum GradientType {
  linear,
  radial,
  sweep,
}

/// Gradient direction enumeration
enum GradientDirection {
  topToBottom,
  bottomToTop,
  leftToRight,
  rightToLeft,
  topLeftToBottomRight,
  topRightToBottomLeft,
  bottomLeftToTopRight,
  bottomRightToTopLeft,
}
