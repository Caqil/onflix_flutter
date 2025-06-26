import 'package:flutter/material.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../buttons/custom_button.dart';

/// Confirmation dialog widget for user confirmations with customizable actions
class ConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? description;
  final IconData? icon;
  final Color? iconColor;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final ConfirmationType type;
  final bool isDangerous;
  final bool barrierDismissible;
  final bool showIcon;
  final Widget? customIcon;
  final List<ConfirmationAction>? customActions;
  final EdgeInsetsGeometry? contentPadding;
  final Duration animationDuration;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.description,
    this.icon,
    this.iconColor,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.type = ConfirmationType.warning,
    this.isDangerous = false,
    this.barrierDismissible = true,
    this.showIcon = true,
    this.customIcon,
    this.customActions,
    this.contentPadding,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  // Named constructors for common confirmation types
  const ConfirmationDialog.delete({
    super.key,
    required this.title,
    required this.message,
    this.description,
    this.onConfirm,
    this.onCancel,
    this.confirmText = 'Delete',
    this.cancelText = 'Cancel',
    this.barrierDismissible = true,
    this.showIcon = true,
    this.customIcon,
    this.customActions,
    this.contentPadding,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : type = ConfirmationType.destructive,
       icon = LucideIcons.trash2,
       iconColor = OnflixColors.error,
       isDangerous = true;

  const ConfirmationDialog.logout({
    super.key,
    this.title = 'Sign Out',
    this.message = 'Are you sure you want to sign out?',
    this.description,
    this.onConfirm,
    this.onCancel,
    this.confirmText = 'Sign Out',
    this.cancelText = 'Cancel',
    this.barrierDismissible = true,
    this.showIcon = true,
    this.customIcon,
    this.customActions,
    this.contentPadding,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : type = ConfirmationType.warning,
       icon = LucideIcons.logOut,
       iconColor = OnflixColors.warning,
       isDangerous = false;

  const ConfirmationDialog.download({
    super.key,
    this.title = 'Download Content',
    this.message = 'This will use your device storage. Continue?',
    this.description,
    this.onConfirm,
    this.onCancel,
    this.confirmText = 'Download',
    this.cancelText = 'Cancel',
    this.barrierDismissible = true,
    this.showIcon = true,
    this.customIcon,
    this.customActions,
    this.contentPadding,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : type = ConfirmationType.info,
       icon = LucideIcons.download,
       iconColor = OnflixColors.primary,
       isDangerous = false;

  const ConfirmationDialog.removeFromWatchlist({
    super.key,
    this.title = 'Remove from Watchlist',
    this.message = 'Remove this item from your watchlist?',
    this.description,
    this.onConfirm,
    this.onCancel,
    this.confirmText = 'Remove',
    this.cancelText = 'Cancel',
    this.barrierDismissible = true,
    this.showIcon = true,
    this.customIcon,
    this.customActions,
    this.contentPadding,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : type = ConfirmationType.warning,
       icon = LucideIcons.x,
       iconColor = OnflixColors.warning,
       isDangerous = false;

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();

  /// Static method to show the dialog
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? description,
    IconData? icon,
    Color? iconColor,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    ConfirmationType type = ConfirmationType.warning,
    bool isDangerous = false,
    bool barrierDismissible = true,
    bool showIcon = true,
    Widget? customIcon,
    List<ConfirmationAction>? customActions,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        description: description,
        icon: icon,
        iconColor: iconColor,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () {
          Navigator.of(context).pop(true);
          onConfirm?.call();
        },
        onCancel: () {
          Navigator.of(context).pop(false);
          onCancel?.call();
        },
        type: type,
        isDangerous: isDangerous,
        barrierDismissible: barrierDismissible,
        showIcon: showIcon,
        customIcon: customIcon,
        customActions: customActions,
        contentPadding: contentPadding,
      ),
    );
  }

  /// Static method to show delete confirmation
  static Future<bool?> showDelete({
    required BuildContext context,
    required String title,
    required String message,
    String? description,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      description: description,
      confirmText: 'Delete',
      cancelText: 'Cancel',
      type: ConfirmationType.destructive,
      isDangerous: true,
      icon: LucideIcons.trash2,
      iconColor: OnflixColors.error,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  /// Static method to show logout confirmation
  static Future<bool?> showLogout({
    required BuildContext context,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
      type: ConfirmationType.warning,
      icon: LucideIcons.logOut,
      iconColor: OnflixColors.warning,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }
}

class _ConfirmationDialogState extends State<ConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop(true);
        widget.onConfirm?.call();
      }
    });
  }

  void _handleCancel() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop(false);
        widget.onCancel?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: ShadDialog(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: widget.contentPadding ?? const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 16),
                    _buildContent(context),
                    const SizedBox(height: 24),
                    _buildActions(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (widget.showIcon && (widget.icon != null || widget.customIcon != null)) ...[
          _buildIcon(context),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: _getHeaderColor(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (widget.customIcon != null) {
      return widget.customIcon!;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getIconBackgroundColor(context),
        shape: BoxShape.circle,
      ),
      child: Icon(
        widget.icon ?? _getDefaultIcon(),
        size: 24,
        color: widget.iconColor ?? _getDefaultIconColor(),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.message,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.5,
          ),
        ),
        if (widget.description != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: OnflixColors.lightGray,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    if (widget.customActions != null) {
      return _buildCustomActions(context);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton.ghost(
          text: widget.cancelText,
          onPressed: _handleCancel,
          size: CustomButtonSize.medium,
        ),
        const SizedBox(width: 12),
        CustomButton(
          text: widget.confirmText,
          onPressed: _handleConfirm,
          variant: widget.isDangerous 
              ? CustomButtonVariant.destructive 
              : _getConfirmButtonVariant(),
          size: CustomButtonSize.medium,
        ),
      ],
    );
  }

  Widget _buildCustomActions(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: widget.customActions!.map((action) {
        return CustomButton(
          text: action.text,
          onPressed: () {
            _animationController.reverse().then((_) {
              if (mounted) {
                Navigator.of(context).pop(action.result);
                action.onPressed?.call();
              }
            });
          },
          variant: action.variant,
          size: CustomButtonSize.medium,
          icon: action.icon,
        );
      }).toList(),
    );
  }

  IconData _getDefaultIcon() {
    switch (widget.type) {
      case ConfirmationType.info:
        return LucideIcons.info;
      case ConfirmationType.warning:
        return LucideIcons.triangleAlert;
      case ConfirmationType.destructive:
        return LucideIcons.circleAlert;
      case ConfirmationType.success:
        return LucideIcons.circleCheck;
    }
  }

  Color _getDefaultIconColor() {
    switch (widget.type) {
      case ConfirmationType.info:
        return OnflixColors.info;
      case ConfirmationType.warning:
        return OnflixColors.warning;
      case ConfirmationType.destructive:
        return OnflixColors.error;
      case ConfirmationType.success:
        return OnflixColors.success;
    }
  }

  Color _getIconBackgroundColor(BuildContext context) {
    final iconColor = widget.iconColor ?? _getDefaultIconColor();
    return iconColor.withOpacity(0.1);
  }

  Color _getHeaderColor(BuildContext context) {
    if (widget.isDangerous) {
      return OnflixColors.error;
    }
    return Theme.of(context).textTheme.headlineSmall?.color ?? OnflixColors.white;
  }

  CustomButtonVariant _getConfirmButtonVariant() {
    switch (widget.type) {
      case ConfirmationType.info:
      case ConfirmationType.success:
        return CustomButtonVariant.primary;
      case ConfirmationType.warning:
        return CustomButtonVariant.secondary;
      case ConfirmationType.destructive:
        return CustomButtonVariant.destructive;
    }
  }
}

/// Confirmation action model for custom actions
class ConfirmationAction {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final IconData? icon;
  final dynamic result;

  const ConfirmationAction({
    required this.text,
    this.onPressed,
    this.variant = CustomButtonVariant.secondary,
    this.icon,
    this.result,
  });
}

/// Confirmation type enumeration
enum ConfirmationType {
  info,
  warning,
  destructive,
  success,
}