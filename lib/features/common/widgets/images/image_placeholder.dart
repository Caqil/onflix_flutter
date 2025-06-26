import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../buttons/icon_button_widget.dart';

/// Image placeholder widget for loading states and error handling
class ImagePlaceholder extends StatefulWidget {
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final Widget? customIcon;
  final String? text;
  final TextStyle? textStyle;
  final bool showShimmer;
  final bool showProgress;
  final bool showIcon;
  final BorderRadius? borderRadius;
  final Border? border;
  final PlaceholderType type;
  final VoidCallback? onTap;
  final VoidCallback? onRetry;
  final double? progress;
  final Duration shimmerDuration;
  final EdgeInsetsGeometry? padding;

  const ImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.customIcon,
    this.text,
    this.textStyle,
    this.showShimmer = true,
    this.showProgress = false,
    this.showIcon = true,
    this.borderRadius,
    this.border,
    this.type = PlaceholderType.loading,
    this.onTap,
    this.onRetry,
    this.progress,
    this.shimmerDuration = const Duration(milliseconds: 1500),
    this.padding,
  });

  // Named constructors for specific placeholder types
  const ImagePlaceholder.loading({
    super.key,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.border,
    this.showShimmer = true,
    this.showProgress = false,
    this.shimmerDuration = const Duration(milliseconds: 1500),
    this.padding,
    this.onTap,
  })  : type = PlaceholderType.loading,
        icon = LucideIcons.image,
        customIcon = null,
        text = null,
        textStyle = null,
        showIcon = false,
        onRetry = null,
        progress = null;

  const ImagePlaceholder.error({
    super.key,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.border,
    this.text = 'Failed to load image',
    this.textStyle,
    this.shimmerDuration = const Duration(milliseconds: 1500),
    this.padding,
    this.onTap,
    this.onRetry,
  })  : type = PlaceholderType.error,
        icon = LucideIcons.imageOff,
        customIcon = null,
        showShimmer = false,
        showProgress = false,
        showIcon = true,
        progress = null;

  const ImagePlaceholder.empty({
    super.key,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.border,
    this.text = 'No image available',
    this.textStyle,
    this.shimmerDuration = const Duration(milliseconds: 1500),
    this.padding,
    this.onTap,
  })  : type = PlaceholderType.empty,
        icon = LucideIcons.imageOff,
        customIcon = null,
        showShimmer = false,
        showProgress = false,
        showIcon = true,
        onRetry = null,
        progress = null;

  const ImagePlaceholder.uploading({
    super.key,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.border,
    this.text = 'Uploading...',
    this.textStyle,
    this.progress,
    this.shimmerDuration = const Duration(milliseconds: 1500),
    this.padding,
    this.onTap,
  })  : type = PlaceholderType.uploading,
        icon = LucideIcons.upload,
        customIcon = null,
        showShimmer = false,
        showProgress = true,
        showIcon = true,
        onRetry = null;

  const ImagePlaceholder.processing({
    super.key,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.border,
    this.text = 'Processing...',
    this.textStyle,
    this.shimmerDuration = const Duration(milliseconds: 1500),
    this.padding,
    this.onTap,
  })  : type = PlaceholderType.processing,
        icon = LucideIcons.loader,
        customIcon = null,
        showShimmer = false,
        showProgress = false,
        showIcon = true,
        onRetry = null,
        progress = null;

  @override
  State<ImagePlaceholder> createState() => _ImagePlaceholderState();
}

