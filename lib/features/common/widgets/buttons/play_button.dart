import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';

/// Specialized play button widget with enhanced visual feedback and animations
class PlayButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool isPlaying;
  final bool isLoading;
  final bool isPaused;
  final PlayButtonSize size;
  final PlayButtonStyle style;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? elevation;
  final String? tooltip;
  final Duration animationDuration;
  final bool showPulseAnimation;
  final bool showRippleEffect;
  final bool enableHapticFeedback;

  const PlayButton({
    super.key,
    this.onPressed,
    this.onLongPress,
    this.isPlaying = false,
    this.isLoading = false,
    this.isPaused = false,
    this.size = PlayButtonSize.medium,
    this.style = PlayButtonStyle.filled,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.elevation,
    this.tooltip,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showPulseAnimation = true,
    this.showRippleEffect = true,
    this.enableHapticFeedback = true,
  });

  // Named constructors for common use cases
  const PlayButton.large({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.isPlaying = false,
    this.isLoading = false,
    this.isPaused = false,
    this.style = PlayButtonStyle.filled,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.elevation,
    this.tooltip,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showPulseAnimation = true,
    this.showRippleEffect = true,
    this.enableHapticFeedback = true,
  }) : size = PlayButtonSize.large;

  const PlayButton.small({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.isPlaying = false,
    this.isLoading = false,
    this.isPaused = false,
    this.style = PlayButtonStyle.filled,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.elevation,
    this.tooltip,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showPulseAnimation = false,
    this.showRippleEffect = true,
    this.enableHapticFeedback = true,
  }) : size = PlayButtonSize.small;

  const PlayButton.ghost({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.isPlaying = false,
    this.isLoading = false,
    this.isPaused = false,
    this.size = PlayButtonSize.medium,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.elevation,
    this.tooltip,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showPulseAnimation = true,
    this.showRippleEffect = true,
    this.enableHapticFeedback = true,
  }) : style = PlayButtonStyle.ghost;

  const PlayButton.outlined({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.isPlaying = false,
    this.isLoading = false,
    this.isPaused = false,
    this.size = PlayButtonSize.medium,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.elevation,
    this.tooltip,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showPulseAnimation = true,
    this.showRippleEffect = true,
    this.enableHapticFeedback = true,
  }) : style = PlayButtonStyle.outlined;

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _iconController;
  late AnimationController _pulseController;
  late AnimationController _loadingController;
  late AnimationController _rippleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _iconAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _rippleAnimation;


  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Scale animation for press effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    // Icon transition animation
    _iconController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Pulse animation for visual feedback
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Ripple effect animation
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    // Set initial states
    if (widget.isPlaying) {
      _iconController.forward();
    }

    if (widget.isLoading) {
      _loadingController.repeat();
    }

    if (widget.showPulseAnimation && widget.isPlaying) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle playing state changes
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _iconController.forward();
        if (widget.showPulseAnimation) {
          _pulseController.repeat(reverse: true);
        }
      } else {
        _iconController.reverse();
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    // Handle loading state changes
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
        _loadingController.reset();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _iconController.dispose();
    _pulseController.dispose();
    _loadingController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
    });
    _scaleController.forward();

    if (widget.showRippleEffect) {
      _rippleController.forward().then((_) {
        _rippleController.reset();
      });
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
    });
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    setState(() {
    });
    _scaleController.reverse();
  }

  void _handleTap() {
    if (widget.enableHapticFeedback) {
      // Add haptic feedback if available
      // HapticFeedback.lightImpact();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = _getButtonSize();
    final iconSize = _getIconSize();

    Widget iconWidget = _buildIcon(iconSize);

    if (widget.isLoading) {
      iconWidget = AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Icon(
              LucideIcons.loader,
              size: iconSize,
              color: _getEffectiveForegroundColor(context),
            ),
          );
        },
      );
    }

    Widget button = AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        double scale = _scaleAnimation.value;
        if (widget.showPulseAnimation && widget.isPlaying) {
          scale *= _pulseAnimation.value;
        }

        return Transform.scale(
          scale: scale,
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: _buildDecoration(context),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(buttonSize / 2),
              child: InkWell(
                onTap: widget.onPressed != null && !widget.isLoading
                    ? _handleTap
                    : null,
                onLongPress: widget.onLongPress,
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                borderRadius: BorderRadius.circular(buttonSize / 2),
                splashColor: _getSplashColor(context),
                child: Center(child: iconWidget),
              ),
            ),
          ),
        );
      },
    );

    // Add ripple effect overlay
    if (widget.showRippleEffect) {
      button = Stack(
        alignment: Alignment.center,
        children: [
          button,
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_rippleAnimation.value * 0.5),
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getEffectiveForegroundColor(context)
                          .withOpacity(1.0 - _rippleAnimation.value),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    // Add tooltip if provided
    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button
        .animate()
        .fadeIn(
          duration: 200.ms,
          curve: Curves.easeOut,
        )
        .scale(
          duration: 300.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildIcon(double size) {
    IconData iconData;

    if (widget.isLoading) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getEffectiveForegroundColor(context),
          ),
        ),
      );
    }

    if (widget.isPaused) {
      iconData = LucideIcons.pause;
    } else if (widget.isPlaying) {
      iconData = LucideIcons.pause;
    } else {
      iconData = LucideIcons.play;
    }

    return AnimatedBuilder(
      animation: _iconAnimation,
      builder: (context, child) {
        return AnimatedSwitcher(
          duration: widget.animationDuration,
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: animation,
              child: child,
            );
          },
          child: Icon(
            iconData,
            key: ValueKey(iconData),
            size: size,
            color: _getEffectiveForegroundColor(context),
          ),
        );
      },
    );
  }

  BoxDecoration _buildDecoration(BuildContext context) {
    Color backgroundColor = _getEffectiveBackgroundColor(context);

    return BoxDecoration(
      color: backgroundColor,
      shape: BoxShape.circle,
      border: widget.style == PlayButtonStyle.outlined
          ? Border.all(
              color:
                  widget.borderColor ?? _getEffectiveForegroundColor(context),
              width: 2,
            )
          : null,
      boxShadow: _getBoxShadow(context),
      gradient: widget.style == PlayButtonStyle.gradient
          ? OnflixColors.primaryGradient
          : null,
    );
  }

  Color _getEffectiveBackgroundColor(BuildContext context) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    switch (widget.style) {
      case PlayButtonStyle.filled:
      case PlayButtonStyle.gradient:
        return OnflixColors.primary;
      case PlayButtonStyle.ghost:
        return OnflixColors.white.withOpacity(0.1);
      case PlayButtonStyle.outlined:
        return Colors.transparent;
      case PlayButtonStyle.glass:
        return OnflixColors.glass;
    }
  }

  Color _getEffectiveForegroundColor(BuildContext context) {
    if (widget.foregroundColor != null) return widget.foregroundColor!;

    switch (widget.style) {
      case PlayButtonStyle.filled:
      case PlayButtonStyle.gradient:
        return OnflixColors.white;
      case PlayButtonStyle.ghost:
      case PlayButtonStyle.outlined:
      case PlayButtonStyle.glass:
        return OnflixColors.white;
    }
  }

  Color _getSplashColor(BuildContext context) {
    return _getEffectiveForegroundColor(context).withOpacity(0.1);
  }

  List<BoxShadow>? _getBoxShadow(BuildContext context) {
    if (widget.elevation == null && widget.style != PlayButtonStyle.filled) {
      return null;
    }

    final elevation = widget.elevation ?? _getDefaultElevation();

    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
      if (widget.style == PlayButtonStyle.glass)
        BoxShadow(
          color: OnflixColors.white.withOpacity(0.1),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
    ];
  }

  double _getButtonSize() {
    switch (widget.size) {
      case PlayButtonSize.small:
        return 40;
      case PlayButtonSize.medium:
        return 56;
      case PlayButtonSize.large:
        return 72;
      case PlayButtonSize.extraLarge:
        return 96;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case PlayButtonSize.small:
        return 16;
      case PlayButtonSize.medium:
        return 24;
      case PlayButtonSize.large:
        return 32;
      case PlayButtonSize.extraLarge:
        return 40;
    }
  }

  double _getDefaultElevation() {
    switch (widget.style) {
      case PlayButtonStyle.filled:
      case PlayButtonStyle.gradient:
        return 4;
      case PlayButtonStyle.ghost:
      case PlayButtonStyle.outlined:
      case PlayButtonStyle.glass:
        return 0;
    }
  }
}

/// Play button size enumeration
enum PlayButtonSize {
  small,
  medium,
  large,
  extraLarge,
}

/// Play button style enumeration
enum PlayButtonStyle {
  filled,
  ghost,
  outlined,
  gradient,
  glass,
}
