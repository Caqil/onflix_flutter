import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../buttons/custom_button.dart';
import '../buttons/icon_button_widget.dart';

/// Info card widget for displaying informational content with icons, titles, and actions
class InfoCard extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final String? description;
  final IconData? icon;
  final Widget? customIcon;
  final String? imageUrl;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final VoidCallback? onActionPressed;
  final String? actionText;
  final IconData? actionIcon;
  final List<InfoCardAction>? actions;
  final InfoCardVariant variant;
  final InfoCardSize size;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Border? border;
  final double? elevation;
  final bool showBorder;
  final bool showShadow;
  final bool isSelectable;
  final bool isSelected;
  final bool isLoading;
  final Widget? trailing;
  final Widget? leading;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const InfoCard({
    super.key,
    this.title,
    this.subtitle,
    this.description,
    this.icon,
    this.customIcon,
    this.imageUrl,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.onActionPressed,
    this.actionText,
    this.actionIcon,
    this.actions,
    this.variant = InfoCardVariant.standard,
    this.size = InfoCardSize.medium,
    this.margin,
    this.padding,
    this.borderRadius,
    this.border,
    this.elevation,
    this.showBorder = false,
    this.showShadow = true,
    this.isSelectable = false,
    this.isSelected = false,
    this.isLoading = false,
    this.trailing,
    this.leading,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  // Named constructors for different info card types
   InfoCard.success({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.onTap,
    this.onActionPressed,
    this.actionText,
    this.actions,
    this.size = InfoCardSize.medium,
    this.margin,
    this.padding,
    this.borderRadius,
    this.border,
    this.elevation,
    this.showBorder = false,
    this.showShadow = true,
    this.isSelectable = false,
    this.isSelected = false,
    this.isLoading = false,
    this.trailing,
    this.leading,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  })  : variant = InfoCardVariant.success,
        icon = LucideIcons.check,
        customIcon = null,
        imageUrl = null,
        iconColor = OnflixColors.success,
        backgroundColor = null,
        actionIcon = null;

   InfoCard.warning({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.onTap,
    this.onActionPressed,
    this.actionText,
    this.actions,
    this.size = InfoCardSize.medium,
    this.margin,
    this.padding,
    this.borderRadius,
    this.border,
    this.elevation,
    this.showBorder = false,
    this.showShadow = true,
    this.isSelectable = false,
    this.isSelected = false,
    this.isLoading = false,
    this.trailing,
    this.leading,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  })  : variant = InfoCardVariant.warning,
        icon = LucideIcons.fileWarning,
        customIcon = null,
        imageUrl = null,
        iconColor = OnflixColors.warning,
        backgroundColor = null,
        actionIcon = null;

   InfoCard.error({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.onTap,
    this.onActionPressed,
    this.actionText,
    this.actions,
    this.size = InfoCardSize.medium,
    this.margin,
    this.padding,
    this.borderRadius,
    this.border,
    this.elevation,
    this.showBorder = false,
    this.showShadow = true,
    this.isSelectable = false,
    this.isSelected = false,
    this.isLoading = false,
    this.trailing,
    this.leading,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  })  : variant = InfoCardVariant.error,
        icon = LucideIcons.circleX,
        customIcon = null,
        imageUrl = null,
        iconColor = OnflixColors.error,
        backgroundColor = null,
        actionIcon = null;

  const InfoCard.info({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.onTap,
    this.onActionPressed,
    this.actionText,
    this.actions,
    this.size = InfoCardSize.medium,
    this.margin,
    this.padding,
    this.borderRadius,
    this.border,
    this.elevation,
    this.showBorder = false,
    this.showShadow = true,
    this.isSelectable = false,
    this.isSelected = false,
    this.isLoading = false,
    this.trailing,
    this.leading,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  })  : variant = InfoCardVariant.info,
        icon = LucideIcons.info,
        customIcon = null,
        imageUrl = null,
        iconColor = OnflixColors.info,
        backgroundColor = null,
        actionIcon = null;

  const InfoCard.feature({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.description,
    this.iconColor,
    this.onTap,
    this.onActionPressed,
    this.actionText,
    this.actionIcon,
    this.actions,
    this.size = InfoCardSize.large,
    this.margin,
    this.padding,
    this.borderRadius,
    this.border,
    this.elevation,
    this.showBorder = true,
    this.showShadow = true,
    this.isSelectable = false,
    this.isSelected = false,
    this.isLoading = false,
    this.trailing,
    this.leading,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.center,
  })  : variant = InfoCardVariant.feature,
        customIcon = null,
        imageUrl = null,
        backgroundColor = null;

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _selectionController;
  late AnimationController _loadingController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _selectionAnimation;
  late Animation<double> _rotationAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
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
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 4.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
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
  void didUpdateWidget(InfoCard oldWidget) {
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
    _hoverController.dispose();
    _selectionController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _elevationAnimation,
          _selectionAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: widget.margin ?? _getDefaultMargin(),
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ?? _getDefaultBorderRadius(),
                boxShadow: widget.showShadow
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: (widget.elevation ?? 2) +
                              _elevationAnimation.value,
                          offset: Offset(
                              0,
                              (widget.elevation ?? 2) +
                                  _elevationAnimation.value / 2),
                        ),
                        if (widget.isSelected)
                          BoxShadow(
                            color: OnflixColors.primary
                                .withOpacity(_selectionAnimation.value * 0.3),
                            blurRadius: 8 * _selectionAnimation.value,
                            spreadRadius: 2 * _selectionAnimation.value,
                          ),
                      ]
                    : null,
              ),
              child: _buildCard(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return ShadCard(
      backgroundColor: widget.backgroundColor ?? _getBackgroundColor(context),
      padding: (widget.padding ?? _getDefaultPadding()) as EdgeInsets?,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: widget.borderRadius ?? _getDefaultBorderRadius(),
        child: Container(
          decoration: BoxDecoration(
            border: widget.border ??
                (widget.showBorder ? _getDefaultBorder(context) : null),
            borderRadius: widget.borderRadius ?? _getDefaultBorderRadius(),
          ),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.variant) {
      case InfoCardVariant.standard:
      case InfoCardVariant.success:
      case InfoCardVariant.warning:
      case InfoCardVariant.error:
      case InfoCardVariant.info:
        return _buildStandardContent(context);
      case InfoCardVariant.feature:
        return _buildFeatureContent(context);
      case InfoCardVariant.compact:
        return _buildCompactContent(context);
    }
  }

  Widget _buildStandardContent(BuildContext context) {
    return Row(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: [
        if (widget.leading != null) ...[
          widget.leading!,
          const SizedBox(width: 12),
        ],
        if (widget.icon != null || widget.customIcon != null) ...[
          _buildIcon(context),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: widget.mainAxisAlignment,
            children: [
              if (widget.title != null)
                Text(
                  widget.title!,
                  style: _getTitleStyle(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.subtitle!,
                  style: _getSubtitleStyle(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (widget.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.description!,
                  style: _getDescriptionStyle(context),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (widget.actionText != null || widget.actions != null) ...[
                const SizedBox(height: 12),
                _buildActions(context),
              ],
            ],
          ),
        ),
        if (widget.trailing != null) ...[
          const SizedBox(width: 12),
          widget.trailing!,
        ],
      ],
    );
  }

  Widget _buildFeatureContent(BuildContext context) {
    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      mainAxisAlignment: widget.mainAxisAlignment,
      children: [
        if (widget.icon != null || widget.customIcon != null)
          _buildIcon(context, isLarge: true),
        if (widget.title != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.title!,
            style: _getTitleStyle(context),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (widget.subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.subtitle!,
            style: _getSubtitleStyle(context),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (widget.description != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.description!,
            style: _getDescriptionStyle(context),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (widget.actionText != null || widget.actions != null) ...[
          const SizedBox(height: 16),
          _buildActions(context),
        ],
      ],
    );
  }

  Widget _buildCompactContent(BuildContext context) {
    return Row(
      children: [
        if (widget.icon != null || widget.customIcon != null) ...[
          _buildIcon(context),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.title != null)
                Text(
                  widget.title!,
                  style: _getTitleStyle(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (widget.subtitle != null)
                Text(
                  widget.subtitle!,
                  style: _getSubtitleStyle(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (widget.trailing != null) widget.trailing!,
      ],
    );
  }

  Widget _buildIcon(BuildContext context, {bool isLarge = false}) {
    if (widget.isLoading) {
      return AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Icon(
              LucideIcons.loader,
              size: _getIconSize(isLarge),
              color: widget.iconColor ?? _getIconColor(context),
            ),
          );
        },
      );
    }

    if (widget.customIcon != null) {
      return SizedBox(
        width: _getIconSize(isLarge),
        height: _getIconSize(isLarge),
        child: widget.customIcon!,
      );
    }

    if (widget.icon != null) {
      return Container(
        width: _getIconSize(isLarge),
        height: _getIconSize(isLarge),
        decoration: isLarge
            ? BoxDecoration(
                color: (widget.iconColor ?? _getIconColor(context))
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          widget.icon!,
          size: isLarge ? _getIconSize(isLarge) * 0.6 : _getIconSize(isLarge),
          color: widget.iconColor ?? _getIconColor(context),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActions(BuildContext context) {
    if (widget.actions != null && widget.actions!.isNotEmpty) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.actions!.map((action) {
          return CustomButton(
            text: action.text,
            onPressed: action.onPressed,
            icon: action.icon,
            variant: action.variant,
            size: CustomButtonSize.small,
          );
        }).toList(),
      );
    }

    if (widget.actionText != null) {
      return CustomButton(
        text: widget.actionText!,
        onPressed: widget.onActionPressed,
        icon: widget.actionIcon,
        variant: _getActionButtonVariant(),
        size: CustomButtonSize.small,
      );
    }

    return const SizedBox.shrink();
  }

  Color? _getBackgroundColor(BuildContext context) {
    switch (widget.variant) {
      case InfoCardVariant.standard:
      case InfoCardVariant.feature:
      case InfoCardVariant.compact:
        return null;
      case InfoCardVariant.success:
        return OnflixColors.success.withOpacity(0.05);
      case InfoCardVariant.warning:
        return OnflixColors.warning.withOpacity(0.05);
      case InfoCardVariant.error:
        return OnflixColors.error.withOpacity(0.05);
      case InfoCardVariant.info:
        return OnflixColors.info.withOpacity(0.05);
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (widget.variant) {
      case InfoCardVariant.standard:
      case InfoCardVariant.feature:
      case InfoCardVariant.compact:
        return Theme.of(context).colorScheme.primary;
      case InfoCardVariant.success:
        return OnflixColors.success;
      case InfoCardVariant.warning:
        return OnflixColors.warning;
      case InfoCardVariant.error:
        return OnflixColors.error;
      case InfoCardVariant.info:
        return OnflixColors.info;
    }
  }

  CustomButtonVariant _getActionButtonVariant() {
    switch (widget.variant) {
      case InfoCardVariant.standard:
      case InfoCardVariant.feature:
      case InfoCardVariant.compact:
      case InfoCardVariant.info:
        return CustomButtonVariant.primary;
      case InfoCardVariant.success:
        return CustomButtonVariant.secondary;
      case InfoCardVariant.warning:
        return CustomButtonVariant.outline;
      case InfoCardVariant.error:
        return CustomButtonVariant.destructive;
    }
  }

  TextStyle? _getTitleStyle(BuildContext context) {
    final theme = Theme.of(context);

    switch (widget.size) {
      case InfoCardSize.small:
        return theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        );
      case InfoCardSize.medium:
        return theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        );
      case InfoCardSize.large:
        return theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        );
    }
  }

  TextStyle? _getSubtitleStyle(BuildContext context) {
    final theme = Theme.of(context);

    return theme.textTheme.bodyMedium?.copyWith(
      color: OnflixColors.lightGray,
      fontWeight: FontWeight.w500,
    );
  }

  TextStyle? _getDescriptionStyle(BuildContext context) {
    final theme = Theme.of(context);

    return theme.textTheme.bodySmall?.copyWith(
      color: OnflixColors.lightGray,
      height: 1.4,
    );
  }

  double _getIconSize(bool isLarge) {
    if (isLarge) return 64;

    switch (widget.size) {
      case InfoCardSize.small:
        return 20;
      case InfoCardSize.medium:
        return 24;
      case InfoCardSize.large:
        return 32;
    }
  }

  EdgeInsetsGeometry _getDefaultMargin() {
    return const EdgeInsets.all(4);
  }

  EdgeInsetsGeometry _getDefaultPadding() {
    switch (widget.size) {
      case InfoCardSize.small:
        return const EdgeInsets.all(12);
      case InfoCardSize.medium:
        return const EdgeInsets.all(16);
      case InfoCardSize.large:
        return const EdgeInsets.all(20);
    }
  }

  BorderRadius _getDefaultBorderRadius() {
    return BorderRadius.circular(8);
  }

  Border _getDefaultBorder(BuildContext context) {
    return Border.all(
      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
      width: 1,
    );
  }
}

/// Info card action model
class InfoCardAction {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final CustomButtonVariant variant;

  const InfoCardAction({
    required this.text,
    this.onPressed,
    this.icon,
    this.variant = CustomButtonVariant.secondary,
  });
}

/// Info card variant enumeration
enum InfoCardVariant {
  standard,
  success,
  warning,
  error,
  info,
  feature,
  compact,
}

/// Info card size enumeration
enum InfoCardSize {
  small,
  medium,
  large,
}
