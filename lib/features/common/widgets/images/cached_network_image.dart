import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart' as cached;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
import 'package:shimmer/shimmer.dart';

import 'image_placeholder.dart';

/// Enhanced cached network image widget with loading states, error handling, and animations
class OnflixCachedNetworkImage extends StatefulWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool useShimmer;
  final bool showErrorIcon;
  final bool enableMemoryCache;
  final bool enableDiskCache;
  final Duration fadeInDuration;
  final Duration placeholderFadeInDuration;
  final String? heroTag;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? errorPlaceholderAsset;
  final Color? placeholderColor;
  final Color? errorColor;
  final ImageType imageType;
  final Map<String, String>? httpHeaders;
  final Duration? cacheValidDuration;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;
  final bool useOldImageOnUrlChange;
  final ImageLoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final bool showProgressIndicator;
  final Color? progressIndicatorColor;

  const OnflixCachedNetworkImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.useShimmer = true,
    this.showErrorIcon = true,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderFadeInDuration = const Duration(milliseconds: 200),
    this.heroTag,
    this.onTap,
    this.onLongPress,
    this.placeholder,
    this.errorWidget,
    this.errorPlaceholderAsset,
    this.placeholderColor,
    this.errorColor,
    this.imageType = ImageType.general,
    this.httpHeaders,
    this.cacheValidDuration,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.useOldImageOnUrlChange = false,
    this.loadingBuilder,
    this.errorBuilder,
    this.showProgressIndicator = false,
    this.progressIndicatorColor,
  });

  // Named constructors for specific image types
  const OnflixCachedNetworkImage.poster({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.heroTag,
    this.onTap,
    this.onLongPress,
    this.useShimmer = true,
    this.showErrorIcon = true,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderFadeInDuration = const Duration(milliseconds: 200),
    this.placeholder,
    this.errorWidget,
    this.errorPlaceholderAsset,
    this.placeholderColor,
    this.errorColor,
    this.httpHeaders,
    this.cacheValidDuration,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.useOldImageOnUrlChange = false,
    this.loadingBuilder,
    this.errorBuilder,
    this.showProgressIndicator = false,
    this.progressIndicatorColor,
  })  : fit = BoxFit.cover,
        imageType = ImageType.poster;

  const OnflixCachedNetworkImage.backdrop({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.heroTag,
    this.onTap,
    this.onLongPress,
    this.useShimmer = true,
    this.showErrorIcon = true,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderFadeInDuration = const Duration(milliseconds: 200),
    this.placeholder,
    this.errorWidget,
    this.errorPlaceholderAsset,
    this.placeholderColor,
    this.errorColor,
    this.httpHeaders,
    this.cacheValidDuration,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.useOldImageOnUrlChange = false,
    this.loadingBuilder,
    this.errorBuilder,
    this.showProgressIndicator = false,
    this.progressIndicatorColor,
  })  : fit = BoxFit.cover,
        imageType = ImageType.backdrop;

  const OnflixCachedNetworkImage.avatar({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.heroTag,
    this.onTap,
    this.onLongPress,
    this.useShimmer = true,
    this.showErrorIcon = true,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderFadeInDuration = const Duration(milliseconds: 200),
    this.placeholder,
    this.errorWidget,
    this.errorPlaceholderAsset,
    this.placeholderColor,
    this.errorColor,
    this.httpHeaders,
    this.cacheValidDuration,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.useOldImageOnUrlChange = false,
    this.loadingBuilder,
    this.errorBuilder,
    this.showProgressIndicator = false,
    this.progressIndicatorColor,
  })  : fit = BoxFit.cover,
        imageType = ImageType.avatar,
        borderRadius = null; // Avatars typically use CircleAvatar

  const OnflixCachedNetworkImage.logo({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.heroTag,
    this.onTap,
    this.onLongPress,
    this.useShimmer = false,
    this.showErrorIcon = true,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderFadeInDuration = const Duration(milliseconds: 200),
    this.placeholder,
    this.errorWidget,
    this.errorPlaceholderAsset,
    this.placeholderColor,
    this.errorColor,
    this.httpHeaders,
    this.cacheValidDuration,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.useOldImageOnUrlChange = false,
    this.loadingBuilder,
    this.errorBuilder,
    this.showProgressIndicator = false,
    this.progressIndicatorColor,
  })  : fit = BoxFit.contain,
        imageType = ImageType.logo;

  @override
  State<OnflixCachedNetworkImage> createState() =>
      _OnflixCachedNetworkImageState();
}

