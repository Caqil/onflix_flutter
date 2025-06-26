import 'package:flutter/material.dart';
import 'package:onflix/core/constants/app_constants.dart';
import 'package:onflix/core/extensions/context_extension.dart';
import 'package:onflix/core/utils/responsive_helper.dart';


class BadgeWidget extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? iconSize;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final BadgeVariant variant;
  final BadgeSize size;
  final bool showBorder;
  final Color? borderColor;
  final VoidCallback? onTap;

  const BadgeWidget({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.iconSize,
    this.padding,
    this.borderRadius,
    this.variant = BadgeVariant.primary,
    this.size = BadgeSize.medium,
    this.showBorder = false,
    this.borderColor,
    this.onTap,
  });

  const BadgeWidget.success({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.iconSize,
    this.padding,
    this.borderRadius,
    this.size = BadgeSize.medium,
    this.showBorder = false,
    this.borderColor,
    this.onTap,
  }) : variant = BadgeVariant.success;

  const BadgeWidget.error({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.iconSize,
    this.padding,
    this.borderRadius,
    this.size = BadgeSize.medium,
    this.showBorder = false,
    this.borderColor,
    this.onTap,
  }) : variant = BadgeVariant.error;

  const BadgeWidget.warning({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.iconSize,
    this.padding,
    this.borderRadius,
    this.size = BadgeSize.medium,
    this.showBorder = false,
    this.borderColor,
    this.onTap,
  }) : variant = BadgeVariant.warning;

  const BadgeWidget.info({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.iconSize,
    this.padding,
    this.borderRadius,
    this.size = BadgeSize.medium,
    this.showBorder = false,
    this.borderColor,
    this.onTap,
  }) : variant = BadgeVariant.info;

  const BadgeWidget.premium({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon = Icons.star,
    this.iconSize,
    this.padding,
    this.borderRadius,
    this.size = BadgeSize.medium,
    this.showBorder = false,
    this.borderColor,
    this.onTap,
  }) : variant = BadgeVariant.premium;

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(context);
    final dimensions = _getDimensions(context);

    Widget badge = Container(
      padding: padding ?? dimensions.padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(dimensions.radius),
        border: showBorder
            ? Border.all(
                color: borderColor ?? colors.borderColor,
                width: 1,
              )
            : null,
        boxShadow: variant == BadgeVariant.premium
            ? [
                BoxShadow(
                  color: (backgroundColor ?? colors.backgroundColor)
                      .withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: iconSize ?? dimensions.iconSize,
              color: textColor ?? colors.textColor,
            ),
            if (text.isNotEmpty) SizedBox(width: dimensions.spacing),
          ],
          if (text.isNotEmpty)
            Text(
              text,
              style: dimensions.textStyle.copyWith(
                color: textColor ?? colors.textColor,
              ),
            ),
        ],
      ),
    );

    if (onTap != null) {
      badge = GestureDetector(
        onTap: onTap,
        child: badge,
      );
    }

    return badge;
  }

  _BadgeColors _getColors(BuildContext context) {
    switch (variant) {
      case BadgeVariant.primary:
        return _BadgeColors(
          backgroundColor: context.colorScheme.primary,
          textColor: context.colorScheme.onPrimary,
          borderColor: context.colorScheme.primary.withOpacity(0.3),
        );
      case BadgeVariant.secondary:
        return _BadgeColors(
          backgroundColor: context.colorScheme.secondary,
          textColor: context.colorScheme.onSecondary,
          borderColor: context.colorScheme.secondary.withOpacity(0.3),
        );
      case BadgeVariant.success:
        return _BadgeColors(
          backgroundColor: Colors.green,
          textColor: Colors.white,
          borderColor: Colors.green.withOpacity(0.3),
        );
      case BadgeVariant.error:
        return _BadgeColors(
          backgroundColor: context.colorScheme.error,
          textColor: context.colorScheme.onError,
          borderColor: context.colorScheme.error.withOpacity(0.3),
        );
      case BadgeVariant.warning:
        return _BadgeColors(
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          borderColor: Colors.orange.withOpacity(0.3),
        );
      case BadgeVariant.info:
        return _BadgeColors(
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          borderColor: Colors.blue.withOpacity(0.3),
        );
      case BadgeVariant.premium:
        return _BadgeColors(
          backgroundColor: const Color(0xFFFFD700), // Gold
          textColor: Colors.black,
          borderColor: const Color(0xFFFFD700).withOpacity(0.3),
        );
      case BadgeVariant.outline:
        return _BadgeColors(
          backgroundColor: Colors.transparent,
          textColor: context.colorScheme.onSurface,
          borderColor: context.colorScheme.outline,
        );
    }
  }

  _BadgeDimensions _getDimensions(BuildContext context) {
    switch (size) {
      case BadgeSize.small:
        return _BadgeDimensions(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getScaledPadding(context, 6),
            vertical: ResponsiveHelper.getScaledPadding(context, 2),
          ),
          textStyle: context.textTheme.bodySmall!.copyWith(
            fontSize: ResponsiveHelper.getScaledFontSize(context, 10),
            fontWeight: FontWeight.w600,
          ),
          iconSize: ResponsiveHelper.getScaledIconSize(context, 12),
          radius: AppConstants.smallRadius,
          spacing: ResponsiveHelper.getScaledPadding(context, 2),
        );
      case BadgeSize.medium:
        return _BadgeDimensions(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getScaledPadding(context, 8),
            vertical: ResponsiveHelper.getScaledPadding(context, 4),
          ),
          textStyle: context.textTheme.bodySmall!.copyWith(
            fontSize: ResponsiveHelper.getScaledFontSize(context, 12),
            fontWeight: FontWeight.w600,
          ),
          iconSize: ResponsiveHelper.getScaledIconSize(context, 14),
          radius: AppConstants.defaultRadius,
          spacing: ResponsiveHelper.getScaledPadding(context, 4),
        );
      case BadgeSize.large:
        return _BadgeDimensions(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getScaledPadding(context, 12),
            vertical: ResponsiveHelper.getScaledPadding(context, 6),
          ),
          textStyle: context.textTheme.bodyMedium!.copyWith(
            fontSize: ResponsiveHelper.getScaledFontSize(context, 14),
            fontWeight: FontWeight.w600,
          ),
          iconSize: ResponsiveHelper.getScaledIconSize(context, 16),
          radius: AppConstants.defaultRadius,
          spacing: ResponsiveHelper.getScaledPadding(context, 6),
        );
    }
  }
}

