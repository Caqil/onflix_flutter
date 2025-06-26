import 'package:flutter/material.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../buttons/custom_button.dart';
import '../buttons/icon_button_widget.dart';

/// Custom dialog widget with flexible content and styling options
class CustomDialog extends StatefulWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget content;
  final List<DialogAction>? actions;
  final Widget? header;
  final Widget? footer;
  final IconData? icon;
  final Color? iconColor;
  final Widget? customIcon;
  final bool showCloseButton;
  final bool barrierDismissible;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double? elevation;
  final Duration animationDuration;
  final Curve animationCurve;
  final DialogSize size;
  final bool isScrollable;
  final ScrollController? scrollController;
  final MainAxisAlignment actionsAlignment;
  final CrossAxisAlignment contentAlignment;
  final VoidCallback? onClose;

  const CustomDialog({
    super.key,
    this.title,
    this.titleWidget,
    required this.content,
    this.actions,
    this.header,
    this.footer,
    this.icon,
    this.iconColor,
    this.customIcon,
    this.showCloseButton = true,
    this.barrierDismissible = true,
    this.width,
    this.height,
    this.contentPadding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.size = DialogSize.medium,
    this.isScrollable = false,
    this.scrollController,
    this.actionsAlignment = MainAxisAlignment.end,
    this.contentAlignment = CrossAxisAlignment.start,
    this.onClose,
  });

  // Named constructors for common dialog types
  const CustomDialog.simple({
    super.key,
    required String title,
    required Widget content,
    List<DialogAction>? actions,
    this.showCloseButton = true,
    this.barrierDismissible = true,
    this.contentPadding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.size = DialogSize.medium,
    this.isScrollable = false,
    this.scrollController,
    this.actionsAlignment = MainAxisAlignment.end,
    this.contentAlignment = CrossAxisAlignment.start,
    this.onClose,
  }) : title = title,
       titleWidget = null,
       content = content,
       actions = actions,
       header = null,
       footer = null,
       icon = null,
       iconColor = null,
       customIcon = null,
       width = null,
       height = null;

  const CustomDialog.fullscreen({
    super.key,
    this.title,
    this.titleWidget,
    required this.content,
    this.actions,
    this.header,
    this.footer,
    this.showCloseButton = true,
    this.contentPadding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 400),
    this.animationCurve = Curves.easeOutCubic,
    this.isScrollable = true,
    this.scrollController,
    this.actionsAlignment = MainAxisAlignment.end,
    this.contentAlignment = CrossAxisAlignment.start,
    this.onClose,
  }) : size = DialogSize.fullscreen,
       icon = null,
       iconColor = null,
       customIcon = null,
       width = null,
       height = null,
       barrierDismissible = false;

  const CustomDialog.bottomSheet({
    super.key,
    this.title,
    this.titleWidget,
    required this.content,
    this.actions,
    this.header,
    this.footer,
    this.showCloseButton = true,
    this.barrierDismissible = true,
    this.contentPadding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 300),
    this.isScrollable = true,
    this.scrollController,
    this.actionsAlignment = MainAxisAlignment.end,
    this.contentAlignment = CrossAxisAlignment.start,
    this.onClose,
  }) : size = DialogSize.bottomSheet,
       icon = null,
       iconColor = null,
       customIcon = null,
       width = null,
       height = null,
       borderRadius = null,
       animationCurve = Curves.easeOutCubic;

  @override
  State<CustomDialog> createState() => _CustomDialogState();

  /// Static method to show the dialog
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? titleWidget,
    required Widget content,
    List<DialogAction>? actions,
    Widget? header,
    Widget? footer,
    IconData? icon,
    Color? iconColor,
    Widget? customIcon,
    bool showCloseButton = true,
    bool barrierDismissible = true,
    double? width,
    double? height,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    double? elevation,
    Duration animationDuration = const Duration(milliseconds: 300),
    Curve animationCurve = Curves.easeOutCubic,
    DialogSize size = DialogSize.medium,
    bool isScrollable = false,
    ScrollController? scrollController,
    MainAxisAlignment actionsAlignment = MainAxisAlignment.end,
    CrossAxisAlignment contentAlignment = CrossAxisAlignment.start,
    VoidCallback? onClose,
  }) {
    if (size == DialogSize.bottomSheet) {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black54,
        builder: (context) => CustomDialog(
          title: title,
          titleWidget: titleWidget,
          content: content,
          actions: actions,
          header: header,
          footer: footer,
          icon: icon,
          iconColor: iconColor,
          customIcon: customIcon,
          showCloseButton: showCloseButton,
          barrierDismissible: barrierDismissible,
          width: width,
          height: height,
          contentPadding: contentPadding,
          margin: margin,
          borderRadius: borderRadius,
          backgroundColor: backgroundColor,
          elevation: elevation,
          animationDuration: animationDuration,
          animationCurve: animationCurve,
          size: size,
          isScrollable: isScrollable,
          scrollController: scrollController,
          actionsAlignment: actionsAlignment,
          contentAlignment: contentAlignment,
          onClose: onClose,
        ),
      );
    }

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: size == DialogSize.fullscreen 
          ? Colors.transparent 
          : Colors.black54,
      builder: (context) => CustomDialog(
        title: title,
        titleWidget: titleWidget,
        content: content,
        actions: actions,
        header: header,
        footer: footer,
        icon: icon,
        iconColor: iconColor,
        customIcon: customIcon,
        showCloseButton: showCloseButton,
        barrierDismissible: barrierDismissible,
        width: width,
        height: height,
        contentPadding: contentPadding,
        margin: margin,
        borderRadius: borderRadius,
        backgroundColor: backgroundColor,
        elevation: elevation,
        animationDuration: animationDuration,
        animationCurve: animationCurve,
        size: size,
        isScrollable: isScrollable,
        scrollController: scrollController,
        actionsAlignment: actionsAlignment,
        contentAlignment: contentAlignment,
        onClose: onClose,
      ),
    );
  }
}

