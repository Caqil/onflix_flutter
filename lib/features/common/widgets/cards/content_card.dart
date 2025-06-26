import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onflix/core/config/environment.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
import 'package:onflix/features/common/widgets/cards/shimmer_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../buttons/custom_button.dart';
import '../buttons/icon_button_widget.dart';

/// Content card widget for displaying movies, TV shows, and other media content
class ContentCard extends StatefulWidget {
  final String? id;
  final String? title;
  final String? subtitle;
  final String? imageUrl;
  final String? backdropUrl;
  final String? description;
  final double? rating;
  final String? duration;
  final String? year;
  final List<String>? genres;
  final bool isInWatchlist;
  final bool isDownloaded;
  final bool isWatched;
  final double? watchProgress;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onAddToWatchlist;
  final VoidCallback? onRemoveFromWatchlist;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final VoidCallback? onMoreInfo;
  final ContentCardSize size;
  final ContentCardStyle style;
  final bool showOverlay;
  final bool showProgress;
  final bool showActions;
  final bool showRating;
  final bool showGenres;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? aspectRatio;
  final bool isLoading;
  final String? heroTag;

  const ContentCard({
    super.key,
    this.id,
    this.title,
    this.subtitle,
    this.imageUrl,
    this.backdropUrl,
    this.description,
    this.rating,
    this.duration,
    this.year,
    this.genres,
    this.isInWatchlist = false,
    this.isDownloaded = false,
    this.isWatched = false,
    this.watchProgress,
    this.onTap,
    this.onPlay,
    this.onAddToWatchlist,
    this.onRemoveFromWatchlist,
    this.onDownload,
    this.onShare,
    this.onMoreInfo,
    this.size = ContentCardSize.medium,
    this.style = ContentCardStyle.poster,
    this.showOverlay = true,
    this.showProgress = true,
    this.showActions = true,
    this.showRating = true,
    this.showGenres = false,
    this.borderRadius,
    this.margin,
    this.padding,
    this.aspectRatio,
    this.isLoading = false,
    this.heroTag,
  });

  // Named constructors for different content types
  const ContentCard.poster({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
    this.subtitle,
    this.description,
    this.rating,
    this.duration,
    this.year,
    this.genres,
    this.isInWatchlist = false,
    this.isDownloaded = false,
    this.isWatched = false,
    this.watchProgress,
    this.onTap,
    this.onPlay,
    this.onAddToWatchlist,
    this.onRemoveFromWatchlist,
    this.onDownload,
    this.onShare,
    this.onMoreInfo,
    this.size = ContentCardSize.medium,
    this.showOverlay = true,
    this.showProgress = true,
    this.showActions = true,
    this.showRating = true,
    this.showGenres = false,
    this.borderRadius,
    this.margin,
    this.padding,
    this.isLoading = false,
    this.heroTag,
  })  : style = ContentCardStyle.poster,
        backdropUrl = null,
        aspectRatio = AppConfig.posterAspectRatio;

  const ContentCard.landscape({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
    this.subtitle,
    this.description,
    this.rating,
    this.duration,
    this.year,
    this.genres,
    this.isInWatchlist = false,
    this.isDownloaded = false,
    this.isWatched = false,
    this.watchProgress,
    this.onTap,
    this.onPlay,
    this.onAddToWatchlist,
    this.onRemoveFromWatchlist,
    this.onDownload,
    this.onShare,
    this.onMoreInfo,
    this.size = ContentCardSize.medium,
    this.showOverlay = true,
    this.showProgress = true,
    this.showActions = true,
    this.showRating = true,
    this.showGenres = true,
    this.borderRadius,
    this.margin,
    this.padding,
    this.isLoading = false,
    this.heroTag,
  })  : style = ContentCardStyle.landscape,
        backdropUrl = null,
        aspectRatio = AppConfig.cardAspectRatio;

