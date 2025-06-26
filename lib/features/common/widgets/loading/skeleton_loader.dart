import 'package:flutter/material.dart';
import 'package:onflix/core/constants/app_constants.dart';
import 'package:onflix/core/utils/responsive_helper.dart';

import 'shimmer_loading.dart';

/// A collection of skeleton loading widgets for different UI components
class SkeletonLoader extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final SkeletonType type;
  final int? itemCount;
  final EdgeInsets? padding;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoader({
    super.key,
    required this.isLoading,
    required this.child,
    required this.type,
    this.itemCount,
    this.padding,
    this.baseColor,
    this.highlightColor,
  });

  /// Creates a skeleton loader for content cards
  const SkeletonLoader.contentCard({
    super.key,
    required this.isLoading,
    required this.child,
    this.padding,
    this.baseColor,
    this.highlightColor,
  })  : type = SkeletonType.contentCard,
        itemCount = null;

  /// Creates a skeleton loader for content lists
  const SkeletonLoader.contentList({
    super.key,
    required this.isLoading,
    required this.child,
    this.itemCount = 6,
    this.padding,
    this.baseColor,
    this.highlightColor,
  }) : type = SkeletonType.contentList;

  /// Creates a skeleton loader for content grids
  const SkeletonLoader.contentGrid({
    super.key,
    required this.isLoading,
    required this.child,
    this.itemCount = 12,
    this.padding,
    this.baseColor,
    this.highlightColor,
  }) : type = SkeletonType.contentGrid;

  /// Creates a skeleton loader for user profiles
  const SkeletonLoader.profile({
    super.key,
    required this.isLoading,
    required this.child,
    this.padding,
    this.baseColor,
    this.highlightColor,
  })  : type = SkeletonType.profile,
        itemCount = null;

  /// Creates a skeleton loader for content details
  const SkeletonLoader.contentDetails({
    super.key,
    required this.isLoading,
    required this.child,
    this.padding,
    this.baseColor,
    this.highlightColor,
  })  : type = SkeletonType.contentDetails,
        itemCount = null;

  /// Creates a skeleton loader for player controls
  const SkeletonLoader.playerControls({
    super.key,
    required this.isLoading,
    required this.child,
    this.padding,
    this.baseColor,
    this.highlightColor,
  })  : type = SkeletonType.playerControls,
        itemCount = null;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    switch (type) {
      case SkeletonType.contentCard:
        return _buildContentCardSkeleton(context);
      case SkeletonType.contentList:
        return _buildContentListSkeleton(context);
      case SkeletonType.contentGrid:
        return _buildContentGridSkeleton(context);
      case SkeletonType.profile:
        return _buildProfileSkeleton(context);
      case SkeletonType.contentDetails:
        return _buildContentDetailsSkeleton(context);
      case SkeletonType.playerControls:
        return _buildPlayerControlsSkeleton(context);
    }
  }

  Widget _buildContentCardSkeleton(BuildContext context) {
    return ShimmerCard(
      showImage: true,
      showTitle: true,
      showSubtitle: true,
      showActions: false,
      baseColor: baseColor,
      highlightColor: highlightColor,
      padding: padding,
    );
  }

  Widget _buildContentListSkeleton(BuildContext context) {
    return ShimmerList(
      itemCount: itemCount ?? 6,
      itemPadding: padding,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  Widget _buildContentGridSkeleton(BuildContext context) {
    return ShimmerGrid(
      itemCount: itemCount ?? 12,
      crossAxisCount: ResponsiveHelper.getContentGridColumns(context),
      padding: padding,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  Widget _buildProfileSkeleton(BuildContext context) {
    return ShimmerProfile(
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  Widget _buildContentDetailsSkeleton(BuildContext context) {
    final spacing = ResponsiveHelper.getScaledPadding(context, 16);
    final contentPadding = padding ?? EdgeInsets.all(spacing);

    return Padding(
      padding: contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image
          ShimmerBox(
            width: double.infinity,
            height: ResponsiveHelper.responsive(
              context,
              mobile: 200.0,
              tablet: 300.0,
              desktop: 400.0,
            ),
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),

          SizedBox(height: spacing),

          // Title
          ShimmerText(
            width: double.infinity,
            height: ResponsiveHelper.getScaledFontSize(context, 24),
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),

          SizedBox(height: spacing * 0.5),

          // Metadata row
          Row(
            children: [
              ShimmerBox(
                width: 60,
                height: ResponsiveHelper.getScaledFontSize(context, 14),
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
              SizedBox(width: spacing),
              ShimmerBox(
                width: 80,
                height: ResponsiveHelper.getScaledFontSize(context, 14),
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
              SizedBox(width: spacing),
              ShimmerBox(
                width: 100,
                height: ResponsiveHelper.getScaledFontSize(context, 14),
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
            ],
          ),

          SizedBox(height: spacing),

          // Description
          ShimmerText(
            lines: 3,
            height: ResponsiveHelper.getScaledFontSize(context, 16),
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),

          SizedBox(height: spacing),

          // Action buttons
          Row(
            children: [
              ShimmerBox(
                width: ResponsiveHelper.getScaledIconSize(context, 120),
                height: ResponsiveHelper.getScaledIconSize(context, 40),
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
              SizedBox(width: spacing),
              ShimmerBox(
                width: ResponsiveHelper.getScaledIconSize(context, 100),
                height: ResponsiveHelper.getScaledIconSize(context, 40),
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerControlsSkeleton(BuildContext context) {
    final spacing = ResponsiveHelper.getScaledPadding(context, 12);
    final iconSize = ResponsiveHelper.getScaledIconSize(context, 40);

    return Container(
      padding: EdgeInsets.all(spacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          ShimmerBox(
            width: double.infinity,
            height: 4,
            borderRadius: BorderRadius.circular(2),
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),

          SizedBox(height: spacing),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous
              ShimmerBox(
                width: iconSize * 0.8,
                height: iconSize * 0.8,
                borderRadius: BorderRadius.circular(iconSize * 0.4),
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),

              // Play/Pause
              ShimmerBox(
                width: iconSize,
                height: iconSize,
                borderRadius: BorderRadius.circular(iconSize * 0.5),
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),

              // Next
              ShimmerBox(
                width: iconSize * 0.8,
                height: iconSize * 0.8,
                borderRadius: BorderRadius.circular(iconSize * 0.4),
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
            ],
          ),

          SizedBox(height: spacing),

          // Time labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(
                width: 50,
                height: ResponsiveHelper.getScaledFontSize(context, 12),
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
              ShimmerBox(
                width: 50,
                height: ResponsiveHelper.getScaledFontSize(context, 12),
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum SkeletonType {
  contentCard,
  contentList,
  contentGrid,
  profile,
  contentDetails,
  playerControls,
}

/// Specialized skeleton loaders for specific features
class ContentCardSkeleton extends StatelessWidget {
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final EdgeInsets? padding;

  const ContentCardSkeleton({
    super.key,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader.contentCard(
      isLoading: isLoading,
      baseColor: baseColor,
      highlightColor: highlightColor,
      padding: padding,
      child: const SizedBox.shrink(),
    );
  }
}

class ContentListSkeleton extends StatelessWidget {
  final bool isLoading;
  final int itemCount;
  final Color? baseColor;
  final Color? highlightColor;
  final EdgeInsets? padding;

  const ContentListSkeleton({
    super.key,
    this.isLoading = true,
    this.itemCount = 6,
    this.baseColor,
    this.highlightColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader.contentList(
      isLoading: isLoading,
      itemCount: itemCount,
      baseColor: baseColor,
      highlightColor: highlightColor,
      padding: padding,
      child: const SizedBox.shrink(),
    );
  }
}

class ContentGridSkeleton extends StatelessWidget {
  final bool isLoading;
  final int itemCount;
  final Color? baseColor;
  final Color? highlightColor;
  final EdgeInsets? padding;

  const ContentGridSkeleton({
    super.key,
    this.isLoading = true,
    this.itemCount = 12,
    this.baseColor,
    this.highlightColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader.contentGrid(
      isLoading: isLoading,
      itemCount: itemCount,
      baseColor: baseColor,
      highlightColor: highlightColor,
      padding: padding,
      child: const SizedBox.shrink(),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ProfileSkeleton({
    super.key,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader.profile(
      isLoading: isLoading,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: const SizedBox.shrink(),
    );
  }
}

class ContentDetailsSkeleton extends StatelessWidget {
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final EdgeInsets? padding;

  const ContentDetailsSkeleton({
    super.key,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader.contentDetails(
      isLoading: isLoading,
      baseColor: baseColor,
      highlightColor: highlightColor,
      padding: padding,
      child: const SizedBox.shrink(),
    );
  }
}

class PlayerControlsSkeleton extends StatelessWidget {
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const PlayerControlsSkeleton({
    super.key,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader.playerControls(
      isLoading: isLoading,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: const SizedBox.shrink(),
    );
  }
}

/// A widget that automatically chooses the appropriate skeleton based on context
class AdaptiveSkeleton extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final SkeletonType? forcedType;
  final int? itemCount;
  final Color? baseColor;
  final Color? highlightColor;
  final EdgeInsets? padding;

  const AdaptiveSkeleton({
    super.key,
    required this.isLoading,
    required this.child,
    this.forcedType,
    this.itemCount,
    this.baseColor,
    this.highlightColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    // Auto-detect skeleton type based on context or use forced type
    final skeletonType = forcedType ?? _detectSkeletonType(context);

    return SkeletonLoader(
      isLoading: isLoading,
      type: skeletonType,
      itemCount: itemCount,
      baseColor: baseColor,
      highlightColor: highlightColor,
      padding: padding,
      child: child,
    );
  }

  SkeletonType _detectSkeletonType(BuildContext context) {
    // Simple heuristic based on screen size and content
    if (ResponsiveHelper.isMobile(context)) {
      return SkeletonType.contentList;
    } else if (ResponsiveHelper.isTablet(context)) {
      return SkeletonType.contentGrid;
    } else {
      return SkeletonType.contentGrid;
    }
  }
}
