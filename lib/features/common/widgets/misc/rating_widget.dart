import 'package:flutter/material.dart';
import 'package:onflix/core/constants/app_constants.dart';
import 'package:onflix/core/extensions/context_extension.dart';
import 'package:onflix/core/utils/responsive_helper.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final double maxRating;
  final int itemCount;
  final double? itemSize;
  final Color? activeColor;
  final Color? inactiveColor;
  final Widget? activeIcon;
  final Widget? inactiveIcon;
  final Function(double)? onRatingChanged;
  final bool allowHalfRating;
  final bool ignoreGestures;
  final MainAxisAlignment alignment;
  final double itemPadding;
  final RatingStyle style;

  const RatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 5.0,
    this.itemCount = 5,
    this.itemSize,
    this.activeColor,
    this.inactiveColor,
    this.activeIcon,
    this.inactiveIcon,
    this.onRatingChanged,
    this.allowHalfRating = true,
    this.ignoreGestures = true,
    this.alignment = MainAxisAlignment.start,
    this.itemPadding = 2.0,
    this.style = RatingStyle.star,
  });

  const RatingWidget.interactive({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.maxRating = 5.0,
    this.itemCount = 5,
    this.itemSize,
    this.activeColor,
    this.inactiveColor,
    this.activeIcon,
    this.inactiveIcon,
    this.allowHalfRating = true,
    this.alignment = MainAxisAlignment.start,
    this.itemPadding = 2.0,
    this.style = RatingStyle.star,
  }) : ignoreGestures = false;

  const RatingWidget.heart({
    super.key,
    required this.rating,
    this.maxRating = 5.0,
    this.itemCount = 5,
    this.itemSize,
    this.activeColor,
    this.inactiveColor,
    this.onRatingChanged,
    this.allowHalfRating = true,
    this.ignoreGestures = true,
    this.alignment = MainAxisAlignment.start,
    this.itemPadding = 2.0,
  })  : style = RatingStyle.heart,
        activeIcon = null,
        inactiveIcon = null;

  const RatingWidget.thumb({
    super.key,
    required this.rating,
    this.maxRating = 5.0,
    this.itemCount = 5,
    this.itemSize,
    this.activeColor,
    this.inactiveColor,
    this.onRatingChanged,
    this.allowHalfRating = false,
    this.ignoreGestures = true,
    this.alignment = MainAxisAlignment.start,
    this.itemPadding = 2.0,
  })  : style = RatingStyle.thumb,
        activeIcon = null,
        inactiveIcon = null;

  @override
  Widget build(BuildContext context) {
    final scaledSize =
        itemSize ?? ResponsiveHelper.getScaledIconSize(context, 20);
    final scaledPadding =
        ResponsiveHelper.getScaledPadding(context, itemPadding);

    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: scaledPadding),
          child: GestureDetector(
            onTap: ignoreGestures ? null : () => _handleTap(index),
            onPanUpdate: ignoreGestures
                ? null
                : (details) => _handlePanUpdate(context, details, index),
            child: _buildRatingItem(context, index, scaledSize),
          ),
        );
      }),
    );
  }

  Widget _buildRatingItem(BuildContext context, int index, double size) {
    final itemRating = _getItemRating(index);

    switch (style) {
      case RatingStyle.star:
        return _buildStarItem(context, itemRating, size);
      case RatingStyle.heart:
        return _buildHeartItem(context, itemRating, size);
      case RatingStyle.thumb:
        return _buildThumbItem(context, itemRating, size);
      case RatingStyle.custom:
        return _buildCustomItem(context, itemRating, size);
    }
  }

  Widget _buildStarItem(BuildContext context, double itemRating, double size) {
    final active = activeColor ?? context.colorScheme.primary;
    final inactive =
        inactiveColor ?? context.colorScheme.outline.withOpacity(0.3);

    if (allowHalfRating && itemRating > 0 && itemRating < 1) {
      return Stack(
        children: [
          Icon(
            Icons.star_outline,
            size: size,
            color: inactive,
          ),
          ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: itemRating,
              child: Icon(
                Icons.star,
                size: size,
                color: active,
              ),
            ),
          ),
        ],
      );
    }

    return Icon(
      itemRating >= 1 ? Icons.star : Icons.star_outline,
      size: size,
      color: itemRating >= 1 ? active : inactive,
    );
  }

  Widget _buildHeartItem(BuildContext context, double itemRating, double size) {
    final active = activeColor ?? Colors.red;
    final inactive =
        inactiveColor ?? context.colorScheme.outline.withOpacity(0.3);

    if (allowHalfRating && itemRating > 0 && itemRating < 1) {
      return Stack(
        children: [
          Icon(
            Icons.favorite_border,
            size: size,
            color: inactive,
          ),
          ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: itemRating,
              child: Icon(
                Icons.favorite,
                size: size,
                color: active,
              ),
            ),
          ),
        ],
      );
    }

    return Icon(
      itemRating >= 1 ? Icons.favorite : Icons.favorite_border,
      size: size,
      color: itemRating >= 1 ? active : inactive,
    );
  }

  Widget _buildThumbItem(BuildContext context, double itemRating, double size) {
    final active = activeColor ?? Colors.green;
    final inactive =
        inactiveColor ?? context.colorScheme.outline.withOpacity(0.3);

    return Icon(
      itemRating >= 1 ? Icons.thumb_up : Icons.thumb_up_outlined,
      size: size,
      color: itemRating >= 1 ? active : inactive,
    );
  }

  Widget _buildCustomItem(
      BuildContext context, double itemRating, double size) {
    final active = activeIcon ?? Icon(Icons.star, size: size);
    final inactive = inactiveIcon ?? Icon(Icons.star_outline, size: size);

    if (allowHalfRating && itemRating > 0 && itemRating < 1) {
      return Stack(
        children: [
          inactive,
          ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: itemRating,
              child: active,
            ),
          ),
        ],
      );
    }

    return itemRating >= 1 ? active : inactive;
  }

  double _getItemRating(int index) {
    final itemValue = rating - index;
    if (itemValue >= 1) return 1;
    if (itemValue <= 0) return 0;
    return allowHalfRating ? itemValue : (itemValue >= 0.5 ? 1 : 0);
  }

  void _handleTap(int index) {
    if (onRatingChanged != null) {
      final newRating = (index + 1).toDouble();
      onRatingChanged!(newRating);
    }
  }

  void _handlePanUpdate(
      BuildContext context, DragUpdateDetails details, int index) {
    if (onRatingChanged != null && allowHalfRating) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final localPosition = box.globalToLocal(details.globalPosition);
      final itemWidth = (box.size.width / itemCount);
      final itemPosition = localPosition.dx - (index * itemWidth);
      final itemRating = (itemPosition / itemWidth).clamp(0.0, 1.0);
      final newRating = index + itemRating;
      onRatingChanged!(newRating.clamp(0.0, maxRating));
    }
  }
}