class _OnflixCachedNetworkImageState extends State<OnflixCachedNetworkImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.fadeInDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return _buildPlaceholder(context);
    }

    Widget imageWidget = _buildCachedImage(context);

    // Apply border radius if specified
    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    // Apply avatar styling for avatar type
    if (widget.imageType == ImageType.avatar) {
      imageWidget = CircleAvatar(
        radius: (widget.width ?? widget.height ?? 50) / 2,
        backgroundColor: widget.placeholderColor ?? OnflixColors.mediumGray,
        child: ClipOval(child: imageWidget),
      );
    }

    // Apply hero animation if tag is provided
    if (widget.heroTag != null) {
      imageWidget = Hero(
        tag: widget.heroTag!,
        child: imageWidget,
      );
    }

    // Apply tap gestures if callbacks provided
    if (widget.onTap != null || widget.onLongPress != null) {
      imageWidget = GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: imageWidget,
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: imageWidget,
    );
  }

  Widget _buildCachedImage(BuildContext context) {
    return cached.CachedNetworkImage(
      imageUrl: widget.imageUrl!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      httpHeaders: widget.httpHeaders,
      useOldImageOnUrlChange: widget.useOldImageOnUrlChange,
      fadeInDuration: widget.fadeInDuration,
      placeholderFadeInDuration: widget.placeholderFadeInDuration,
      memCacheWidth: widget.maxWidthDiskCache,
      memCacheHeight: widget.maxHeightDiskCache,
      maxWidthDiskCache: widget.maxWidthDiskCache,
      maxHeightDiskCache: widget.maxHeightDiskCache,
      placeholder: widget.loadingBuilder != null
          ? null
          : (context, url) => _buildLoadingPlaceholder(context),
      errorWidget: widget.errorBuilder != null
          ? null
          : (context, url, error) => _buildErrorPlaceholder(context, error),
      imageBuilder: (context, imageProvider) => _buildImageWithAnimation(
        context,
        imageProvider,
      ),
    );
  }

  Widget _buildImageWithAnimation(
      BuildContext context, ImageProvider imageProvider) {
    _controller.forward();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: widget.fit,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    if (widget.useShimmer) {
      return _buildShimmerPlaceholder(context);
    }

    return ImagePlaceholder(
      width: widget.width,
      height: widget.height,
      showIcon: true,
      icon: _getPlaceholderIcon(),
    );
  }

  Widget _buildShimmerPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark
          ? OnflixColors.mediumGray.withOpacity(0.3)
          : OnflixColors.veryLightGray.withOpacity(0.3),
      highlightColor: isDark
          ? OnflixColors.lightGray.withOpacity(0.1)
          : OnflixColors.white.withOpacity(0.8),
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context, dynamic error) {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return ImagePlaceholder(
      width: widget.width,
      height: widget.height,
      showIcon: widget.showErrorIcon,
      icon: _getErrorIcon(),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return ImagePlaceholder(
      width: widget.width,
      height: widget.height,
      showIcon: true,
      icon: _getPlaceholderIcon(),
    );
  }

  IconData _getPlaceholderIcon() {
    switch (widget.imageType) {
      case ImageType.poster:
      case ImageType.backdrop:
        return LucideIcons.image;
      case ImageType.avatar:
        return LucideIcons.user;
      case ImageType.logo:
        return LucideIcons.zap;
      case ImageType.general:
      default:
        return LucideIcons.image;
    }
  }

  IconData _getErrorIcon() {
    switch (widget.imageType) {
      case ImageType.poster:
      case ImageType.backdrop:
        return LucideIcons.imageOff;
      case ImageType.avatar:
        return LucideIcons.userX;
      case ImageType.logo:
        return LucideIcons.zapOff;
      case ImageType.general:
      default:
        return LucideIcons.imageOff;
    }
  }
}

/// Progress indicator cached network image for showing download/loading progress
class ProgressCachedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? progressColor;
  final Color? backgroundColor;
  final double strokeWidth;

  const ProgressCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.progressColor,
    this.backgroundColor,
    this.strokeWidth = 3.0,
  });

  @override
  State<ProgressCachedNetworkImage> createState() =>
      _ProgressCachedNetworkImageState();
}

class _ProgressCachedNetworkImageState
    extends State<ProgressCachedNetworkImage> {
  @override
  Widget build(BuildContext context) {
    return cached.CachedNetworkImage(
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, url) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? OnflixColors.mediumGray,
          borderRadius: widget.borderRadius,
        ),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: widget.strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.progressColor ?? OnflixColors.primary,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? OnflixColors.mediumGray,
          borderRadius: widget.borderRadius,
        ),
        child: Icon(
          LucideIcons.imageOff,
          size: 32,
          color: OnflixColors.lightGray,
        ),
      ),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          image: DecorationImage(
            image: imageProvider,
            fit: widget.fit,
          ),
        ),
      ),
    );
  }
}

/// Fade in cached network image with custom animation
class FadeInCachedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Duration duration;
  final Curve curve;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const FadeInCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOut,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<FadeInCachedNetworkImage> createState() =>
      _FadeInCachedNetworkImageState();
}

class _FadeInCachedNetworkImageState extends State<FadeInCachedNetworkImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = cached.CachedNetworkImage(
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, url) =>
          widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: OnflixColors.mediumGray,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(OnflixColors.primary),
              ),
            ),
          ),
      errorWidget: (context, url, error) =>
          widget.errorWidget ??
          Container(
            width: widget.width,
            height: widget.height,
            color: OnflixColors.mediumGray,
            child: const Icon(
              LucideIcons.imageOff,
              size: 32,
              color: OnflixColors.lightGray,
            ),
          ),
      imageBuilder: (context, imageProvider) {
        _controller.forward();
        return FadeTransition(
          opacity: _animation,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              image: DecorationImage(
                image: imageProvider,
                fit: widget.fit,
              ),
            ),
          ),
        );
      },
    );

    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

/// Image type enumeration for different image categories
enum ImageType {
  general,
  poster,
  backdrop,
  avatar,
  logo,
}
