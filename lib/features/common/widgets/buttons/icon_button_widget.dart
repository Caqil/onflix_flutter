import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';


/// Custom icon button widget with consistent styling and enhanced functionality
class OnflixIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final String? tooltip;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? hoverColor;
  final Color? splashColor;
  final double? iconSize;
  final double? buttonSize;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Border? border;
  final bool isSelected;
  final bool isLoading;
  final bool isDisabled;
  final IconButtonVariant variant;
  final IconButtonStyle style;
  final double? elevation;
  final Duration animationDuration;
  final bool enableFeedback;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool showBadge;
  final String? badgeText;
  final Color? badgeColor;

  const OnflixIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.onLongPress,
    this.tooltip,
    this.iconColor,
    this.backgroundColor,
    this.hoverColor,
    this.splashColor,
    this.iconSize,
    this.buttonSize,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
    this.isSelected = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = IconButtonVariant.standard,
    this.style = IconButtonStyle.filled,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 200),
    this.enableFeedback = true,
    this.autofocus = false,
    this.focusNode,
    this.showBadge = false,
    this.badgeText,
    this.badgeColor,
  });

  // Named constructors for common use cases
  const OnflixIconButton.play({
    super.key,
    required this.onPressed,
    this.tooltip = 'Play',
    this.iconColor,
    this.backgroundColor,
    this.iconSize,
    this.buttonSize,
    this.isSelected = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = IconButtonVariant.primary,
    this.style = IconButtonStyle.filled,
    this.animationDuration = const Duration(milliseconds: 200),
  })  : icon = LucideIcons.play,
        onLongPress = null,
        hoverColor = null,
        splashColor = null,
        padding = null,
        margin = null,
        borderRadius = null,
        border = null,
        elevation = null,
        enableFeedback = true,
        autofocus = false,
        focusNode = null,
        showBadge = false,
        badgeText = null,
        badgeColor = null;

  const OnflixIconButton.add({
    super.key,
    required this.onPressed,
    this.tooltip = 'Add to Watchlist',
    this.iconColor,
    this.backgroundColor,
    this.iconSize,
    this.buttonSize,
    this.isSelected = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = IconButtonVariant.standard,
    this.style = IconButtonStyle.outlined,
    this.animationDuration = const Duration(milliseconds: 200),
  })  : icon = LucideIcons.plus,
        onLongPress = null,
        hoverColor = null,
        splashColor = null,
        padding = null,
        margin = null,
        borderRadius = null,
        border = null,
        elevation = null,
        enableFeedback = true,
        autofocus = false,
        focusNode = null,
        showBadge = false,
        badgeText = null,
        badgeColor = null;

  const OnflixIconButton.like({
    super.key,
    required this.onPressed,
    this.tooltip,
    this.isSelected = false,
    this.iconColor,
    this.backgroundColor,
    this.iconSize,
    this.buttonSize,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = IconButtonVariant.standard,
    this.style = IconButtonStyle.ghost,
    this.animationDuration = const Duration(milliseconds: 200),
  })  : icon = LucideIcons.thumbsUp,
        onLongPress = null,
        hoverColor = null,
        splashColor = null,
        padding = null,
        margin = null,
        borderRadius = null,
        border = null,
        elevation = null,
        enableFeedback = true,
        autofocus = false,
        focusNode = null,
        showBadge = false,
        badgeText = null,
        badgeColor = null;

  const OnflixIconButton.download({
    super.key,
    required this.onPressed,
    this.tooltip = 'Download',
    this.iconColor,
    this.backgroundColor,
    this.iconSize,
    this.buttonSize,
    this.isSelected = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = IconButtonVariant.standard,
    this.style = IconButtonStyle.outlined,
    this.animationDuration = const Duration(milliseconds: 200),
    this.showBadge = false,
    this.badgeText,
    this.badgeColor,
  })  : icon = LucideIcons.download,
        onLongPress = null,
        hoverColor = null,
        splashColor = null,
        padding = null,
        margin = null,
        borderRadius = null,
        border = null,
        elevation = null,
        enableFeedback = true,
        autofocus = false,
        focusNode = null;

  @override
  State<OnflixIconButton> createState() => _OnflixIconButtonState();
}

