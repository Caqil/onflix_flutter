import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../buttons/custom_button.dart';

/// Loading dialog widget for displaying progress and loading states
class LoadingDialog extends StatefulWidget {
  final String? title;
  final String? message;
  final String? description;
  final double? progress;
  final bool isIndeterminate;
  final bool showProgress;
  final bool showCancel;
  final bool barrierDismissible;
  final VoidCallback? onCancel;
  final LoadingType type;
  final Widget? customIcon;
  final String? animationAsset;
  final Color? progressColor;
  final Color? backgroundColor;
  final Duration animationDuration;
  final String cancelText;
  final EdgeInsetsGeometry? contentPadding;

  const LoadingDialog({
    super.key,
    this.title,
    this.message,
    this.description,
    this.progress,
    this.isIndeterminate = true,
    this.showProgress = false,
    this.showCancel = false,
    this.barrierDismissible = false,
    this.onCancel,
    this.type = LoadingType.general,
    this.customIcon,
    this.animationAsset,
    this.progressColor,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.cancelText = 'Cancel',
    this.contentPadding,
  });

  // Named constructors for specific loading types
  const LoadingDialog.download({
    super.key,
    this.title = 'Downloading',
    this.message = 'Downloading content...',
    this.description,
    this.progress,
    this.isIndeterminate = false,
    this.showProgress = true,
    this.showCancel = true,
    this.barrierDismissible = false,
    this.onCancel,
    this.customIcon,
    this.animationAsset,
    this.progressColor,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.cancelText = 'Cancel',
    this.contentPadding,
  }) : type = LoadingType.download;

  const LoadingDialog.upload({
    super.key,
    this.title = 'Uploading',
    this.message = 'Uploading content...',
    this.description,
    this.progress,
    this.isIndeterminate = false,
    this.showProgress = true,
    this.showCancel = true,
    this.barrierDismissible = false,
    this.onCancel,
    this.customIcon,
    this.animationAsset,
    this.progressColor,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.cancelText = 'Cancel',
    this.contentPadding,
  }) : type = LoadingType.upload;

  const LoadingDialog.processing({
    super.key,
    this.title = 'Processing',
    this.message = 'Processing your request...',
    this.description,
    this.progress,
    this.isIndeterminate = true,
    this.showProgress = false,
    this.showCancel = false,
    this.barrierDismissible = false,
    this.onCancel,
    this.customIcon,
    this.animationAsset,
    this.progressColor,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.cancelText = 'Cancel',
    this.contentPadding,
  }) : type = LoadingType.processing;

  const LoadingDialog.authentication({
    super.key,
    this.title = 'Signing In',
    this.message = 'Authenticating...',
    this.description,
    this.progress,
    this.isIndeterminate = true,
    this.showProgress = false,
    this.showCancel = false,
    this.barrierDismissible = false,
    this.onCancel,
    this.customIcon,
    this.animationAsset,
    this.progressColor,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.cancelText = 'Cancel',
    this.contentPadding,
  }) : type = LoadingType.authentication;

  const LoadingDialog.sync({
    super.key,
    this.title = 'Syncing',
    this.message = 'Syncing your data...',
    this.description,
    this.progress,
    this.isIndeterminate = true,
    this.showProgress = false,
    this.showCancel = false,
    this.barrierDismissible = false,
    this.onCancel,
    this.customIcon,
    this.animationAsset,
    this.progressColor,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.cancelText = 'Cancel',
    this.contentPadding,
  }) : type = LoadingType.sync;

  const LoadingDialog.buffering({
    super.key,
    this.title = 'Buffering',
    this.message = 'Loading video...',
    this.description,
    this.progress,
    this.isIndeterminate = true,
    this.showProgress = false,
    this.showCancel = true,
    this.barrierDismissible = true,
    this.onCancel,
    this.customIcon,
    this.animationAsset,
    this.progressColor,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.cancelText = 'Cancel',
    this.contentPadding,
  }) : type = LoadingType.buffering;

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();

  /// Static method to show the loading dialog
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    String? description,
    double? progress,
    bool isIndeterminate = true,
    bool showProgress = false,
    bool showCancel = false,
    bool barrierDismissible = false,
    VoidCallback? onCancel,
    LoadingType type = LoadingType.general,
    Widget? customIcon,
    String? animationAsset,
    Color? progressColor,
    Color? backgroundColor,
    Duration animationDuration = const Duration(milliseconds: 300),
    String cancelText = 'Cancel',
    EdgeInsetsGeometry? contentPadding,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      builder: (context) => LoadingDialog(
        title: title,
        message: message,
        description: description,
        progress: progress,
        isIndeterminate: isIndeterminate,
        showProgress: showProgress,
        showCancel: showCancel,
        barrierDismissible: barrierDismissible,
        onCancel: onCancel,
        type: type,
        customIcon: customIcon,
        animationAsset: animationAsset,
        progressColor: progressColor,
        backgroundColor: backgroundColor,
        animationDuration: animationDuration,
        cancelText: cancelText,
        contentPadding: contentPadding,
      ),
    );
  }

  /// Static method to show download loading dialog
  static Future<T?> showDownload<T>({
    required BuildContext context,
    String? title,
    String? message,
    double? progress,
    VoidCallback? onCancel,
  }) {
    return show<T>(
      context: context,
      title: title ?? 'Downloading',
      message: message ?? 'Downloading content...',
      progress: progress,
      isIndeterminate: progress == null,
      showProgress: true,
      showCancel: true,
      type: LoadingType.download,
      onCancel: onCancel,
    );
  }

  /// Static method to show processing loading dialog
  static Future<T?> showProcessing<T>({
    required BuildContext context,
    String? title,
    String? message,
  }) {
    return show<T>(
      context: context,
      title: title ?? 'Processing',
      message: message ?? 'Processing your request...',
      type: LoadingType.processing,
    );
  }

  /// Static method to show authentication loading dialog
  static Future<T?> showAuthentication<T>({
    required BuildContext context,
  }) {
    return show<T>(
      context: context,
      title: 'Signing In',
      message: 'Authenticating...',
      type: LoadingType.authentication,
    );
  }
}