  const ContentCard.compact({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
    this.subtitle,
    this.description,
    this.rating,
    this.duration,
    this.year,
    this.genres,
    this.isInWatchlist = false,
    this.isDownloaded = false,
    this.isWatched = false,
    this.watchProgress,
    this.onTap,
    this.onPlay,
    this.onAddToWatchlist,
    this.onRemoveFromWatchlist,
    this.onDownload,
    this.onShare,
    this.onMoreInfo,
    this.showOverlay = false,
    this.showProgress = true,
    this.showActions = false,
    this.showRating = false,
    this.showGenres = false,
    this.borderRadius,
    this.margin,
    this.padding,
    this.isLoading = false,
    this.heroTag,
  })  : size = ContentCardSize.small,
        style = ContentCardStyle.compact,
        backdropUrl = null,
        aspectRatio = AppConfig.cardAspectRatio;

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _progressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.watchProgress ?? 0.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    if (widget.watchProgress != null && widget.watchProgress! > 0) {
      _progressController.forward();
    }
  }

  @override
  void didUpdateWidget(ContentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.watchProgress != oldWidget.watchProgress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.watchProgress ?? 0.0,
        end: widget.watchProgress ?? 0.0,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOut,
      ));
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return ShimmerCard(
        size: widget.size,
        style: widget.style,
        margin: widget.margin,
      );
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin ?? _getDefaultMargin(),
            child: _buildCard(context),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context) {
    Widget card;

    switch (widget.style) {
      case ContentCardStyle.poster:
        card = _buildPosterCard(context);
        break;
      case ContentCardStyle.landscape:
        card = _buildLandscapeCard(context);
        break;
      case ContentCardStyle.compact:
        card = _buildCompactCard(context);
        break;
    }

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: card,
      ),
    );
  }

  Widget _buildPosterCard(BuildContext context) {
    return ShadCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageContainer(context),
          if (widget.title != null || widget.subtitle != null)
            _buildCardInfo(context),
        ],
      ),
    );
  }

  Widget _buildLandscapeCard(BuildContext context) {
    return ShadCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageContainer(context),
          _buildCardInfo(context),
        ],
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    return ShadCard(
      child: Row(
        children: [
          _buildImageContainer(context, isCompact: true),
          const SizedBox(width: 12),
          Expanded(child: _buildCardInfo(context, isCompact: true)),
        ],
      ),
    );
  }

  Widget _buildImageContainer(BuildContext context, {bool isCompact = false}) {
    final imageWidget = _buildImage(context);
    final size = _getImageSize(isCompact);

    Widget container = Container(
      width: isCompact ? size.width : null,
      height: isCompact ? size.height : size.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? _getDefaultBorderRadius(),
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? _getDefaultBorderRadius(),
        child: Stack(
          fit: isCompact ? StackFit.loose : StackFit.expand,
          children: [
            imageWidget,
            if (widget.showOverlay) _buildOverlay(context),
            if (widget.showProgress && widget.watchProgress != null)
              _buildProgressIndicator(context),
            if (widget.showActions && _isHovered) _buildActionButtons(context),
            if (widget.isDownloaded) _buildDownloadBadge(context),
            if (widget.isWatched) _buildWatchedBadge(context),
          ],
        ),
      ),
    );

    if (widget.heroTag != null) {
      container = Hero(
        tag: widget.heroTag!,
        child: container,
      );
    }

    return container;
  }

  Widget _buildImage(BuildContext context) {
    final imageUrl = widget.imageUrl ?? widget.backdropUrl;

    if (imageUrl == null) {
      return Container(
        color: OnflixColors.mediumGray,
        child: const Icon(
          LucideIcons.image,
          size: 32,
          color: OnflixColors.lightGray,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: OnflixColors.mediumGray,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(OnflixColors.primary),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: OnflixColors.mediumGray,
        child: const Icon(
          LucideIcons.imageOff,
          size: 32,
          color: OnflixColors.lightGray,
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black54,
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: _progressAnimation.value,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor:
                const AlwaysStoppedAnimation<Color>(OnflixColors.primary),
            minHeight: 3,
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Column(
        children: [
          if (widget.onPlay != null)
            OnflixIconButton.play(
              onPressed: widget.onPlay,
              style: IconButtonStyle.filled,
              backgroundColor: OnflixColors.primary.withOpacity(0.9),
            ),
          const SizedBox(height: 8),
          if (widget.onAddToWatchlist != null ||
              widget.onRemoveFromWatchlist != null)
            OnflixIconButton(
              icon: widget.isInWatchlist ? LucideIcons.check : LucideIcons.plus,
              onPressed: widget.isInWatchlist
                  ? widget.onRemoveFromWatchlist
                  : widget.onAddToWatchlist,
              style: IconButtonStyle.filled,
              backgroundColor: OnflixColors.black.withOpacity(0.7),
              isSelected: widget.isInWatchlist,
            ),
          if (widget.onDownload != null) ...[
            const SizedBox(height: 8),
            OnflixIconButton.download(
              onPressed: widget.onDownload,
              style: IconButtonStyle.filled,
              backgroundColor: OnflixColors.black.withOpacity(0.7),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDownloadBadge(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: OnflixColors.success,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          LucideIcons.download,
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildWatchedBadge(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: OnflixColors.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          LucideIcons.eye,
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCardInfo(BuildContext context, {bool isCompact = false}) {
    return Padding(
      padding: widget.padding ?? _getDefaultPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.title != null)
            Text(
              widget.title!,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: isCompact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: OnflixColors.lightGray,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (widget.showRating && widget.rating != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  LucideIcons.star,
                  size: 12,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.rating!.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: OnflixColors.lightGray,
                      ),
                ),
              ],
            ),
          ],
          if (widget.showGenres &&
              widget.genres != null &&
              widget.genres!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.genres!.take(2).join(', '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: OnflixColors.lightGray,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (widget.duration != null || widget.year != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (widget.year != null)
                  Text(
                    widget.year!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: OnflixColors.lightGray,
                        ),
                  ),
                if (widget.year != null && widget.duration != null)
                  const Text(' • '),
                if (widget.duration != null)
                  Text(
                    widget.duration!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: OnflixColors.lightGray,
                        ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Size _getImageSize(bool isCompact) {
    double width, height;

    if (isCompact) {
      return const Size(80, 60);
    }

    switch (widget.size) {
      case ContentCardSize.small:
        width = 120;
        break;
      case ContentCardSize.medium:
        width = 160;
        break;
      case ContentCardSize.large:
        width = 200;
        break;
    }

    height = width / (widget.aspectRatio ?? _getDefaultAspectRatio());
    return Size(width, height);
  }

  double _getDefaultAspectRatio() {
    switch (widget.style) {
      case ContentCardStyle.poster:
        return AppConfig.posterAspectRatio;
      case ContentCardStyle.landscape:
      case ContentCardStyle.compact:
        return AppConfig.cardAspectRatio;
    }
  }

  BorderRadius _getDefaultBorderRadius() {
    return BorderRadius.circular(8);
  }

  EdgeInsetsGeometry _getDefaultMargin() {
    return const EdgeInsets.all(8);
  }

  EdgeInsetsGeometry _getDefaultPadding() {
    return const EdgeInsets.all(12);
  }
}

/// Content card size enumeration
enum ContentCardSize {
  small,
  medium,
  large,
}

/// Content card style enumeration
enum ContentCardStyle {
  poster,
  landscape,
  compact,
}
