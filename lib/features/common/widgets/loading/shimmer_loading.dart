import 'package:flutter/material.dart';
import 'package:onflix/core/constants/app_constants.dart';
import 'package:onflix/core/extensions/context_extension.dart';
import 'package:onflix/core/utils/responsive_helper.dart';

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;
  final ShimmerDirection direction;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
    this.direction = ShimmerDirection.ltr,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: widget.period);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return _createShimmerGradient(context, bounds);
          },
          child: widget.child,
        );
      },
    );
  }

  Shader _createShimmerGradient(BuildContext context, Rect bounds) {
    final baseColor =
        widget.baseColor ?? context.colorScheme.surfaceVariant.withOpacity(0.3);
    final highlightColor =
        widget.highlightColor ?? context.colorScheme.surface.withOpacity(0.8);

    return LinearGradient(
      colors: [baseColor, highlightColor, baseColor],
      stops: const [0.1, 0.3, 0.4],
      begin: _getGradientBegin(),
      end: _getGradientEnd(),
      transform:
          _SlidingGradientTransform(slidePercent: _shimmerController.value),
    ).createShader(bounds);
  }

  AlignmentGeometry _getGradientBegin() {
    switch (widget.direction) {
      case ShimmerDirection.ltr:
        return Alignment.centerLeft;
      case ShimmerDirection.rtl:
        return Alignment.centerRight;
      case ShimmerDirection.ttb:
        return Alignment.topCenter;
      case ShimmerDirection.btt:
        return Alignment.bottomCenter;
    }
  }

  AlignmentGeometry _getGradientEnd() {
    switch (widget.direction) {
      case ShimmerDirection.ltr:
        return Alignment.centerRight;
      case ShimmerDirection.rtl:
        return Alignment.centerLeft;
      case ShimmerDirection.ttb:
        return Alignment.bottomCenter;
      case ShimmerDirection.btt:
        return Alignment.topCenter;
    }
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

enum ShimmerDirection { ltr, rtl, ttb, btt }

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final boxWidth = width ?? double.infinity;
    final boxHeight = height ?? ResponsiveHelper.getScaledPadding(context, 20);
    final radius =
        borderRadius ?? BorderRadius.circular(AppConstants.defaultRadius);
    final shimmerBaseColor = baseColor ?? context.colorScheme.surfaceVariant;

    return ShimmerLoading(
      isLoading: isLoading,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: boxWidth,
        height: boxHeight,
        decoration: BoxDecoration(
          color: shimmerBaseColor,
          borderRadius: radius,
        ),
      ),
    );
  }
}

class ShimmerText extends StatelessWidget {
  final double? width;
  final double? height;
  final int lines;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerText({
    super.key,
    this.width,
    this.height,
    this.lines = 1,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final lineHeight =
        height ?? ResponsiveHelper.getScaledFontSize(context, 16);
    final spacing = ResponsiveHelper.getScaledPadding(context, 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLastLine = index == lines - 1;
        final lineWidth = width ?? (isLastLine ? 100.0 : double.infinity);

        return Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? spacing : 0),
          child: ShimmerBox(
            width: lineWidth,
            height: lineHeight,
            borderRadius: BorderRadius.circular(lineHeight / 2),
            isLoading: isLoading,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
        );
      }),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;
  final bool showImage;
  final bool showTitle;
  final bool showSubtitle;
  final bool showActions;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final EdgeInsets? padding;

