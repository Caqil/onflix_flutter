import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../buttons/custom_button.dart';
import '../buttons/icon_button_widget.dart';
import 'custom_dialog.dart';

/// Error dialog widget for displaying errors with retry and support options
class ErrorDialog extends StatefulWidget {
  final String title;
  final String message;
  final String? description;
  final String? errorCode;
  final String? technicalDetails;
  final VoidCallback? onRetry;
  final VoidCallback? onSupport;
  final VoidCallback? onClose;
  final VoidCallback? onDismiss;
  final ErrorType type;
  final bool showRetryButton;
  final bool showSupportButton;
  final bool showTechnicalDetails;
  final bool barrierDismissible;
  final String retryText;
  final String supportText;
  final String closeText;
  final Widget? customIcon;
  final List<ErrorAction>? customActions;
  final Duration animationDuration;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.description,
    this.errorCode,
    this.technicalDetails,
    this.onRetry,
    this.onSupport,
    this.onClose,
    this.onDismiss,
    this.type = ErrorType.general,
    this.showRetryButton = false,
    this.showSupportButton = true,
    this.showTechnicalDetails = false,
    this.barrierDismissible = true,
    this.retryText = 'Try Again',
    this.supportText = 'Contact Support',
    this.closeText = 'Close',
    this.customIcon,
    this.customActions,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  // Named constructors for specific error types
  const ErrorDialog.network({
    super.key,
    this.title = 'Connection Error',
    this.message = 'Unable to connect to the server. Please check your internet connection.',
    this.description,
    this.errorCode,
    this.technicalDetails,
    this.onRetry,
    this.onSupport,
    this.onClose,
    this.onDismiss,
    this.showRetryButton = true,
    this.showSupportButton = false,
    this.showTechnicalDetails = false,
    this.barrierDismissible = true,
    this.retryText = 'Retry',
    this.supportText = 'Contact Support',
    this.closeText = 'Close',
    this.customIcon,
    this.customActions,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : type = ErrorType.network;

  const ErrorDialog.server({
    super.key,
    this.title = 'Server Error',
    this.message = 'Something went wrong on our end. Please try again later.',
    this.description,
    this.errorCode,
    this.technicalDetails,
    this.onRetry,
    this.onSupport,
    this.onClose,
    this.onDismiss,
    this.showRetryButton = true,
    this.showSupportButton = true,
    this.showTechnicalDetails = true,
    this.barrierDismissible = true,
    this.retryText = 'Try Again',
    this.supportText = 'Report Issue',
    this.closeText = 'Close',
    this.customIcon,
    this.customActions,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : type = ErrorType.server;

  const ErrorDialog.authentication({
    super.key,
    this.title = 'Authentication Error',
    this.message = 'Your session has expired. Please sign in again.',
    this.description,
    this.errorCode,
    this.technicalDetails,
    this.onRetry,
    this.onSupport,
    this.onClose,
    this.onDismiss,
    this.showRetryButton = false,
    this.showSupportButton = false,
    this.showTechnicalDetails = false,
    this.barrierDismissible = false,
    this.retryText = 'Sign In',
    this.supportText = 'Contact Support',
    this.closeText = 'Close',
    this.customIcon,
    this.customActions,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : type = ErrorType.authentication;

  const ErrorDialog.validation({
    super.key,
    this.title = 'Invalid Input',
    this.message = 'Please check your input and try again.',
    this.description,
    this.errorCode,
    this.technicalDetails,
    this.onRetry,
    this.onSupport,
    this.onClose,
    this.onDismiss,
    this.showRetryButton = false,
    this.showSupportButton = false,
    this.showTechnicalDetails = false,
    this.barrierDismissible = true,
    this.retryText = 'Try Again',
    this.supportText = 'Contact Support',
    this.closeText = 'OK',
    this.customIcon,
    this.customActions,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : type = ErrorType.validation;

  const ErrorDialog.playback({
    super.key,
    this.title = 'Playback Error',
    this.message = 'Unable to play this content. Please try again.',
    this.description,
    this.errorCode,
    this.technicalDetails,
    this.onRetry,
    this.onSupport,
    this.onClose,
    this.onDismiss,
    this.showRetryButton = true,
    this.showSupportButton = true,
    this.showTechnicalDetails = false,
    this.barrierDismissible = true,
    this.retryText = 'Retry Playback',
    this.supportText = 'Report Issue',
    this.closeText = 'Close',
    this.customIcon,
    this.customActions,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : type = ErrorType.playback;

  const ErrorDialog.download({
    super.key,
    this.title = 'Download Error',
    this.message = 'Failed to download content. Please try again.',
    this.description,
    this.errorCode,
    this.technicalDetails,
    this.onRetry,
    this.onSupport,
    this.onClose,
    this.onDismiss,
    this.showRetryButton = true,
    this.showSupportButton = false,
    this.showTechnicalDetails = false,
    this.barrierDismissible = true,
    this.retryText = 'Retry Download',
    this.supportText = 'Contact Support',
    this.closeText = 'Close',
    this.customIcon,
    this.customActions,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : type = ErrorType.download;

  @override
  State<ErrorDialog> createState() => _ErrorDialogState();

  /// Static method to show the error dialog
  static Future<ErrorDialogResult?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? description,
    String? errorCode,
    String? technicalDetails,
    VoidCallback? onRetry,
    VoidCallback? onSupport,
    VoidCallback? onClose,
    VoidCallback? onDismiss,
    ErrorType type = ErrorType.general,
    bool showRetryButton = false,
    bool showSupportButton = true,
    bool showTechnicalDetails = false,
    bool barrierDismissible = true,
    String retryText = 'Try Again',
    String supportText = 'Contact Support',
    String closeText = 'Close',
    Widget? customIcon,
    List<ErrorAction>? customActions,
  }) {
    return showDialog<ErrorDialogResult>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        description: description,
        errorCode: errorCode,
        technicalDetails: technicalDetails,
        onRetry: onRetry,
        onSupport: onSupport,
        onClose: onClose,
        onDismiss: onDismiss,
        type: type,
        showRetryButton: showRetryButton,
        showSupportButton: showSupportButton,
        showTechnicalDetails: showTechnicalDetails,
        barrierDismissible: barrierDismissible,
        retryText: retryText,
        supportText: supportText,
        closeText: closeText,
        customIcon: customIcon,
        customActions: customActions,
      ),
    );
  }

  /// Static method to show network error
  static Future<ErrorDialogResult?> showNetworkError({
    required BuildContext context,
    VoidCallback? onRetry,
    VoidCallback? onClose,
  }) {
    return show(
      context: context,
      title: 'Connection Error',
      message: 'Unable to connect to Onflix. Please check your internet connection.',
      type: ErrorType.network,
      showRetryButton: true,
      showSupportButton: false,
      onRetry: onRetry,
      onClose: onClose,
    );
  }

  /// Static method to show server error
  static Future<ErrorDialogResult?> showServerError({
    required BuildContext context,
    String? errorCode,
    String? technicalDetails,
    VoidCallback? onRetry,
    VoidCallback? onSupport,
  }) {
    return show(
      context: context,
      title: 'Server Error',
      message: 'Something went wrong on our end. Our team has been notified.',
      errorCode: errorCode,
      technicalDetails: technicalDetails,
      type: ErrorType.server,
      showRetryButton: true,
      showSupportButton: true,
      showTechnicalDetails: true,
      onRetry: onRetry,
      onSupport: onSupport,
    );
  }

  /// Static method to show playback error
  static Future<ErrorDialogResult?> showPlaybackError({
    required BuildContext context,
    String? errorCode,
    VoidCallback? onRetry,
    VoidCallback? onSupport,
  }) {
    return show(
      context: context,
      title: 'Playback Error',
      message: 'Unable to play this content. This might be due to network issues or content restrictions.',
      errorCode: errorCode,
      type: ErrorType.playback,
      showRetryButton: true,
      showSupportButton: true,
      retryText: 'Retry Playback',
      supportText: 'Report Issue',
      onRetry: onRetry,
      onSupport: onSupport,
    );
  }
}

class _ErrorDialogState extends State<ErrorDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  bool _showTechnicalDetails = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _showTechnicalDetails = widget.showTechnicalDetails;
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

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleAction(ErrorDialogResult result) {
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop(result);
        
        switch (result) {
          case ErrorDialogResult.retry:
            widget.onRetry?.call();
            break;
          case ErrorDialogResult.support:
            widget.onSupport?.call();
            break;
          case ErrorDialogResult.close:
            widget.onClose?.call();
            break;
          case ErrorDialogResult.dismiss:
            widget.onDismiss?.call();
            break;
        }
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
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    (1 - _shakeAnimation.value) * 10 * 
                    (widget.type == ErrorType.validation ? 1 : 0),
                    0,
                  ),
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: _buildErrorDialog(context),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorDialog(BuildContext context) {
    return ShadCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildContent(context),
            if (widget.technicalDetails != null && 
                widget.technicalDetails!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildTechnicalDetailsToggle(context),
            ],
            const SizedBox(height: 24),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildIcon(context),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getErrorColor(),
                ),
              ),
              if (widget.errorCode != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Error Code: ${widget.errorCode}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: OnflixColors.lightGray,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ],
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
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _getErrorColor().withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getErrorIcon(),
        size: 28,
        color: _getErrorColor(),
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
        if (_showTechnicalDetails && 
            widget.technicalDetails != null && 
            widget.technicalDetails!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: OnflixColors.mediumGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: OnflixColors.lightGray.withOpacity(0.2),
              ),
            ),
            child: Text(
              widget.technicalDetails!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: OnflixColors.lightGray,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTechnicalDetailsToggle(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showTechnicalDetails = !_showTechnicalDetails;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _showTechnicalDetails 
                ? LucideIcons.chevronUp 
                : LucideIcons.chevronDown,
            size: 16,
            color: OnflixColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            _showTechnicalDetails 
                ? 'Hide Technical Details' 
                : 'Show Technical Details',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: OnflixColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (widget.customActions != null) {
      return _buildCustomActions(context);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.showSupportButton)
          CustomButton.ghost(
            text: widget.supportText,
            onPressed: () => _handleAction(ErrorDialogResult.support),
            icon: LucideIcons.headphones,
            size: CustomButtonSize.medium,
          ),
        
        if (widget.showSupportButton && widget.showRetryButton)
          const SizedBox(width: 12),
        
        if (widget.showRetryButton)
          CustomButton.secondary(
            text: widget.retryText,
            onPressed: () => _handleAction(ErrorDialogResult.retry),
            icon: LucideIcons.refreshCw,
            size: CustomButtonSize.medium,
          ),
        
        if ((widget.showSupportButton || widget.showRetryButton))
          const SizedBox(width: 12),
        
        CustomButton.primary(
          text: widget.closeText,
          onPressed: () => _handleAction(ErrorDialogResult.close),
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

  IconData _getErrorIcon() {
    switch (widget.type) {
      case ErrorType.network:
        return LucideIcons.wifiOff;
      case ErrorType.server:
        return LucideIcons.serverCrash;
      case ErrorType.authentication:
        return LucideIcons.userX;
      case ErrorType.validation:
        return LucideIcons.triangleAlert;
      case ErrorType.playback:
        return LucideIcons.circlePlay;
      case ErrorType.download:
        return LucideIcons.download;
      case ErrorType.general:
      default:
        return LucideIcons.circleAlert;
    }
  }

  Color _getErrorColor() {
    switch (widget.type) {
      case ErrorType.network:
      case ErrorType.download:
        return OnflixColors.warning;
      case ErrorType.server:
      case ErrorType.general:
      case ErrorType.playback:
        return OnflixColors.error;
      case ErrorType.authentication:
        return OnflixColors.primary;
      case ErrorType.validation:
        return OnflixColors.warning;
    }
  }
}

/// Error action model for custom actions
class ErrorAction {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final IconData? icon;
  final ErrorDialogResult result;

  const ErrorAction({
    required this.text,
    this.onPressed,
    this.variant = CustomButtonVariant.secondary,
    this.icon,
    this.result = ErrorDialogResult.close,
  });
}

/// Error type enumeration
enum ErrorType {
  general,
  network,
  server,
  authentication,
  validation,
  playback,
  download,
}

/// Error dialog result enumeration
enum ErrorDialogResult {
  retry,
  support,
  close,
  dismiss,
}