class CountBadge extends StatelessWidget {
  final int count;
  final int? maxCount;
  final Color? backgroundColor;
  final Color? textColor;
  final double? size;
  final bool showWhenZero;

  const CountBadge({
    super.key,
    required this.count,
    this.maxCount = 99,
    this.backgroundColor,
    this.textColor,
    this.size,
    this.showWhenZero = false,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0 && !showWhenZero) {
      return const SizedBox.shrink();
    }

    final badgeSize = size ?? ResponsiveHelper.getScaledIconSize(context, 20);
    final displayText =
        count > (maxCount ?? 99) ? '${maxCount}+' : count.toString();

    return Container(
      constraints: BoxConstraints(
        minWidth: badgeSize,
        minHeight: badgeSize,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getScaledPadding(context, 4),
        vertical: ResponsiveHelper.getScaledPadding(context, 2),
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorScheme.error,
        borderRadius: BorderRadius.circular(badgeSize / 2),
      ),
      child: Text(
        displayText,
        style: context.textTheme.bodySmall?.copyWith(
          color: textColor ?? context.colorScheme.onError,
          fontSize: ResponsiveHelper.getScaledFontSize(context, 10),
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class DotBadge extends StatelessWidget {
  final Color? color;
  final double? size;
  final bool isVisible;

  const DotBadge({
    super.key,
    this.color,
    this.size,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    final dotSize = size ?? ResponsiveHelper.getScaledIconSize(context, 8);

    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: color ?? context.colorScheme.error,
        shape: BoxShape.circle,
      ),
    );
  }
}

class QualityBadge extends StatelessWidget {
  final String quality;
  final QualityType type;

  const QualityBadge({
    super.key,
    required this.quality,
    this.type = QualityType.video,
  });

  const QualityBadge.hd({super.key})
      : quality = 'HD',
        type = QualityType.video;

  const QualityBadge.fourK({super.key})
      : quality = '4K',
        type = QualityType.video;

  const QualityBadge.dolby({super.key})
      : quality = 'Dolby',
        type = QualityType.audio;

  @override
  Widget build(BuildContext context) {
    return BadgeWidget(
      text: quality,
      variant: _getVariant(),
      size: BadgeSize.small,
      backgroundColor: _getBackgroundColor(),
      textColor: _getTextColor(),
    );
  }

  BadgeVariant _getVariant() {
    switch (quality.toLowerCase()) {
      case '4k':
      case 'uhd':
        return BadgeVariant.premium;
      case 'hd':
      case '1080p':
        return BadgeVariant.info;
      case 'sd':
      case '720p':
        return BadgeVariant.secondary;
      default:
        return BadgeVariant.outline;
    }
  }

  Color? _getBackgroundColor() {
    switch (quality.toLowerCase()) {
      case '4k':
      case 'uhd':
        return const Color(0xFFFFD700); // Gold
      case 'dolby':
        return const Color(0xFF6B46C1); // Purple
      default:
        return null;
    }
  }

  Color? _getTextColor() {
    switch (quality.toLowerCase()) {
      case '4k':
      case 'uhd':
        return Colors.black;
      case 'dolby':
        return Colors.white;
      default:
        return null;
    }
  }
}

class StatusBadge extends StatelessWidget {
  final ContentStatus status;
  final BadgeSize size;

  const StatusBadge({
    super.key,
    required this.status,
    this.size = BadgeSize.small,
  });

  @override
  Widget build(BuildContext context) {
    return BadgeWidget(
      text: _getStatusText(),
      variant: _getVariant(),
      size: size,
      icon: _getIcon(),
    );
  }

  String _getStatusText() {
    switch (status) {
      case ContentStatus.new_:
        return 'NEW';
      case ContentStatus.trending:
        return 'TRENDING';
      case ContentStatus.popular:
        return 'POPULAR';
      case ContentStatus.featured:
        return 'FEATURED';
      case ContentStatus.exclusive:
        return 'EXCLUSIVE';
      case ContentStatus.comingSoon:
        return 'COMING SOON';
      case ContentStatus.live:
        return 'LIVE';
    }
  }

  BadgeVariant _getVariant() {
    switch (status) {
      case ContentStatus.new_:
        return BadgeVariant.success;
      case ContentStatus.trending:
        return BadgeVariant.error;
      case ContentStatus.popular:
        return BadgeVariant.warning;
      case ContentStatus.featured:
        return BadgeVariant.premium;
      case ContentStatus.exclusive:
        return BadgeVariant.primary;
      case ContentStatus.comingSoon:
        return BadgeVariant.info;
      case ContentStatus.live:
        return BadgeVariant.error;
    }
  }

  IconData? _getIcon() {
    switch (status) {
      case ContentStatus.trending:
        return Icons.trending_up;
      case ContentStatus.live:
        return Icons.circle;
      case ContentStatus.exclusive:
        return Icons.star;
      default:
        return null;
    }
  }
}

enum BadgeVariant {
  primary,
  secondary,
  success,
  error,
  warning,
  info,
  premium,
  outline,
}

enum BadgeSize {
  small,
  medium,
  large,
}

enum QualityType {
  video,
  audio,
}

enum ContentStatus {
  new_,
  trending,
  popular,
  featured,
  exclusive,
  comingSoon,
  live,
}

class _BadgeColors {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _BadgeColors({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });
}

class _BadgeDimensions {
  final EdgeInsets padding;
  final TextStyle textStyle;
  final double iconSize;
  final double radius;
  final double spacing;

  const _BadgeDimensions({
    required this.padding,
    required this.textStyle,
    required this.iconSize,
    required this.radius,
    required this.spacing,
  });
}
