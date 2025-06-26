import 'package:flutter/material.dart';
import 'package:onflix/core/config/environment.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'content_card.dart';
import 'hero_card.dart';
import 'info_card.dart';

/// Shimmer card widget for displaying loading states with animated shimmer effects
class ShimmerCard extends StatelessWidget {
  final ContentCardSize? size;
  final ContentCardStyle? style;
  final HeroCardSize? heroSize;
  final InfoCardSize? infoSize;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final ShimmerVariant variant;
  final bool showText;
  final bool showSubtext;
  final bool showActions;
  final int textLines;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;

  const ShimmerCard({
    super.key,
    this.size,
    this.style,
    this.heroSize,
    this.infoSize,
    this.width,
    this.height,
    this.aspectRatio,
    this.margin,
    this.padding,
    this.borderRadius,
    this.variant = ShimmerVariant.content,
    this.showText = true,
    this.showSubtext = true,
    this.showActions = false,
    this.textLines = 2,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  });

  // Named constructors for different shimmer types
  const ShimmerCard.content({
    super.key,
    this.size = ContentCardSize.medium,
    this.style = ContentCardStyle.poster,
    this.width,
    this.height,
    this.aspectRatio,
    this.margin,
    this.padding,
    this.borderRadius,
    this.showText = true,
    this.showSubtext = true,
    this.showActions = false,
    this.textLines = 2,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  }) : variant = ShimmerVariant.content,
       heroSize = null,
       infoSize = null;

  const ShimmerCard.hero({
    super.key,
    this.heroSize = HeroCardSize.large,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius,
    this.showText = true,
    this.showSubtext = true,
    this.showActions = true,
    this.textLines = 3,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  }) : variant = ShimmerVariant.hero,
       size = null,
       style = null,
       infoSize = null,
       aspectRatio = null;

  const ShimmerCard.info({
    super.key,
    this.infoSize = InfoCardSize.medium,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius,
    this.showText = true,
    this.showSubtext = true,
    this.showActions = false,
    this.textLines = 1,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  }) : variant = ShimmerVariant.info,
       size = null,
       style = null,
       heroSize = null,
       aspectRatio = null;

  const ShimmerCard.list({
    super.key,
    this.width,
    this.height = 80,
    this.margin,
    this.padding,
    this.borderRadius,
    this.showText = true,
    this.showSubtext = true,
    this.showActions = false,
    this.textLines = 1,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  }) : variant = ShimmerVariant.list,
       size = null,
       style = null,
       heroSize = null,
       infoSize = null,
       aspectRatio = null;

  const ShimmerCard.grid({
    super.key,
    this.size = ContentCardSize.medium,
    this.width,
    this.height,
    this.aspectRatio = 1.0,
    this.margin,
    this.padding,
    this.borderRadius,
    this.showText = false,
    this.showSubtext = false,
    this.showActions = false,
    this.textLines = 0,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  }) : variant = ShimmerVariant.grid,
       style = null,
       heroSize = null,
       infoSize = null;