  const ShimmerCard({
    super.key,
    this.width,
    this.height,
    this.showImage = true,
    this.showTitle = true,
    this.showSubtitle = true,
    this.showActions = false,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final cardPadding = padding ??
        EdgeInsets.all(ResponsiveHelper.getScaledPadding(context, 16));
    final spacing = ResponsiveHelper.getScaledPadding(context, 12);

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        width: width,
        height: height,
        padding: cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            if (showImage)
              ShimmerBox(
                width: double.infinity,
                height: ResponsiveHelper.getScaledIconSize(context, 120),
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                isLoading: isLoading,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),

            if (showImage) SizedBox(height: spacing),

            // Title placeholder
            if (showTitle)
              ShimmerText(
                width: double.infinity,
                height: ResponsiveHelper.getScaledFontSize(context, 18),
                isLoading: isLoading,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),

            if (showTitle) SizedBox(height: spacing * 0.5),

            // Subtitle placeholder
            if (showSubtitle)
              ShimmerText(
                width: ResponsiveHelper.responsive(
                  context,
                  mobile: 200.0,
                  tablet: 250.0,
                  desktop: 300.0,
                ),
                height: ResponsiveHelper.getScaledFontSize(context, 14),
                lines: 2,
                isLoading: isLoading,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),

            if (showSubtitle) SizedBox(height: spacing),

            // Actions placeholder
            if (showActions)
              Row(
                children: [
                  ShimmerBox(
                    width: ResponsiveHelper.getScaledIconSize(context, 80),
                    height: ResponsiveHelper.getScaledIconSize(context, 32),
                    borderRadius:
                        BorderRadius.circular(AppConstants.smallRadius),
                    isLoading: isLoading,
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                  ),
                  SizedBox(width: spacing),
                  ShimmerBox(
                    width: ResponsiveHelper.getScaledIconSize(context, 60),
                    height: ResponsiveHelper.getScaledIconSize(context, 32),
                    borderRadius:
                        BorderRadius.circular(AppConstants.smallRadius),
                    isLoading: isLoading,
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double? itemHeight;
  final EdgeInsets? itemPadding;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerList({
    super.key,
    required this.itemCount,
    this.itemHeight,
    this.itemPadding,
    this.separatorBuilder,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final height =
        itemHeight ?? ResponsiveHelper.getScaledIconSize(context, 80);
    final padding = itemPadding ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getScaledPadding(context, 16),
          vertical: ResponsiveHelper.getScaledPadding(context, 8),
        );

    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: separatorBuilder ??
          (context, index) => SizedBox(
                height: ResponsiveHelper.getScaledPadding(context, 8),
              ),
      itemBuilder: (context, index) {
        return Padding(
          padding: padding,
          child: ShimmerBox(
            width: double.infinity,
            height: height,
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            isLoading: isLoading,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
        );
      },
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final EdgeInsets? padding;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerGrid({
    super.key,
    required this.itemCount,
    this.crossAxisCount = 2,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.padding,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final gridPadding = padding ??
        EdgeInsets.all(ResponsiveHelper.getScaledPadding(context, 16));
    final crossSpacing =
        crossAxisSpacing ?? ResponsiveHelper.getGridSpacing(context);
    final mainSpacing =
        mainAxisSpacing ?? ResponsiveHelper.getGridSpacing(context);
    final aspectRatio = childAspectRatio ?? AppConstants.cardAspectRatio;

    return GridView.builder(
      padding: gridPadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.responsive(
          context,
          mobile: 2,
          tablet: 3,
          desktop: crossAxisCount,
        ),
        crossAxisSpacing: crossSpacing,
        mainAxisSpacing: mainSpacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerCard(
          isLoading: isLoading,
          baseColor: baseColor,
          highlightColor: highlightColor,
        );
      },
    );
  }
}

class ShimmerProfile extends StatelessWidget {
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerProfile({
    super.key,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.getScaledPadding(context, 16);
    final avatarSize = ResponsiveHelper.getScaledIconSize(context, 60);

    return Padding(
      padding: EdgeInsets.all(spacing),
      child: Row(
        children: [
          // Avatar
          ShimmerBox(
            width: avatarSize,
            height: avatarSize,
            borderRadius: BorderRadius.circular(avatarSize / 2),
            isLoading: isLoading,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),

          SizedBox(width: spacing),

          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                ShimmerText(
                  width: ResponsiveHelper.responsive(
                    context,
                    mobile: 120.0,
                    tablet: 150.0,
                    desktop: 180.0,
                  ),
                  height: ResponsiveHelper.getScaledFontSize(context, 18),
                  isLoading: isLoading,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),

                SizedBox(height: spacing * 0.5),

                // Email/Status
                ShimmerText(
                  width: ResponsiveHelper.responsive(
                    context,
                    mobile: 100.0,
                    tablet: 130.0,
                    desktop: 160.0,
                  ),
                  height: ResponsiveHelper.getScaledFontSize(context, 14),
                  isLoading: isLoading,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerCarousel extends StatelessWidget {
  final bool isLoading;
  final int itemCount;
  final double? itemWidth;
  final double? itemHeight;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerCarousel({
    super.key,
    this.isLoading = true,
    this.itemCount = 5,
    this.itemWidth,
    this.itemHeight,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = itemWidth ?? ResponsiveHelper.getCardWidth(context);
    final cardHeight = itemHeight ?? ResponsiveHelper.getCardHeight(context);
    final spacing = ResponsiveHelper.getGridSpacing(context);

    return SizedBox(
      height: cardHeight + ResponsiveHelper.getScaledPadding(context, 40),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: spacing),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                EdgeInsets.only(right: index < itemCount - 1 ? spacing : 0),
            child: ShimmerCard(
              width: cardWidth,
              height: cardHeight,
              isLoading: isLoading,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
          );
        },
      ),
    );
  }
}

class ShimmerSearchResults extends StatelessWidget {
  final bool isLoading;
  final int itemCount;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerSearchResults({
    super.key,
    this.isLoading = true,
    this.itemCount = 8,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.getScaledPadding(context, 12);

    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getScaledPadding(context, 16),
          ),
          child: Row(
            children: [
              // Thumbnail
              ShimmerBox(
                width: ResponsiveHelper.getScaledIconSize(context, 80),
                height: ResponsiveHelper.getScaledIconSize(context, 60),
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                isLoading: isLoading,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),

              SizedBox(width: spacing),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    ShimmerText(
                      width: double.infinity,
                      height: ResponsiveHelper.getScaledFontSize(context, 16),
                      isLoading: isLoading,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                    ),

                    SizedBox(height: spacing * 0.5),

                    // Subtitle
                    ShimmerText(
                      width: ResponsiveHelper.responsive(
                        context,
                        mobile: 150.0,
                        tablet: 200.0,
                        desktop: 250.0,
                      ),
                      height: ResponsiveHelper.getScaledFontSize(context, 14),
                      isLoading: isLoading,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ShimmerVideoPlayer extends StatelessWidget {
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerVideoPlayer({
    super.key,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final aspectRatio = ResponsiveHelper.getPlayerAspectRatio(context);
    final spacing = ResponsiveHelper.getScaledPadding(context, 16);

    return Column(
      children: [
        // Video player area
        AspectRatio(
          aspectRatio: aspectRatio,
          child: ShimmerBox(
            width: double.infinity,
            height: double.infinity,
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            isLoading: isLoading,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
        ),

        SizedBox(height: spacing),

        // Controls area
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: Column(
            children: [
              // Progress bar
              ShimmerBox(
                width: double.infinity,
                height: 4,
                borderRadius: BorderRadius.circular(2),
                isLoading: isLoading,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),

              SizedBox(height: spacing),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final size = index == 2 ? 48.0 : 40.0; // Middle button larger
                  return ShimmerBox(
                    width: size,
                    height: size,
                    borderRadius: BorderRadius.circular(size / 2),
                    isLoading: isLoading,
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ShimmerStats extends StatelessWidget {
  final bool isLoading;
  final int itemCount;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerStats({
    super.key,
    this.isLoading = true,
    this.itemCount = 4,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.getScaledPadding(context, 16);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(itemCount, (index) {
        return Column(
          children: [
            // Number
            ShimmerText(
              width: ResponsiveHelper.getScaledIconSize(context, 60),
              height: ResponsiveHelper.getScaledFontSize(context, 24),
              isLoading: isLoading,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),

            SizedBox(height: spacing * 0.5),

            // Label
            ShimmerText(
              width: ResponsiveHelper.getScaledIconSize(context, 80),
              height: ResponsiveHelper.getScaledFontSize(context, 12),
              isLoading: isLoading,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
          ],
        );
      }),
    );
  }
}

class ShimmerMediaCard extends StatelessWidget {
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final EdgeInsets? padding;

  const ShimmerMediaCard({
    super.key,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final cardPadding = padding ??
        EdgeInsets.all(ResponsiveHelper.getScaledPadding(context, 12));
    final spacing = ResponsiveHelper.getScaledPadding(context, 8);

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        padding: cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster/Thumbnail
            AspectRatio(
              aspectRatio: AppConstants.posterAspectRatio,
              child: ShimmerBox(
                width: double.infinity,
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                isLoading: isLoading,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
            ),

            SizedBox(height: spacing),

            // Title
            ShimmerText(
              width: double.infinity,
              height: ResponsiveHelper.getScaledFontSize(context, 16),
              isLoading: isLoading,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),

            SizedBox(height: spacing * 0.5),

            // Rating and year
            Row(
              children: [
                ShimmerBox(
                  width: 40,
                  height: ResponsiveHelper.getScaledFontSize(context, 12),
                  borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                  isLoading: isLoading,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
                SizedBox(width: spacing),
                ShimmerBox(
                  width: 60,
                  height: ResponsiveHelper.getScaledFontSize(context, 12),
                  borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                  isLoading: isLoading,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerCommentCard extends StatelessWidget {
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerCommentCard({
    super.key,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.getScaledPadding(context, 12);
    final avatarSize = ResponsiveHelper.getScaledIconSize(context, 40);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getScaledPadding(context, 16),
        vertical: spacing,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          ShimmerBox(
            width: avatarSize,
            height: avatarSize,
            borderRadius: BorderRadius.circular(avatarSize / 2),
            isLoading: isLoading,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),

          SizedBox(width: spacing),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and time
                Row(
                  children: [
                    ShimmerText(
                      width: 80,
                      height: ResponsiveHelper.getScaledFontSize(context, 14),
                      isLoading: isLoading,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                    ),
                    SizedBox(width: spacing),
                    ShimmerText(
                      width: 50,
                      height: ResponsiveHelper.getScaledFontSize(context, 12),
                      isLoading: isLoading,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                    ),
                  ],
                ),

                SizedBox(height: spacing * 0.5),

                // Comment text
                ShimmerText(
                  lines: 2,
                  height: ResponsiveHelper.getScaledFontSize(context, 14),
                  isLoading: isLoading,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),

                SizedBox(height: spacing * 0.5),

                // Like/Reply buttons
                Row(
                  children: [
                    ShimmerBox(
                      width: 40,
                      height: ResponsiveHelper.getScaledFontSize(context, 12),
                      borderRadius:
                          BorderRadius.circular(AppConstants.smallRadius),
                      isLoading: isLoading,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                    ),
                    SizedBox(width: spacing),
                    ShimmerBox(
                      width: 50,
                      height: ResponsiveHelper.getScaledFontSize(context, 12),
                      borderRadius:
                          BorderRadius.circular(AppConstants.smallRadius),
                      isLoading: isLoading,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerNotificationCard extends StatelessWidget {
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerNotificationCard({
    super.key,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.getScaledPadding(context, 12);
    final iconSize = ResponsiveHelper.getScaledIconSize(context, 24);

    return Container(
      padding: EdgeInsets.all(spacing),
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getScaledPadding(context, 16),
        vertical: spacing * 0.5,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: context.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Icon
          ShimmerBox(
            width: iconSize,
            height: iconSize,
            borderRadius: BorderRadius.circular(iconSize / 2),
            isLoading: isLoading,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),

          SizedBox(width: spacing),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                ShimmerText(
                  width: double.infinity,
                  height: ResponsiveHelper.getScaledFontSize(context, 16),
                  isLoading: isLoading,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),

                SizedBox(height: spacing * 0.5),

                // Description
                ShimmerText(
                  width: ResponsiveHelper.responsive(
                    context,
                    mobile: 200.0,
                    tablet: 250.0,
                    desktop: 300.0,
                  ),
                  height: ResponsiveHelper.getScaledFontSize(context, 14),
                  isLoading: isLoading,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),

                SizedBox(height: spacing * 0.5),

                // Time
                ShimmerText(
                  width: 80,
                  height: ResponsiveHelper.getScaledFontSize(context, 12),
                  isLoading: isLoading,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