class RatingDisplay extends StatelessWidget {
  final double rating;
  final double maxRating;
  final int reviewCount;
  final bool showRatingText;
  final bool showReviewCount;
  final RatingDisplayStyle displayStyle;
  final double? starSize;
  final Color? starColor;
  final TextStyle? ratingTextStyle;
  final TextStyle? reviewCountStyle;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.maxRating = 5.0,
    this.reviewCount = 0,
    this.showRatingText = true,
    this.showReviewCount = true,
    this.displayStyle = RatingDisplayStyle.horizontal,
    this.starSize,
    this.starColor,
    this.ratingTextStyle,
    this.reviewCountStyle,
  });

  const RatingDisplay.compact({
    super.key,
    required this.rating,
    this.maxRating = 5.0,
    this.reviewCount = 0,
    this.starSize,
    this.starColor,
    this.ratingTextStyle,
    this.reviewCountStyle,
  })  : showRatingText = true,
        showReviewCount = false,
        displayStyle = RatingDisplayStyle.compact;

  const RatingDisplay.detailed({
    super.key,
    required this.rating,
    this.maxRating = 5.0,
    this.reviewCount = 0,
    this.starSize,
    this.starColor,
    this.ratingTextStyle,
    this.reviewCountStyle,
  })  : showRatingText = true,
        showReviewCount = true,
        displayStyle = RatingDisplayStyle.vertical;

  @override
  Widget build(BuildContext context) {
    switch (displayStyle) {
      case RatingDisplayStyle.horizontal:
        return _buildHorizontalLayout(context);
      case RatingDisplayStyle.vertical:
        return _buildVerticalLayout(context);
      case RatingDisplayStyle.compact:
        return _buildCompactLayout(context);
    }
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingWidget(
          rating: rating,
          maxRating: maxRating,
          itemSize: starSize ?? ResponsiveHelper.getScaledIconSize(context, 16),
          activeColor: starColor ?? context.colorScheme.primary,
        ),
        if (showRatingText) ...[
          SizedBox(width: ResponsiveHelper.getScaledPadding(context, 8)),
          Text(
            '${rating.toStringAsFixed(1)}',
            style: ratingTextStyle ??
                context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveHelper.getScaledFontSize(context, 14),
                ),
          ),
        ],
        if (showReviewCount && reviewCount > 0) ...[
          SizedBox(width: ResponsiveHelper.getScaledPadding(context, 4)),
          Text(
            '(${_formatReviewCount()})',
            style: reviewCountStyle ??
                context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontSize: ResponsiveHelper.getScaledFontSize(context, 12),
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingWidget(
          rating: rating,
          maxRating: maxRating,
          itemSize: starSize ?? ResponsiveHelper.getScaledIconSize(context, 18),
          activeColor: starColor ?? context.colorScheme.primary,
        ),
        if (showRatingText || showReviewCount) ...[
          SizedBox(height: ResponsiveHelper.getScaledPadding(context, 4)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showRatingText)
                Text(
                  '${rating.toStringAsFixed(1)} out of ${maxRating.toInt()}',
                  style: ratingTextStyle ??
                      context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize:
                            ResponsiveHelper.getScaledFontSize(context, 14),
                      ),
                ),
              if (showReviewCount && reviewCount > 0) ...[
                if (showRatingText) const Text(' • '),
                Text(
                  '${_formatReviewCount()} reviews',
                  style: reviewCountStyle ??
                      context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        fontSize:
                            ResponsiveHelper.getScaledFontSize(context, 12),
                      ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getScaledPadding(context, 8),
        vertical: ResponsiveHelper.getScaledPadding(context, 4),
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: starSize ?? ResponsiveHelper.getScaledIconSize(context, 14),
            color: starColor ?? context.colorScheme.primary,
          ),
          SizedBox(width: ResponsiveHelper.getScaledPadding(context, 4)),
          Text(
            rating.toStringAsFixed(1),
            style: ratingTextStyle ??
                context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveHelper.getScaledFontSize(context, 12),
                ),
          ),
        ],
      ),
    );
  }

  String _formatReviewCount() {
    if (reviewCount >= 1000000) {
      return '${(reviewCount / 1000000).toStringAsFixed(1)}M';
    } else if (reviewCount >= 1000) {
      return '${(reviewCount / 1000).toStringAsFixed(1)}K';
    }
    return reviewCount.toString();
  }
}

