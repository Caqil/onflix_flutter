import 'package:flutter/material.dart';
import 'package:onflix/core/constants/app_constants.dart';
import 'package:onflix/core/extensions/context_extension.dart';
import 'package:onflix/core/utils/responsive_helper.dart';

class CustomErrorWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final String? iconAsset;
  final String? primaryActionText;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;
  final ErrorType type;
  final EdgeInsets? padding;
  final bool centerContent;
  final bool showDetails;
  final String? technicalDetails;

  const CustomErrorWidget({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.iconAsset,
    this.primaryActionText,
    this.onPrimaryAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.type = ErrorType.generic,
    this.padding,
    this.centerContent = true,
    this.showDetails = false,
    this.technicalDetails,
  });

  const CustomErrorWidget.network({
    super.key,
    this.title = 'Connection Error',
    this.message = 'Please check your internet connection and try again.',
    this.primaryActionText = 'Retry',
    this.onPrimaryAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.padding,
    this.centerContent = true,
    this.showDetails = false,
    this.technicalDetails,
  })  : type = ErrorType.network,
        icon = Icons.wifi_off,
        iconAsset = null;

  const CustomErrorWidget.server({
    super.key,
    this.title = 'Server Error',
    this.message = 'Something went wrong on our end. Please try again later.',
    this.primaryActionText = 'Try Again',
    this.onPrimaryAction,
    this.secondaryActionText = 'Contact Support',
    this.onSecondaryAction,
    this.padding,
    this.centerContent = true,
    this.showDetails = false,
    this.technicalDetails,
  })  : type = ErrorType.server,
        icon = Icons.cloud_off,
        iconAsset = null;

  const CustomErrorWidget.notFound({
    super.key,
    this.title = 'Content Not Found',
    this.message = 'The content you\'re looking for could not be found.',
    this.primaryActionText = 'Go Back',
    this.onPrimaryAction,
    this.secondaryActionText = 'Browse Content',
    this.onSecondaryAction,
    this.padding,
    this.centerContent = true,
    this.showDetails = false,
    this.technicalDetails,
  })  : type = ErrorType.notFound,
        icon = Icons.search_off,
        iconAsset = null;

  const CustomErrorWidget.unauthorized({
    super.key,
    this.title = 'Access Denied',
    this.message = 'You don\'t have permission to access this content.',
    this.primaryActionText = 'Sign In',
    this.onPrimaryAction,
    this.secondaryActionText = 'Go Home',
    this.onSecondaryAction,
    this.padding,
    this.centerContent = true,
    this.showDetails = false,
    this.technicalDetails,
  })  : type = ErrorType.unauthorized,
        icon = Icons.lock,
        iconAsset = null;

  const CustomErrorWidget.playback({
    super.key,
    this.title = 'Playback Error',
    this.message = 'Unable to play this content. Please try again.',
    this.primaryActionText = 'Retry',
    this.onPrimaryAction,
    this.secondaryActionText = 'Report Issue',
    this.onSecondaryAction,
    this.padding,
    this.centerContent = true,
    this.showDetails = false,
    this.technicalDetails,
  })  : type = ErrorType.playback,
        icon = Icons.play_disabled,
        iconAsset = null;

  const CustomErrorWidget.maintenance({
    super.key,
    this.title = 'Under Maintenance',
    this.message =
        'We\'re currently performing maintenance. Please check back later.',
    this.primaryActionText = 'Check Status',
    this.onPrimaryAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.padding,
    this.centerContent = true,
    this.showDetails = false,
    this.technicalDetails,
  })  : type = ErrorType.maintenance,
        icon = Icons.build,
        iconAsset = null;

  @override
  Widget build(BuildContext context) {
    final contentPadding = padding ??
        EdgeInsets.all(ResponsiveHelper.getScaledPadding(context, 32));

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(context),
        SizedBox(height: ResponsiveHelper.getScaledPadding(context, 24)),
        _buildTitle(context),
        if (message != null) ...[
          SizedBox(height: ResponsiveHelper.getScaledPadding(context, 12)),
          _buildMessage(context),
        ],
        if (showDetails && technicalDetails != null) ...[
          SizedBox(height: ResponsiveHelper.getScaledPadding(context, 16)),
          _buildTechnicalDetails(context),
        ],
        SizedBox(height: ResponsiveHelper.getScaledPadding(context, 32)),
        _buildActions(context),
      ],
    );

    if (centerContent) {
      return Padding(
        padding: contentPadding,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.responsive(
                context,
                mobile: double.infinity,
                tablet: 400,
                desktop: 500,
              ),
            ),
            child: content,
          ),
        ),
      );
    }

    return Padding(
      padding: contentPadding,
      child: content,
    );
  }

  Widget _buildIcon(BuildContext context) {
    final iconSize = ResponsiveHelper.responsive(
      context,
      mobile: 80.0,
      tablet: 96.0,
      desktop: 112.0,
    );

    if (iconAsset != null) {
      return Image.asset(
        iconAsset!,
        width: iconSize,
        height: iconSize,
        color: _getIconColor(context),
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultIcon(context, iconSize);
        },
      );
    }

    return _buildDefaultIcon(context, iconSize);
  }

  Widget _buildDefaultIcon(BuildContext context, double iconSize) {
    final displayIcon = icon ?? _getDefaultIcon();

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: _getIconBackgroundColor(context),
        shape: BoxShape.circle,
      ),
      child: Icon(
        displayIcon,
        size: iconSize * 0.5,
        color: _getIconColor(context),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.headlineSmall?.copyWith(
        color: _getTitleColor(context),
        fontWeight: FontWeight.bold,
        fontSize: ResponsiveHelper.getScaledFontSize(context, 24),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage(BuildContext context) {
    return Text(
      message!,
      style: context.textTheme.bodyLarge?.copyWith(
        color: context.colorScheme.onSurfaceVariant,
        fontSize: ResponsiveHelper.getScaledFontSize(context, 16),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTechnicalDetails(BuildContext context) {
    return ExpansionTile(
      title: Text(
        'Technical Details',
        style: context.textTheme.bodyMedium?.copyWith(
          fontSize: ResponsiveHelper.getScaledFontSize(context, 14),
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding:
              EdgeInsets.all(ResponsiveHelper.getScaledPadding(context, 16)),
          margin: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getScaledPadding(context, 16),
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppConstants.smallRadius),
          ),
          child: Text(
            technicalDetails!,
            style: context.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontSize: ResponsiveHelper.getScaledFontSize(context, 12),
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final actions = <Widget>[];

    if (primaryActionText != null && onPrimaryAction != null) {
      actions.add(
        ElevatedButton.icon(
          onPressed: onPrimaryAction,
          icon: Icon(_getPrimaryActionIcon()),
          label: Text(primaryActionText!),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getPrimaryButtonColor(context),
            foregroundColor: _getPrimaryButtonTextColor(context),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getScaledPadding(context, 24),
              vertical: ResponsiveHelper.getScaledPadding(context, 12),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
          ),
        ),
      );
    }

    if (secondaryActionText != null && onSecondaryAction != null) {
      if (actions.isNotEmpty) {
        actions.add(SizedBox(
          width: ResponsiveHelper.getScaledPadding(context, 16),
        ));
      }

      actions.add(
        OutlinedButton.icon(
          onPressed: onSecondaryAction,
          icon: Icon(_getSecondaryActionIcon()),
          label: Text(secondaryActionText!),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getScaledPadding(context, 24),
              vertical: ResponsiveHelper.getScaledPadding(context, 12),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
          ),
        ),
      );
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Stack buttons vertically on mobile, horizontally on larger screens
    if (ResponsiveHelper.isMobile(context) && actions.length > 1) {
      return Column(
        children: actions
            .map((action) => Padding(
                  padding: EdgeInsets.only(
                    bottom: action == actions.last
                        ? 0
                        : ResponsiveHelper.getScaledPadding(context, 12),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: action,
                  ),
                ))
            .toList(),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: actions,
    );
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.unauthorized:
        return Icons.lock;
      case ErrorType.playback:
        return Icons.play_disabled;
      case ErrorType.maintenance:
        return Icons.build;
      case ErrorType.generic:
        return Icons.error_outline;
    }
  }

  Color _getIconBackgroundColor(BuildContext context) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange.withOpacity(0.1);
      case ErrorType.server:
        return Colors.red.withOpacity(0.1);
      case ErrorType.notFound:
        return Colors.blue.withOpacity(0.1);
      case ErrorType.unauthorized:
        return Colors.purple.withOpacity(0.1);
      case ErrorType.playback:
        return Colors.red.withOpacity(0.1);
      case ErrorType.maintenance:
        return Colors.grey.withOpacity(0.1);
      case ErrorType.generic:
      default:
        return context.colorScheme.error.withOpacity(0.1);
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.server:
        return Colors.red;
      case ErrorType.notFound:
        return Colors.blue;
      case ErrorType.unauthorized:
        return Colors.purple;
      case ErrorType.playback:
        return Colors.red;
      case ErrorType.maintenance:
        return Colors.grey;
      case ErrorType.generic:
        return context.colorScheme.error;
    }
  }

  Color _getTitleColor(BuildContext context) {
    return context.colorScheme.onSurface;
  }

  Color _getPrimaryButtonColor(BuildContext context) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.server:
        return context.colorScheme.error;
      case ErrorType.notFound:
        return Colors.blue;
      case ErrorType.unauthorized:
        return Colors.purple;
      case ErrorType.playback:
        return context.colorScheme.error;
      case ErrorType.maintenance:
        return Colors.grey;
      case ErrorType.generic:
        return context.colorScheme.primary;
    }
  }

  Color _getPrimaryButtonTextColor(BuildContext context) {
    return Colors.white;
  }

  IconData _getPrimaryActionIcon() {
    switch (type) {
      case ErrorType.network:
      case ErrorType.server:
      case ErrorType.playback:
        return Icons.refresh;
      case ErrorType.notFound:
        return Icons.arrow_back;
      case ErrorType.unauthorized:
        return Icons.login;
      case ErrorType.maintenance:
        return Icons.info_outline;
      case ErrorType.generic:
        return Icons.refresh;
    }
  }

  IconData _getSecondaryActionIcon() {
    switch (type) {
      case ErrorType.server:
      case ErrorType.playback:
        return Icons.support;
      case ErrorType.notFound:
        return Icons.home;
      case ErrorType.unauthorized:
        return Icons.home;
      case ErrorType.generic:
      default:
        return Icons.help;
    }
  }
}

class CompactErrorWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;
  final Color? backgroundColor;

  const CompactErrorWidget({
    super.key,
    required this.message,
    this.icon,
    this.onRetry,
    this.retryText,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.getScaledPadding(context, 16)),
      margin: EdgeInsets.all(ResponsiveHelper.getScaledPadding(context, 8)),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: context.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: context.colorScheme.error,
            size: ResponsiveHelper.getScaledIconSize(context, 24),
          ),
          SizedBox(width: ResponsiveHelper.getScaledPadding(context, 12)),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onErrorContainer,
                fontSize: ResponsiveHelper.getScaledFontSize(context, 14),
              ),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(width: ResponsiveHelper.getScaledPadding(context, 12)),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: context.colorScheme.error,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getScaledPadding(context, 12),
                  vertical: ResponsiveHelper.getScaledPadding(context, 4),
                ),
              ),
              child: Text(
                retryText ?? 'Retry',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getScaledFontSize(context, 12),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String message;
  final IconData? icon;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionText;
  final ErrorSeverity severity;

  const ErrorBanner({
    super.key,
    required this.message,
    this.icon,
    this.onDismiss,
    this.onAction,
    this.actionText,
    this.severity = ErrorSeverity.error,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getSeverityColors(context);

    return Material(
      color: colors.backgroundColor,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getScaledPadding(context, 16),
          vertical: ResponsiveHelper.getScaledPadding(context, 12),
        ),
        child: Row(
          children: [
            Icon(
              icon ?? _getSeverityIcon(),
              color: colors.iconColor,
              size: ResponsiveHelper.getScaledIconSize(context, 20),
            ),
            SizedBox(width: ResponsiveHelper.getScaledPadding(context, 12)),
            Expanded(
              child: Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textColor,
                  fontSize: ResponsiveHelper.getScaledFontSize(context, 14),
                ),
              ),
            ),
            if (onAction != null && actionText != null) ...[
              SizedBox(width: ResponsiveHelper.getScaledPadding(context, 12)),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: colors.actionColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getScaledPadding(context, 8),
                    vertical: ResponsiveHelper.getScaledPadding(context, 4),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getScaledFontSize(context, 12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (onDismiss != null) ...[
              SizedBox(width: ResponsiveHelper.getScaledPadding(context, 8)),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close,
                  color: colors.iconColor,
                  size: ResponsiveHelper.getScaledIconSize(context, 18),
                ),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getSeverityIcon() {
    switch (severity) {
      case ErrorSeverity.error:
        return Icons.error;
      case ErrorSeverity.warning:
        return Icons.warning;
      case ErrorSeverity.info:
        return Icons.info;
    }
  }

  _SeverityColors _getSeverityColors(BuildContext context) {
    switch (severity) {
      case ErrorSeverity.error:
        return _SeverityColors(
          backgroundColor: context.colorScheme.errorContainer,
          textColor: context.colorScheme.onErrorContainer,
          iconColor: context.colorScheme.error,
          actionColor: context.colorScheme.error,
        );
      case ErrorSeverity.warning:
        return _SeverityColors(
          backgroundColor: Colors.orange.withOpacity(0.1),
          textColor: Colors.orange.shade800,
          iconColor: Colors.orange,
          actionColor: Colors.orange.shade700,
        );
      case ErrorSeverity.info:
        return _SeverityColors(
          backgroundColor: Colors.blue.withOpacity(0.1),
          textColor: Colors.blue.shade800,
          iconColor: Colors.blue,
          actionColor: Colors.blue.shade700,
        );
    }
  }
}

class ErrorCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final ErrorType type;

  const ErrorCard({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.onRetry,
    this.onDismiss,
    this.type = ErrorType.generic,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.defaultElevation,
      margin: EdgeInsets.all(ResponsiveHelper.getScaledPadding(context, 8)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(ResponsiveHelper.getScaledPadding(context, 20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon ?? Icons.error_outline,
                  color: context.colorScheme.error,
                  size: ResponsiveHelper.getScaledIconSize(context, 24),
                ),
                SizedBox(width: ResponsiveHelper.getScaledPadding(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colorScheme.error,
                          fontWeight: FontWeight.w600,
                          fontSize:
                              ResponsiveHelper.getScaledFontSize(context, 16),
                        ),
                      ),
                      SizedBox(
                          height:
                              ResponsiveHelper.getScaledPadding(context, 4)),
                      Text(
                        message,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                          fontSize:
                              ResponsiveHelper.getScaledFontSize(context, 14),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    icon: Icon(
                      Icons.close,
                      color: context.colorScheme.onSurfaceVariant,
                      size: ResponsiveHelper.getScaledIconSize(context, 20),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            if (onRetry != null) ...[
              SizedBox(height: ResponsiveHelper.getScaledPadding(context, 16)),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorOverlay extends StatelessWidget {
  final Widget child;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorOverlay({
    super.key,
    required this.child,
    required this.hasError,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (hasError)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                margin: EdgeInsets.all(
                    ResponsiveHelper.getScaledPadding(context, 24)),
                padding: EdgeInsets.all(
                    ResponsiveHelper.getScaledPadding(context, 24)),
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius:
                      BorderRadius.circular(AppConstants.defaultRadius),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: ResponsiveHelper.getScaledIconSize(context, 48),
                      color: context.colorScheme.error,
                    ),
                    SizedBox(
                        height: ResponsiveHelper.getScaledPadding(context, 16)),
                    Text(
                      errorMessage ?? 'An error occurred',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (onRetry != null) ...[
                      SizedBox(
                          height:
                              ResponsiveHelper.getScaledPadding(context, 16)),
                      ElevatedButton(
                        onPressed: onRetry,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

enum ErrorType {
  generic,
  network,
  server,
  notFound,
  unauthorized,
  playback,
  maintenance,
}

enum ErrorSeverity {
  error,
  warning,
  info,
}

class _SeverityColors {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color actionColor;

  const _SeverityColors({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.actionColor,
  });
}