class _CustomDialogState extends State<CustomDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    switch (widget.size) {
      case DialogSize.bottomSheet:
        _slideAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: widget.animationCurve,
        ));
        break;
      case DialogSize.fullscreen:
        _fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: widget.animationCurve,
        ));
        break;
      default:
        _scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: widget.animationCurve,
        ));
        
        _fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
        ));
        break;
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onClose?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        switch (widget.size) {
          case DialogSize.bottomSheet:
            return _buildBottomSheet(context);
          case DialogSize.fullscreen:
            return _buildFullscreen(context);
          default:
            return _buildStandardDialog(context);
        }
      },
    );
  }

  Widget _buildStandardDialog(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: widget.width ?? _getDefaultWidth(),
            height: widget.height,
            margin: widget.margin ?? const EdgeInsets.all(16),
            child: _buildDialogContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        margin: widget.margin ?? const EdgeInsets.only(top: 50),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Theme.of(context).dialogBackgroundColor,
          borderRadius: widget.borderRadius ?? const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: _buildDialogContent(context),
      ),
    );
  }

  Widget _buildFullscreen(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        body: _buildDialogContent(context),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    Widget content = Column(
      mainAxisSize: widget.size == DialogSize.fullscreen 
          ? MainAxisSize.max 
          : MainAxisSize.min,
      crossAxisAlignment: widget.contentAlignment,
      children: [
        if (widget.header != null)
          widget.header!
        else if (widget.title != null || 
                 widget.titleWidget != null || 
                 widget.showCloseButton)
          _buildHeader(context),
        
        if (widget.isScrollable)
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: widget.contentPadding ?? _getDefaultContentPadding(),
              child: widget.content,
            ),
          )
        else
          Padding(
            padding: widget.contentPadding ?? _getDefaultContentPadding(),
            child: widget.content,
          ),
        
        if (widget.actions != null && widget.actions!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildActions(context),
        ],
        
        if (widget.footer != null)
          widget.footer!,
      ],
    );

    if (widget.size == DialogSize.fullscreen) {
      return content;
    }

    return ShadCard(
      backgroundColor: widget.backgroundColor,
      child: content,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
      child: Row(
        children: [
          if (widget.icon != null || widget.customIcon != null) ...[
            _buildIcon(context),
            const SizedBox(width: 16),
          ],
          
          Expanded(
            child: widget.titleWidget ?? (widget.title != null 
                ? Text(
                    widget.title!,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : const SizedBox.shrink()),
          ),
          
          if (widget.showCloseButton)
            OnflixIconButton(
              icon: LucideIcons.x,
              onPressed: _handleClose,
              style: IconButtonStyle.ghost,
              tooltip: 'Close',
            ),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (widget.customIcon != null) {
      return widget.customIcon!;
    }

    if (widget.icon != null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (widget.iconColor ?? OnflixColors.primary).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.icon!,
          size: 20,
          color: widget.iconColor ?? OnflixColors.primary,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        mainAxisAlignment: widget.actionsAlignment,
        children: widget.actions!.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;
          
          return Padding(
            padding: EdgeInsets.only(
              left: index > 0 ? 8 : 0,
            ),
            child: CustomButton(
              text: action.text,
              onPressed: () {
                action.onPressed?.call();
                if (action.closesDialog) {
                  _animationController.reverse().then((_) {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                }
              },
              variant: action.variant,
              size: action.size,
              icon: action.icon,
              isLoading: action.isLoading,
              isDisabled: action.isDisabled,
              isExpanded: action.isExpanded,
            ),
          );
        }).toList(),
      ),
    );
  }

  double _getDefaultWidth() {
    switch (widget.size) {
      case DialogSize.small:
        return 300;
      case DialogSize.medium:
        return 400;
      case DialogSize.large:
        return 600;
      case DialogSize.extraLarge:
        return 800;
      case DialogSize.bottomSheet:
      case DialogSize.fullscreen:
        return double.infinity;
    }
  }

  EdgeInsetsGeometry _getDefaultContentPadding() {
    if (widget.size == DialogSize.fullscreen) {
      return const EdgeInsets.all(24);
    }
    return const EdgeInsets.fromLTRB(24, 16, 24, 0);
  }
}

/// Dialog action model
class DialogAction {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final CustomButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final bool isExpanded;
  final bool closesDialog;

  const DialogAction({
    required this.text,
    this.onPressed,
    this.variant = CustomButtonVariant.secondary,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = false,
    this.closesDialog = true,
  });

  /// Creates a primary action
  const DialogAction.primary({
    required this.text,
    this.onPressed,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = false,
    this.closesDialog = true,
  }) : variant = CustomButtonVariant.primary;

  /// Creates a cancel action
  const DialogAction.cancel({
    this.text = 'Cancel',
    this.onPressed,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = false,
    this.closesDialog = true,
  }) : variant = CustomButtonVariant.ghost;

  /// Creates a destructive action
  const DialogAction.destructive({
    required this.text,
    this.onPressed,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = false,
    this.closesDialog = true,
  }) : variant = CustomButtonVariant.destructive;
}

/// Dialog size enumeration
enum DialogSize {
  small,
  medium,
  large,
  extraLarge,
  bottomSheet,
  fullscreen,
}