class _LoadingDialogState extends State<LoadingDialog>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress ?? 0.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    
    if (widget.isIndeterminate) {
      _pulseController.repeat(reverse: true);
    }

    if (widget.progress != null) {
      _progressController.forward();
    }
  }

  @override
  void didUpdateWidget(LoadingDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.progress != oldWidget.progress && widget.progress != null) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress!,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOut,
      ));
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _handleCancel() {
    _fadeController.reverse();
    _scaleController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onCancel?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 350),
                child: _buildLoadingDialog(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingDialog(BuildContext context) {
    return ShadCard(
      backgroundColor: widget.backgroundColor,
      child: Padding(
        padding: widget.contentPadding ?? const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLoadingIndicator(context),
            if (widget.title != null) ...[
              const SizedBox(height: 20),
              _buildTitle(context),
            ],
            if (widget.message != null) ...[
              const SizedBox(height: 8),
              _buildMessage(context),
            ],
            if (widget.description != null) ...[
              const SizedBox(height: 8),
              _buildDescription(context),
            ],
            if (widget.showProgress && !widget.isIndeterminate) ...[
              const SizedBox(height: 16),
              _buildProgressIndicator(context),
            ],
            if (widget.showCancel) ...[
              const SizedBox(height: 20),
              _buildCancelButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    if (widget.customIcon != null) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isIndeterminate ? _pulseAnimation.value : 1.0,
            child: widget.customIcon!,
          );
        },
      );
    }

    if (widget.animationAsset != null) {
      return SizedBox(
        width: 80,
        height: 80,
        child: Lottie.asset(
          widget.animationAsset!,
          fit: BoxFit.contain,
        ),
      );
    }

    return _buildDefaultLoadingIndicator(context);
  }

  Widget _buildDefaultLoadingIndicator(BuildContext context) {
    Widget indicator;

    switch (widget.type) {
      case LoadingType.download:
        indicator = Icon(
          LucideIcons.download,
          size: 32,
          color: widget.progressColor ?? OnflixColors.primary,
        );
        break;
      case LoadingType.upload:
        indicator = Icon(
          LucideIcons.upload,
          size: 32,
          color: widget.progressColor ?? OnflixColors.primary,
        );
        break;
      case LoadingType.processing:
        indicator = Icon(
          LucideIcons.cpu,
          size: 32,
          color: widget.progressColor ?? OnflixColors.primary,
        );
        break;
      case LoadingType.authentication:
        indicator = Icon(
          LucideIcons.userCheck,
          size: 32,
          color: widget.progressColor ?? OnflixColors.primary,
        );
        break;
      case LoadingType.sync:
        indicator = Icon(
          LucideIcons.refreshCw,
          size: 32,
          color: widget.progressColor ?? OnflixColors.primary,
        );
        break;
      case LoadingType.buffering:
        indicator = Icon(
          LucideIcons.play,
          size: 32,
          color: widget.progressColor ?? OnflixColors.primary,
        );
        break;
      case LoadingType.general:
      default:
        indicator = SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.progressColor ?? OnflixColors.primary,
            ),
          ),
        );
        break;
    }

    if (widget.type != LoadingType.general && widget.isIndeterminate) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (widget.progressColor ?? OnflixColors.primary)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(child: indicator),
            ),
          );
        },
      );
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: (widget.progressColor ?? OnflixColors.primary)
            .withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(child: indicator),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      widget.title!,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage(BuildContext context) {
    return Text(
      widget.message!,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      widget.description!,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: OnflixColors.lightGray,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: OnflixColors.lightGray.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.progressColor ?? OnflixColors.primary,
              ),
              minHeight: 6,
            );
          },
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            final percentage = (_progressAnimation.value * 100).round();
            return Text(
              '$percentage%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: OnflixColors.lightGray,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return CustomButton.ghost(
      text: widget.cancelText,
      onPressed: _handleCancel,
      size: CustomButtonSize.medium,
      icon: LucideIcons.x,
    );
  }
}

/// Loading overlay widget for showing loading states over existing content
class LoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? overlayColor;
  final Widget? customIndicator;
  final Duration animationDuration;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.overlayColor,
    this.customIndicator,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isLoading) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
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
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  color: widget.overlayColor ?? Colors.black54,
                  child: Center(
                    child: widget.customIndicator ?? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              OnflixColors.primary,
                            ),
                          ),
                        ),
                        if (widget.message != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            widget.message!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Loading type enumeration
enum LoadingType {
  general,
  download,
  upload,
  processing,
  authentication,
  sync,
  buffering,
}