class _ImagePlaceholderState extends State<ImagePlaceholder>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Start animations based on placeholder type
    switch (widget.type) {
      case PlaceholderType.loading:
        _pulseController.repeat(reverse: true);
        break;
      case PlaceholderType.processing:
      case PlaceholderType.uploading:
        _rotationController.repeat();
        break;
      case PlaceholderType.error:
      case PlaceholderType.empty:
        // No animation for error and empty states
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget placeholder = _buildPlaceholderContent(context);

    if (widget.showShimmer && widget.type == PlaceholderType.loading) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      placeholder = Shimmer.fromColors(
        baseColor: _getShimmerBaseColor(isDark),
        highlightColor: _getShimmerHighlightColor(isDark),
        period: widget.shimmerDuration,
        child: placeholder,
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? _getDefaultBackgroundColor(),
          borderRadius: widget.borderRadius,
          border: widget.border,
        ),
        child: placeholder,
      ),
    );
  }

  Widget _buildPlaceholderContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showIcon &&
              (widget.icon != null || widget.customIcon != null))
            _buildIcon(context),
          if (widget.text != null) ...[
            if (widget.showIcon) const SizedBox(height: 8),
            _buildText(context),
          ],
          if (widget.showProgress && widget.progress != null) ...[
            const SizedBox(height: 12),
            _buildProgressIndicator(context),
          ],
          if (widget.onRetry != null &&
              widget.type == PlaceholderType.error) ...[
            const SizedBox(height: 12),
            _buildRetryButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    Widget iconWidget;

    if (widget.customIcon != null) {
      iconWidget = widget.customIcon!;
    } else if (widget.icon != null) {
      iconWidget = Icon(
        widget.icon!,
        size: _getIconSize(),
        color: widget.foregroundColor ?? _getDefaultForegroundColor(),
      );
    } else {
      iconWidget = const SizedBox.shrink();
    }

    // Apply animations based on type
    switch (widget.type) {
      case PlaceholderType.loading:
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            );
          },
          child: iconWidget,
        );

      case PlaceholderType.processing:
      case PlaceholderType.uploading:
        return AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: child,
            );
          },
          child: iconWidget,
        );

      case PlaceholderType.error:
        return iconWidget.animate().shake(
              duration: 500.ms,
              curve: Curves.easeInOut,
            );

      case PlaceholderType.empty:
      default:
        return iconWidget;
    }
  }

  Widget _buildText(BuildContext context) {
    return Text(
      widget.text!,
      style: widget.textStyle ?? _getDefaultTextStyle(context),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 4,
          child: LinearProgressIndicator(
            value: widget.progress,
            backgroundColor: OnflixColors.lightGray.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.foregroundColor ?? OnflixColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${((widget.progress ?? 0) * 100).round()}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: widget.foregroundColor ?? _getDefaultForegroundColor(),
              ),
        ),
      ],
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return OnflixIconButton(
      icon: LucideIcons.refreshCw,
      onPressed: widget.onRetry,
      style: IconButtonStyle.filled,
      backgroundColor: OnflixColors.primary,
      iconColor: OnflixColors.white,
      tooltip: 'Retry',
    );
  }

  Color _getDefaultBackgroundColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (widget.type) {
      case PlaceholderType.error:
        return OnflixColors.error.withOpacity(isDark ? 0.1 : 0.05);
      case PlaceholderType.loading:
      case PlaceholderType.processing:
      case PlaceholderType.uploading:
        return isDark ? OnflixColors.mediumGray : OnflixColors.veryLightGray;
      case PlaceholderType.empty:
        return isDark
            ? OnflixColors.darkGray
            : OnflixColors.lightGray.withOpacity(0.3);
    }
  }

  Color _getDefaultForegroundColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (widget.type) {
      case PlaceholderType.error:
        return OnflixColors.error;
      case PlaceholderType.loading:
      case PlaceholderType.processing:
      case PlaceholderType.uploading:
        return isDark ? OnflixColors.lightGray : OnflixColors.mediumGray;
      case PlaceholderType.empty:
        return OnflixColors.lightGray;
    }
  }

  TextStyle _getDefaultTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
              color: widget.foregroundColor ?? _getDefaultForegroundColor(),
              fontWeight: FontWeight.w500,
            ) ??
        const TextStyle();
  }

  double _getIconSize() {
    if (widget.width != null && widget.height != null) {
      final minDimension =
          widget.width! < widget.height! ? widget.width! : widget.height!;
      return (minDimension * 0.3).clamp(16.0, 48.0);
    }
    return 32.0;
  }

  Color _getShimmerBaseColor(bool isDark) {
    return isDark
        ? OnflixColors.mediumGray.withOpacity(0.3)
        : OnflixColors.veryLightGray.withOpacity(0.3);
  }

  Color _getShimmerHighlightColor(bool isDark) {
    return isDark
        ? OnflixColors.lightGray.withOpacity(0.1)
        : OnflixColors.white.withOpacity(0.8);
  }
}

/// Animated placeholder with custom animations
class AnimatedImagePlaceholder extends StatefulWidget {
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final PlaceholderAnimationType animationType;
  final Duration animationDuration;
  final String? text;

  const AnimatedImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.animationType = PlaceholderAnimationType.pulse,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.text,
  });

  @override
  State<AnimatedImagePlaceholder> createState() =>
      _AnimatedImagePlaceholderState();
}

class _AnimatedImagePlaceholderState extends State<AnimatedImagePlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    switch (widget.animationType) {
      case PlaceholderAnimationType.pulse:
        _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _controller.repeat(reverse: true);
        break;

      case PlaceholderAnimationType.wave:
        _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _controller.repeat();
        break;

      case PlaceholderAnimationType.fade:
        _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _controller.repeat(reverse: true);
        break;
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: (widget.backgroundColor ?? OnflixColors.mediumGray)
                .withOpacity(_animation.value),
            borderRadius: widget.borderRadius,
          ),
          child: widget.text != null
              ? Center(
                  child: Text(
                    widget.text!,
                    style: TextStyle(
                      color: widget.foregroundColor ?? OnflixColors.lightGray,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

/// Placeholder type enumeration
enum PlaceholderType {
  loading,
  error,
  empty,
  uploading,
  processing,
}

/// Placeholder animation type enumeration
enum PlaceholderAnimationType {
  pulse,
  wave,
  fade,
}
