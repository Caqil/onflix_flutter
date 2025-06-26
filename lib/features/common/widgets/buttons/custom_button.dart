import 'package:flutter/material.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
import 'package:onflix/core/extensions/widget_extension.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Custom button widget that provides consistent styling and behavior
/// across the Onflix application. Built on top of ShadCN UI components.
class CustomButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final CustomButtonVariant variant;
  final CustomButtonSize size;
  final IconData? icon;
  final IconData? suffixIcon;
  final bool isLoading;
  final bool isDisabled;
  final bool isExpanded;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? elevation;
  final Duration animationDuration;

  const CustomButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.onLongPress,
    this.variant = CustomButtonVariant.primary,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = false,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : assert(text != null || child != null,
            'Either text or child must be provided');

  // Named constructors for common button types
  const CustomButton.primary({
    super.key,
    required String this.text,
    required this.onPressed,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = false,
    this.size = CustomButtonSize.medium,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 200),
  })  : child = null,
        onLongPress = null,
        variant = CustomButtonVariant.primary,
        backgroundColor = null,
        foregroundColor = null,
        borderColor = null;

  const CustomButton.secondary({
    super.key,
    required String this.text,
    required this.onPressed,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = false,
    this.size = CustomButtonSize.medium,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 200),
  })  : child = null,
        onLongPress = null,
        variant = CustomButtonVariant.secondary,
        backgroundColor = null,
        foregroundColor = null,
        borderColor = null;

  const CustomButton.ghost({
    super.key,
    required String this.text,
    required this.onPressed,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = false,
    this.size = CustomButtonSize.medium,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 200),
  })  : child = null,
        onLongPress = null,
        variant = CustomButtonVariant.ghost,
        backgroundColor = null,
        foregroundColor = null,
        borderColor = null;

  const CustomButton.destructive({
    super.key,
    required String this.text,
    required this.onPressed,
    this.icon,
    this.suffixIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = false,
    this.size = CustomButtonSize.medium,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 200),
  })  : child = null,
        onLongPress = null,
        variant = CustomButtonVariant.destructive,
        backgroundColor = null,
        foregroundColor = null,
        borderColor = null;

  @override
  Widget build(BuildContext context) {
    final isEffectivelyDisabled = isDisabled || isLoading;

    Widget buttonChild = _buildButtonContent(context);

    if (isLoading) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _getLoadingSize(),
            height: _getLoadingSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getLoadingColor(context),
              ),
            ),
          ),
          if (text != null || child != null) ...[
            const SizedBox(width: 8),
            Opacity(
              opacity: 0.7,
              child: _buildButtonContent(context),
            ),
          ],
        ],
      );
    }

    Widget button = ShadButton.raw(
      onPressed: isEffectivelyDisabled ? null : onPressed,
      onLongPress: isEffectivelyDisabled ? null : onLongPress,
      variant: _getShadVariant(),
      size: _getShadSize(),
      child: buttonChild,
    );

    // Apply custom styling if provided
    if (backgroundColor != null ||
        foregroundColor != null ||
        borderColor != null ||
        borderRadius != null ||
        elevation != null) {
      button = _applyCustomStyling(button, context);
    }

    // Apply expansion
    if (isExpanded) {
      button = button.expanded();
    }

    // Apply margin if provided
    if (margin != null) {
      button = Padding(
        padding: margin!,
        child: button,
      );
    }

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOut,
      child: button,
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    if (child != null) {
      return child!;
    }

    final List<Widget> children = [];

    if (icon != null) {
      children.add(Icon(icon, size: _getIconSize()));
    }

    if (text != null) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(width: 8));
      }
      children.add(
        Text(
          text!,
          style: _getTextStyle(context),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    if (suffixIcon != null) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(width: 8));
      }
      children.add(Icon(suffixIcon, size: _getIconSize()));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _applyCustomStyling(Widget button, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation!,
                  offset: Offset(0, elevation! / 2),
                ),
              ]
            : null,
      ),
      child: button,
    );
  }

  ShadButtonVariant _getShadVariant() {
    switch (variant) {
      case CustomButtonVariant.primary:
        return ShadButtonVariant.primary;
      case CustomButtonVariant.secondary:
        return ShadButtonVariant.secondary;
      case CustomButtonVariant.ghost:
        return ShadButtonVariant.ghost;
      case CustomButtonVariant.destructive:
        return ShadButtonVariant.destructive;
      case CustomButtonVariant.outline:
        return ShadButtonVariant.outline;
      case CustomButtonVariant.link:
        return ShadButtonVariant.link;
    }
  }

  ShadButtonSize _getShadSize() {
    switch (size) {
      case CustomButtonSize.small:
        return ShadButtonSize.sm;
      case CustomButtonSize.medium:
        return ShadButtonSize.regular;
      case CustomButtonSize.large:
        return ShadButtonSize.lg;
    }
  }

  double _getIconSize() {
    switch (size) {
      case CustomButtonSize.small:
        return 14;
      case CustomButtonSize.medium:
        return 16;
      case CustomButtonSize.large:
        return 18;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case CustomButtonSize.small:
        return 12;
      case CustomButtonSize.medium:
        return 16;
      case CustomButtonSize.large:
        return 20;
    }
  }

  Color _getLoadingColor(BuildContext context) {
    if (foregroundColor != null) return foregroundColor!;

    switch (variant) {
      case CustomButtonVariant.primary:
        return OnflixColors.white;
      case CustomButtonVariant.secondary:
      case CustomButtonVariant.ghost:
      case CustomButtonVariant.outline:
      case CustomButtonVariant.link:
        return Theme.of(context).colorScheme.primary;
      case CustomButtonVariant.destructive:
        return OnflixColors.white;
    }
  }

  TextStyle? _getTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    TextStyle? baseStyle;

    switch (size) {
      case CustomButtonSize.small:
        baseStyle = theme.textTheme.bodySmall;
        break;
      case CustomButtonSize.medium:
        baseStyle = theme.textTheme.bodyMedium;
        break;
      case CustomButtonSize.large:
        baseStyle = theme.textTheme.bodyLarge;
        break;
    }

    return baseStyle?.copyWith(
      color: foregroundColor,
      fontWeight: FontWeight.w500,
    );
  }
}

/// Button variant enumeration
enum CustomButtonVariant {
  primary,
  secondary,
  ghost,
  destructive,
  outline,
  link,
}

/// Button size enumeration
enum CustomButtonSize {
  small,
  medium,
  large,
}