  const ShimmerCard.custom({
    super.key,
    required this.width,
    required this.height,
    this.margin,
    this.padding,
    this.borderRadius,
    this.showText = false,
    this.showSubtext = false,
    this.showActions = false,
    this.textLines = 0,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  }) : variant = ShimmerVariant.custom,
       size = null,
       style = null,
       heroSize = null,
       infoSize = null,
       aspectRatio = null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: margin ?? _getDefaultMargin(),
      child: Shimmer.fromColors(
        baseColor: baseColor ?? _getBaseColor(isDark),
        highlightColor: highlightColor ?? _getHighlightColor(isDark),
        period: period,
        child: _buildShimmerContent(context),
      ),
    );
  }

  Widget _buildShimmerContent(BuildContext context) {
    switch (variant) {
      case ShimmerVariant.content:
        return _buildContentShimmer(context);
      case ShimmerVariant.hero:
        return _buildHeroShimmer(context);
      case ShimmerVariant.info:
        return _buildInfoShimmer(context);
      case ShimmerVariant.list:
        return _buildListShimmer(context);
      case ShimmerVariant.grid:
        return _buildGridShimmer(context);
      case ShimmerVariant.custom:
        return _buildCustomShimmer(context);
    }
  }

  Widget _buildContentShimmer(BuildContext context) {
    final cardSize = _getContentCardSize();
    final isCompact = style == ContentCardStyle.compact;

    if (isCompact) {
      return ShadCard(
        padding: (padding ?? const EdgeInsets.all(12)) as EdgeInsets?,
        child: Row(
          children: [
            _buildShimmerBox(
              width: 80,
              height: 60,
              borderRadius: borderRadius,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showText)
                    _buildShimmerBox(
                      width: double.infinity,
                      height: 16,
                    ),
                  if (showSubtext) ...[
                    const SizedBox(height: 8),
                    _buildShimmerBox(
                      width: 120,
                      height: 12,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ShadCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBox(
            width: cardSize.width,
            height: cardSize.height,
            borderRadius: borderRadius,
          ),
          if (showText || showSubtext)
            Padding(
              padding: padding ?? const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showText)
                    _buildShimmerBox(
                      width: double.infinity,
                      height: 16,
                    ),
                  if (showSubtext) ...[
                    const SizedBox(height: 8),
                    _buildShimmerBox(
                      width: cardSize.width * 0.7,
                      height: 12,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroShimmer(BuildContext context) {
    final heroHeight = height ?? _getHeroCardHeight();

    return ShadCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: SizedBox(
          height: heroHeight,
          child: Stack(
            children: [
              _buildShimmerBox(
                width: double.infinity,
                height: heroHeight,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: padding ?? const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showText)
                        _buildShimmerBox(
                          width: 250,
                          height: 24,
                        ),
                      if (showSubtext) ...[
                        const SizedBox(height: 8),
                        _buildShimmerBox(
                          width: 180,
                          height: 16,
                        ),
                      ],
                      for (int i = 0; i < textLines; i++) ...[
                        const SizedBox(height: 8),
                        _buildShimmerBox(
                          width: (i == textLines - 1) ? 200 : double.infinity,
                          height: 14,
                        ),
                      ],
                      if (showActions) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildShimmerBox(
                              width: 120,
                              height: 40,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            const SizedBox(width: 12),
                            _buildShimmerBox(
                              width: 100,
                              height: 40,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoShimmer(BuildContext context) {
    return ShadCard(
      padding: (padding ?? _getInfoCardPadding()) as EdgeInsets?,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBox(
            width: _getInfoIconSize(),
            height: _getInfoIconSize(),
            borderRadius: BorderRadius.circular(_getInfoIconSize() / 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showText)
                  _buildShimmerBox(
                    width: double.infinity,
                    height: 18,
                  ),
                if (showSubtext) ...[
                  const SizedBox(height: 8),
                  _buildShimmerBox(
                    width: 150,
                    height: 14,
                  ),
                ],
                for (int i = 0; i < textLines; i++) ...[
                  const SizedBox(height: 6),
                  _buildShimmerBox(
                    width: (i == textLines - 1) ? 180 : double.infinity,
                    height: 12,
                  ),
                ],
                if (showActions) ...[
                  const SizedBox(height: 12),
                  _buildShimmerBox(
                    width: 80,
                    height: 32,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListShimmer(BuildContext context) {
    return ShadCard(
      padding: (padding ?? const EdgeInsets.all(16)) as EdgeInsets?,
      child: Row(
        children: [
          _buildShimmerBox(
            width: 60,
            height: 60,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showText)
                  _buildShimmerBox(
                    width: double.infinity,
                    height: 16,
                  ),
                if (showSubtext) ...[
                  const SizedBox(height: 8),
                  _buildShimmerBox(
                    width: 120,
                    height: 12,
                  ),
                ],
              ],
            ),
          ),
          if (showActions)
            _buildShimmerBox(
              width: 24,
              height: 24,
              borderRadius: BorderRadius.circular(12),
            ),
        ],
      ),
    );
  }

  Widget _buildGridShimmer(BuildContext context) {
    final gridSize = _getGridSize();
    
    return _buildShimmerBox(
      width: gridSize.width,
      height: gridSize.height,
      borderRadius: borderRadius,
    );
  }

  Widget _buildCustomShimmer(BuildContext context) {
    return _buildShimmerBox(
      width: width!,
      height: height!,
      borderRadius: borderRadius,
    );
  }

  Widget _buildShimmerBox({
    required double? width,
    required double? height,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }

  Size _getContentCardSize() {
    double cardWidth, cardHeight;
    
    switch (size ?? ContentCardSize.medium) {
      case ContentCardSize.small:
        cardWidth = 120;
        break;
      case ContentCardSize.medium:
        cardWidth = 160;
        break;
      case ContentCardSize.large:
        cardWidth = 200;
        break;
    }

    final effectiveAspectRatio = aspectRatio ?? _getContentAspectRatio();
    cardHeight = cardWidth / effectiveAspectRatio;
    
    return Size(cardWidth, cardHeight);
  }

  double _getContentAspectRatio() {
    switch (style ?? ContentCardStyle.poster) {
      case ContentCardStyle.poster:
        return AppConfig.posterAspectRatio;
      case ContentCardStyle.landscape:
      case ContentCardStyle.compact:
        return AppConfig.cardAspectRatio;
    }
  }

  double _getHeroCardHeight() {
    switch (heroSize ?? HeroCardSize.large) {
      case HeroCardSize.small:
        return 200;
      case HeroCardSize.medium:
        return 300;
      case HeroCardSize.large:
        return 400;
    }
  }

  double _getInfoIconSize() {
    switch (infoSize ?? InfoCardSize.medium) {
      case InfoCardSize.small:
        return 20;
      case InfoCardSize.medium:
        return 24;
      case InfoCardSize.large:
        return 32;
    }
  }

  EdgeInsetsGeometry _getInfoCardPadding() {
    switch (infoSize ?? InfoCardSize.medium) {
      case InfoCardSize.small:
        return const EdgeInsets.all(12);
      case InfoCardSize.medium:
        return const EdgeInsets.all(16);
      case InfoCardSize.large:
        return const EdgeInsets.all(20);
    }
  }

  Size _getGridSize() {
    double gridWidth, gridHeight;
    
    switch (size ?? ContentCardSize.medium) {
      case ContentCardSize.small:
        gridWidth = 100;
        break;
      case ContentCardSize.medium:
        gridWidth = 140;
        break;
      case ContentCardSize.large:
        gridWidth = 180;
        break;
    }

    gridHeight = gridWidth / (aspectRatio ?? 1.0);
    return Size(gridWidth, gridHeight);
  }

  EdgeInsetsGeometry _getDefaultMargin() {
    return const EdgeInsets.all(4);
  }

  Color _getBaseColor(bool isDark) {
    return isDark 
        ? OnflixColors.mediumGray.withOpacity(0.3)
        : OnflixColors.veryLightGray.withOpacity(0.3);
  }

  Color _getHighlightColor(bool isDark) {
    return isDark 
        ? OnflixColors.lightGray.withOpacity(0.1)
        : OnflixColors.white.withOpacity(0.8);
  }
}

/// Shimmer loading list widget for displaying multiple shimmer cards
class ShimmerCardList extends StatelessWidget {
  final int itemCount;
  final ShimmerVariant variant;
  final ContentCardSize? size;
  final ContentCardStyle? style;
  final HeroCardSize? heroSize;
  final InfoCardSize? infoSize;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final double? spacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ShimmerCardList({
    super.key,
    this.itemCount = 10,
    this.variant = ShimmerVariant.content,
    this.size,
    this.style,
    this.heroSize,
    this.infoSize,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.spacing,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: scrollDirection,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(
        width: scrollDirection == Axis.horizontal ? spacing ?? 8 : 0,
        height: scrollDirection == Axis.vertical ? spacing ?? 8 : 0,
      ),
      itemBuilder: (context, index) {
        switch (variant) {
          case ShimmerVariant.content:
            return ShimmerCard.content(
              size: size,
              style: style,
            );
          case ShimmerVariant.hero:
            return ShimmerCard.hero(
              heroSize: heroSize,
            );
          case ShimmerVariant.info:
            return ShimmerCard.info(
              infoSize: infoSize,
            );
          case ShimmerVariant.list:
            return const ShimmerCard.list();
          case ShimmerVariant.grid:
            return ShimmerCard.grid(
              size: size,
            );
          case ShimmerVariant.custom:
            return const ShimmerCard.custom(
              width: 200,
              height: 100,
            );
        }
      },
    );
  }
}

/// Shimmer grid widget for displaying shimmer cards in a grid layout
class ShimmerCardGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final ContentCardSize size;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ShimmerCardGrid({
    super.key,
    this.itemCount = 12,
    this.crossAxisCount = 3,
    this.childAspectRatio,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    this.padding,
    this.size = ContentCardSize.medium,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio ?? AppConfig.posterAspectRatio,
        crossAxisSpacing: crossAxisSpacing ?? 8,
        mainAxisSpacing: mainAxisSpacing ?? 8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerCard.grid(
          size: size,
        );
      },
    );
  }
}

/// Shimmer variant enumeration
enum ShimmerVariant {
  content,
  hero,
  info,
  list,
  grid,
  custom,
}