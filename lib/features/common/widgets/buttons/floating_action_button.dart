import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';

/// Custom floating action button with Onflix branding and enhanced functionality
class OnflixFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget? child;
  final IconData? icon;
  final String? tooltip;
  final bool mini;
  final bool extended;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? splashColor;
  final double? elevation;
  final double? focusElevation;
  final double? hoverElevation;
  final double? highlightElevation;
  final double? disabledElevation;
  final ShapeBorder? shape;
  final bool isExtended;
  final bool autofocus;
  final MaterialTapTargetSize? materialTapTargetSize;
  final bool enableFeedback;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool showShadow;
  final Object? heroTag;

  const OnflixFloatingActionButton({
    super.key,
    this.onPressed,
    this.onLongPress,
    this.child,
    this.icon,
    this.tooltip,
    this.mini = false,
    this.extended = false,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.splashColor,
    this.elevation,
    this.focusElevation,
    this.hoverElevation,
    this.highlightElevation,
    this.disabledElevation,
    this.shape,
    this.isExtended = false,
    this.autofocus = false,
    this.materialTapTargetSize,
    this.enableFeedback = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.showShadow = true,
    this.heroTag,
  }) : assert(
          child != null || icon != null,
          'Either child or icon must be provided',
        );

  // Named constructors for common use cases
  const OnflixFloatingActionButton.play({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.tooltip = 'Play',
    this.mini = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.showShadow = true,
    this.heroTag,
  })  : child = null,
        icon = LucideIcons.play,
        extended = false,
        label = null,
        splashColor = null,
        focusElevation = null,
        hoverElevation = null,
        highlightElevation = null,
        disabledElevation = null,
        shape = null,
        isExtended = false,
        autofocus = false,
        materialTapTargetSize = null,
        enableFeedback = true;

  const OnflixFloatingActionButton.add({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.tooltip = 'Add to Watchlist',
    this.mini = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.showShadow = true,
    this.heroTag,
  })  : child = null,
        icon = LucideIcons.plus,
        extended = false,
        label = null,
        splashColor = null,
        focusElevation = null,
        hoverElevation = null,
        highlightElevation = null,
        disabledElevation = null,
        shape = null,
        isExtended = false,
        autofocus = false,
        materialTapTargetSize = null,
        enableFeedback = true;

  const OnflixFloatingActionButton.download({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.tooltip = 'Download',
    this.mini = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.showShadow = true,
    this.heroTag,
  })  : child = null,
        icon = LucideIcons.download,
        extended = false,
        label = null,
        splashColor = null,
        focusElevation = null,
        hoverElevation = null,
        highlightElevation = null,
        disabledElevation = null,
        shape = null,
        isExtended = false,
        autofocus = false,
        materialTapTargetSize = null,
        enableFeedback = true;

  const OnflixFloatingActionButton.extended({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.onLongPress,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.showShadow = true,
    this.heroTag,
  })  : child = null,
        mini = false,
        extended = true,
        splashColor = null,
        focusElevation = null,
        hoverElevation = null,
        highlightElevation = null,
        disabledElevation = null,
        shape = null,
        isExtended = true,
        autofocus = false,
        materialTapTargetSize = null,
        enableFeedback = true;

  @override
  State<OnflixFloatingActionButton> createState() =>
      _OnflixFloatingActionButtonState();
}

class _OnflixFloatingActionButtonState extends State<OnflixFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: widget.animationCurve,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
    if (widget.icon == LucideIcons.play) {
      _rotationController.forward().then((_) {
        _rotationController.reverse();
      });
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget fabWidget;

    if (widget.extended || widget.isExtended) {
      fabWidget = FloatingActionButton.extended(
        onPressed: widget.onPressed,
        icon: widget.icon != null ? Icon(widget.icon) : null,
        label: Text(widget.label ?? ''),
        tooltip: widget.tooltip,
        backgroundColor: widget.backgroundColor ?? OnflixColors.primary,
        foregroundColor: widget.foregroundColor ?? OnflixColors.white,
        splashColor: widget.splashColor,
        elevation: widget.elevation ?? (widget.showShadow ? 6 : 0),
        focusElevation: widget.focusElevation,
        hoverElevation: widget.hoverElevation,
        highlightElevation: widget.highlightElevation,
        disabledElevation: widget.disabledElevation ?? 0,
        shape: widget.shape ?? _getDefaultShape(),
        autofocus: widget.autofocus,
        materialTapTargetSize: widget.materialTapTargetSize,
        enableFeedback: widget.enableFeedback,
        heroTag: widget.heroTag ?? "onflix_fab_${widget.hashCode}",
      );
    } else {
      fabWidget = FloatingActionButton(
        onPressed: widget.onPressed,
        tooltip: widget.tooltip,
        mini: widget.mini,
        backgroundColor: widget.backgroundColor ?? OnflixColors.primary,
        foregroundColor: widget.foregroundColor ?? OnflixColors.white,
        splashColor: widget.splashColor,
        elevation: widget.elevation ?? (widget.showShadow ? 6 : 0),
        focusElevation: widget.focusElevation,
        hoverElevation: widget.hoverElevation,
        highlightElevation: widget.highlightElevation,
        disabledElevation: widget.disabledElevation ?? 0,
        shape: widget.shape ?? _getDefaultShape(),
        autofocus: widget.autofocus,
        materialTapTargetSize: widget.materialTapTargetSize,
        enableFeedback: widget.enableFeedback,
        heroTag: widget.heroTag ?? "onflix_fab_${widget.hashCode}",
        child: widget.child ?? (widget.icon != null ? Icon(widget.icon) : null),
      );
    }

    // Wrap with gesture detector for custom animations
    fabWidget = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPress,
      child: fabWidget,
    );

    // Apply animations
    fabWidget = AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: child,
          ),
        );
      },
      child: fabWidget,
    );

    // Add entrance animation
    return fabWidget
        .animate()
        .scale(
          duration: 300.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(
          duration: 200.ms,
        );
  }

  ShapeBorder _getDefaultShape() {
    if (widget.extended || widget.isExtended) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      );
    }

    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(widget.mini ? 12 : 16),
    );
  }
}

/// Specialized FAB for video play actions with enhanced visual feedback
class PlayFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isPlaying;
  final bool isLoading;
  final double? size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PlayFloatingActionButton({
    super.key,
    this.onPressed,
    this.isPlaying = false,
    this.isLoading = false,
    this.size,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<PlayFloatingActionButton> createState() =>
      _PlayFloatingActionButtonState();
}

class _PlayFloatingActionButtonState extends State<PlayFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(PlayFloatingActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;

    if (widget.isLoading) {
      iconWidget = SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.foregroundColor ?? OnflixColors.white,
          ),
        ),
      );
    } else {
      iconWidget = AnimatedBuilder(
        animation: _iconAnimation,
        builder: (context, child) {
          return Icon(
            widget.isPlaying ? LucideIcons.pause : LucideIcons.play,
            size: (widget.size ?? 56) * 0.4,
          );
        },
      );
    }

    return OnflixFloatingActionButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      backgroundColor: widget.backgroundColor ?? OnflixColors.primary,
      foregroundColor: widget.foregroundColor ?? OnflixColors.white,
      tooltip: widget.isPlaying ? 'Pause' : 'Play',
      child: iconWidget,
    );
  }
}