class _OnflixIconButtonState extends State<OnflixIconButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _selectionController;
  late AnimationController _loadingController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _selectionAnimation;
  late Animation<double> _rotationAnimation;

  bool _isHovered = false;

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

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _selectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));

    if (widget.isSelected) {
      _selectionController.forward();
    }

    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  @override
  void didUpdateWidget(OnflixIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }

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
    _selectionController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEffectivelyDisabled = widget.isDisabled || widget.isLoading;

    Widget iconWidget = _buildIcon(context);

    if (widget.isLoading) {
      iconWidget = AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Icon(
              LucideIcons.loader,
              size: widget.iconSize ?? _getDefaultIconSize(),
              color: _getEffectiveIconColor(context),
            ),
          );
        },
      );
    }

    Widget button = Material(
      color: _getEffectiveBackgroundColor(context),
      borderRadius: widget.borderRadius ??
          BorderRadius.circular(_getDefaultBorderRadius()),
      elevation: widget.elevation ?? _getDefaultElevation(),
      child: InkWell(
        onTap: isEffectivelyDisabled ? null : widget.onPressed,
        onLongPress: isEffectivelyDisabled ? null : widget.onLongPress,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onHover: (value) {
          setState(() {
            _isHovered = value;
          });
        },
        borderRadius: widget.borderRadius ??
            BorderRadius.circular(_getDefaultBorderRadius()),
        splashColor: widget.splashColor ?? _getDefaultSplashColor(context),
        hoverColor: widget.hoverColor ?? _getDefaultHoverColor(context),
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        enableFeedback: widget.enableFeedback,
        child: Container(
          width: widget.buttonSize ?? _getDefaultButtonSize(),
          height: widget.buttonSize ?? _getDefaultButtonSize(),
          padding: widget.padding ?? _getDefaultPadding(),
          decoration: BoxDecoration(
            border: widget.border ?? _getDefaultBorder(context),
            borderRadius: widget.borderRadius ??
                BorderRadius.circular(_getDefaultBorderRadius()),
          ),
          child: Center(child: iconWidget),
        ),
      ),
    );

    // Apply scale animation
    button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: button,
    );

    // Apply selection animation
    if (widget.isSelected) {
      button = AnimatedBuilder(
        animation: _selectionAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ??
                  BorderRadius.circular(_getDefaultBorderRadius()),
              boxShadow: [
                BoxShadow(
                  color: OnflixColors.primary
                      .withOpacity(_selectionAnimation.value * 0.3),
                  blurRadius: 8 * _selectionAnimation.value,
                  spreadRadius: 2 * _selectionAnimation.value,
                ),
              ],
            ),
            child: child,
          );
        },
        child: button,
      );
    }

    // Add badge if needed
    if (widget.showBadge && widget.badgeText != null) {
      button = Badge(
        label: Text(
          widget.badgeText!,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
        backgroundColor: widget.badgeColor ?? OnflixColors.primary,
        child: button,
      );
    }

    // Apply margin
    if (widget.margin != null) {
      button = Padding(
        padding: widget.margin!,
        child: button,
      );
    }

    // Add tooltip
    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }

  Widget _buildIcon(BuildContext context) {
    IconData effectiveIcon = widget.icon;

    // Handle special cases for selected state
    if (widget.isSelected) {
      switch (widget.icon) {
        case LucideIcons.thumbsUp:
          effectiveIcon = LucideIcons.thumbsUp;
          break;
        case LucideIcons.plus:
          effectiveIcon = LucideIcons.check;
          break;
        case LucideIcons.bookmark:
          effectiveIcon = LucideIcons.bookmarkCheck;
          break;
      }
    }

    return Icon(
      effectiveIcon,
      size: widget.iconSize ?? _getDefaultIconSize(),
      color: _getEffectiveIconColor(context),
    );
  }

  Color _getEffectiveIconColor(BuildContext context) {
    if (widget.iconColor != null) return widget.iconColor!;

    final theme = Theme.of(context);

    if (widget.isSelected) {
      switch (widget.variant) {
        case IconButtonVariant.primary:
          return OnflixColors.white;
        case IconButtonVariant.standard:
          return OnflixColors.primary;
        case IconButtonVariant.destructive:
          return OnflixColors.error;
      }
    }

    switch (widget.style) {
      case IconButtonStyle.filled:
        return widget.variant == IconButtonVariant.primary
            ? OnflixColors.white
            : theme.colorScheme.onSurface;
      case IconButtonStyle.outlined:
      case IconButtonStyle.ghost:
        return widget.variant == IconButtonVariant.primary
            ? OnflixColors.primary
            : theme.colorScheme.onSurface;
    }
  }

  Color _getEffectiveBackgroundColor(BuildContext context) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    final theme = Theme.of(context);

    if (widget.isSelected) {
      switch (widget.variant) {
        case IconButtonVariant.primary:
          return OnflixColors.primary;
        case IconButtonVariant.standard:
          return OnflixColors.primary.withOpacity(0.1);
        case IconButtonVariant.destructive:
          return OnflixColors.error.withOpacity(0.1);
      }
    }

    switch (widget.style) {
      case IconButtonStyle.filled:
        return widget.variant == IconButtonVariant.primary
            ? OnflixColors.primary
            : theme.colorScheme.surface;
      case IconButtonStyle.outlined:
      case IconButtonStyle.ghost:
        return Colors.transparent;
    }
  }

  Border? _getDefaultBorder(BuildContext context) {
    if (widget.style == IconButtonStyle.outlined) {
      return Border.all(
        color: widget.variant == IconButtonVariant.primary
            ? OnflixColors.primary
            : Theme.of(context).colorScheme.outline,
        width: 1,
      );
    }
    return null;
  }

  Color _getDefaultSplashColor(BuildContext context) {
    return OnflixColors.primary.withOpacity(0.1);
  }

  Color _getDefaultHoverColor(BuildContext context) {
    if (_isHovered) {
      return OnflixColors.primary.withOpacity(0.05);
    }
    return Colors.transparent;
  }

  double _getDefaultIconSize() => 20.0;
  double _getDefaultButtonSize() => 48.0;
  double _getDefaultBorderRadius() => 8.0;
  double _getDefaultElevation() =>
      widget.style == IconButtonStyle.filled ? 2.0 : 0.0;
  EdgeInsetsGeometry _getDefaultPadding() => const EdgeInsets.all(8.0);
}

/// Icon button variant enumeration
enum IconButtonVariant {
  primary,
  standard,
  destructive,
}

/// Icon button style enumeration
enum IconButtonStyle {
  filled,
  outlined,
  ghost,
}