class RatingBreakdown extends StatelessWidget {
  final Map<int, int> ratingCounts;
  final double maxRating;
  final int totalReviews;

  const RatingBreakdown({
    super.key,
    required this.ratingCounts,
    this.maxRating = 5.0,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(maxRating.toInt(), (index) {
        final stars = maxRating.toInt() - index;
        final count = ratingCounts[stars] ?? 0;
        final percentage = totalReviews > 0 ? (count / totalReviews) : 0.0;

        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.getScaledPadding(context, 2),
          ),
          child: Row(
            children: [
              Text(
                '$stars',
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: ResponsiveHelper.getScaledFontSize(context, 12),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getScaledPadding(context, 4)),
              Icon(
                Icons.star,
                size: ResponsiveHelper.getScaledIconSize(context, 12),
                color: context.colorScheme.primary,
              ),
              SizedBox(width: ResponsiveHelper.getScaledPadding(context, 8)),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: context.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getScaledPadding(context, 8)),
              SizedBox(
                width: 30,
                child: Text(
                  count.toString(),
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: ResponsiveHelper.getScaledFontSize(context, 12),
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class ContentRating extends StatelessWidget {
  final String rating;
  final String? description;
  final ContentRatingSystem system;
  final bool showDescription;

  const ContentRating({
    super.key,
    required this.rating,
    this.description,
    this.system = ContentRatingSystem.mpaa,
    this.showDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getScaledPadding(context, 8),
        vertical: ResponsiveHelper.getScaledPadding(context, 4),
      ),
      decoration: BoxDecoration(
        color: _getRatingColor(context),
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        border: Border.all(
          color: _getRatingBorderColor(context),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rating,
            style: context.textTheme.bodySmall?.copyWith(
              color: _getRatingTextColor(context),
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getScaledFontSize(context, 10),
            ),
          ),
          if (showDescription && description != null) ...[
            SizedBox(width: ResponsiveHelper.getScaledPadding(context, 4)),
            Text(
              description!,
              style: context.textTheme.bodySmall?.copyWith(
                color: _getRatingTextColor(context),
                fontSize: ResponsiveHelper.getScaledFontSize(context, 9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRatingColor(BuildContext context) {
    switch (rating.toUpperCase()) {
      case 'G':
        return Colors.green.withOpacity(0.2);
      case 'PG':
        return Colors.yellow.withOpacity(0.2);
      case 'PG-13':
      case '12A':
      case '12':
        return Colors.orange.withOpacity(0.2);
      case 'R':
      case '15':
        return Colors.red.withOpacity(0.2);
      case 'NC-17':
      case '18':
        return Colors.red.withOpacity(0.3);
      default:
        return context.colorScheme.surfaceVariant;
    }
  }

  Color _getRatingBorderColor(BuildContext context) {
    switch (rating.toUpperCase()) {
      case 'G':
        return Colors.green;
      case 'PG':
        return Colors.yellow.shade700;
      case 'PG-13':
      case '12A':
      case '12':
        return Colors.orange;
      case 'R':
      case '15':
        return Colors.red;
      case 'NC-17':
      case '18':
        return Colors.red.shade700;
      default:
        return context.colorScheme.outline;
    }
  }

  Color _getRatingTextColor(BuildContext context) {
    switch (rating.toUpperCase()) {
      case 'G':
        return Colors.green.shade800;
      case 'PG':
        return Colors.yellow.shade800;
      case 'PG-13':
      case '12A':
      case '12':
        return Colors.orange.shade800;
      case 'R':
      case '15':
        return Colors.red.shade800;
      case 'NC-17':
      case '18':
        return Colors.red.shade900;
      default:
        return context.colorScheme.onSurfaceVariant;
    }
  }
}

enum RatingStyle {
  star,
  heart,
  thumb,
  custom,
}

enum RatingDisplayStyle {
  horizontal,
  vertical,
  compact,
}

enum ContentRatingSystem {
  mpaa, // Motion Picture Association (US)
  bbfc, // British Board of Film Classification (UK)
  cero, // Computer Entertainment Rating Organization (Japan)
  esrb, // Entertainment Software Rating Board (Games)
  pegi, // Pan European Game Information (Europe)
}
