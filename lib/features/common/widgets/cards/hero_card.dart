import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../buttons/custom_button.dart';
import '../buttons/icon_button_widget.dart';
import '../buttons/play_button.dart';

/// Hero card widget for featuring prominent content with large visuals and detailed information
class HeroCard extends StatefulWidget {
  final String? id;
  final String title;
  final String? subtitle;
  final String? description;
  final String? imageUrl;
  final String? backdropUrl;
  final String? logoUrl;
  final double? rating;
  final String? duration;
  final String? year;
  final String? ageRating;
  final List<String>? genres;
  final List<String>? cast;
  final bool isInWatchlist;
  final bool isDownloaded;
  final bool isWatched;
  final double? watchProgress;
  final VoidCallback? onPlay;
  final VoidCallback? onMoreInfo;
  final VoidCallback? onAddToWatchlist;
  final VoidCallback? onRemoveFromWatchlist;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final VoidCallback? onTap;
  final HeroCardSize size;
  final HeroCardStyle style;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool showGradient;
  final bool showActions;
  final bool showDetails;
  final bool autoPlay;
  final Duration autoPlayDelay;
  final String? heroTag;

  const HeroCard({
    super.key,
    this.id,
    required this.title,
    this.subtitle,
    this.description,
    this.imageUrl,
    this.backdropUrl,
    this.logoUrl,
    this.rating,
    this.duration,
    this.year,
    this.ageRating,
    this.genres,
    this.cast,
    this.isInWatchlist = false,
    this.isDownloaded = false,
    this.isWatched = false,
    this.watchProgress,
    this.onPlay,
    this.onMoreInfo,
    this.onAddToWatchlist,
    this.onRemoveFromWatchlist,
    this.onDownload,
    this.onShare,
    this.onTap,
    this.size = HeroCardSize.large,
    this.style = HeroCardStyle.featured,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius,
    this.showGradient = true,
    this.showActions = true,
    this.showDetails = true,
    this.autoPlay = false,
    this.autoPlayDelay = const Duration(seconds: 3),
    this.heroTag,
  });

  // Named constructors for different hero card types
  const HeroCard.featured({
    super.key,
    required this.title,
    required this.imageUrl,
    this.id,
    this.subtitle,
    this.description,
    this.backdropUrl,
    this.logoUrl,
    this.rating,
    this.duration,
    this.year,
    this.ageRating,
    this.genres,
    this.cast,
    this.isInWatchlist = false,
    this.isDownloaded = false,
    this.isWatched = false,
    this.watchProgress,
    this.onPlay,
    this.onMoreInfo,
    this.onAddToWatchlist,
    this.onRemoveFromWatchlist,
    this.onDownload,
    this.onShare,
    this.onTap,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius,
    this.showGradient = true,
    this.showActions = true,
    this.showDetails = true,
    this.autoPlay = false,
    this.autoPlayDelay = const Duration(seconds: 3),
    this.heroTag,
  })  : size = HeroCardSize.large,
        style = HeroCardStyle.featured;

  const HeroCard.banner({
    super.key,
    required this.title,
    required this.imageUrl,
    this.id,
    this.subtitle,
    this.description,
    this.backdropUrl,
    this.logoUrl,
    this.rating,
    this.duration,
    this.year,
    this.ageRating,
    this.genres,
    this.cast,
    this.isInWatchlist = false,
    this.isDownloaded = false,
    this.isWatched = false,
    this.watchProgress,
    this.onPlay,
    this.onMoreInfo,
    this.onAddToWatchlist,
    this.onRemoveFromWatchlist,
    this.onDownload,
    this.onShare,
    this.onTap,
    this.margin,
    this.padding,
    this.borderRadius,
    this.showGradient = true,
    this.showActions = true,
    this.showDetails = false,
    this.autoPlay = false,
    this.autoPlayDelay = const Duration(seconds: 3),
    this.heroTag,
  })  : size = HeroCardSize.medium,
        style = HeroCardStyle.banner,
        height = 200;

  const HeroCard.compact({
    super.key,
    required this.title,
    required this.imageUrl,
    this.id,
    this.subtitle,
    this.description,
    this.backdropUrl,
    this.logoUrl,
    this.rating,
    this.duration,
    this.year,
    this.ageRating,
    this.genres,
    this.cast,
    this.isInWatchlist = false,
    this.isDownloaded = false,
    this.isWatched = false,
    this.watchProgress,
    this.onPlay,
    this.onMoreInfo,
    this.onAddToWatchlist,
    this.onRemoveFromWatchlist,
    this.onDownload,
    this.onShare,
    this.onTap,
    this.margin,
    this.padding,
    this.borderRadius,
    this.showGradient = true,
    this.showActions = false,
    this.showDetails = false,
    this.autoPlay = false,
    this.autoPlayDelay = const Duration(seconds: 3),
    this.heroTag,
  })  : size = HeroCardSize.small,
        style = HeroCardStyle.compact,
        height = 150;

  @override
  State<HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<HeroCard> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _progressController;
  late AnimationController _autoPlayController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAutoPlay();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _autoPlayController = AnimationController(
      duration: widget.autoPlayDelay,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.watchProgress ?? 0.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    // Start entrance animations
    _fadeController.forward();
    _slideController.forward();

    if (widget.watchProgress != null && widget.watchProgress! > 0) {
      _progressController.forward();
    }
  }

  void _startAutoPlay() {
    if (widget.autoPlay) {
      _autoPlayController.addStatusListener((status) {
        if (status == AnimationStatus.completed && widget.onPlay != null) {
          widget.onPlay!();
        }
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _autoPlayController.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(HeroCard oldWidget) {
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
    _fadeController.dispose();
    _slideController.dispose();
    _progressController.dispose();
    _autoPlayController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (widget.autoPlay) {
      if (isHovered) {
        _autoPlayController.stop();
      } else {
        _autoPlayController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: widget.height ?? _getDefaultHeight(),
          margin: widget.margin,
          child: AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _slideAnimation]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildHeroCard(context),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    Widget card = ShadCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackgroundImage(context),
            if (widget.showGradient) _buildGradientOverlay(context),
            if (widget.watchProgress != null) _buildProgressIndicator(context),
            _buildContent(context),
            if (widget.autoPlay) _buildAutoPlayIndicator(context),
          ],
        ),
      ),
    );

    if (widget.heroTag != null) {
      card = Hero(
        tag: widget.heroTag!,
        child: card,
      );
    }

    return card;
  }

  Widget _buildBackgroundImage(BuildContext context) {
    final imageUrl = widget.backdropUrl ?? widget.imageUrl;

    if (imageUrl == null) {
      return Container(
        color: OnflixColors.darkGray,
        child: const Center(
          child: Icon(
            LucideIcons.image,
            size: 48,
            color: OnflixColors.lightGray,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: OnflixColors.darkGray,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(OnflixColors.primary),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: OnflixColors.darkGray,
        child: const Center(
          child: Icon(
            LucideIcons.imageOff,
            size: 48,
            color: OnflixColors.lightGray,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.0, 0.5, 1.0],
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
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor:
                const AlwaysStoppedAnimation<Color>(OnflixColors.primary),
            minHeight: 4,
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: widget.padding ?? _getDefaultPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            if (widget.showDetails) ...[
              const SizedBox(height: 12),
              _buildDetails(context),
            ],
            if (widget.showActions) ...[
              const SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.logoUrl != null)
          Container(
            height: 60,
            width: 200,
            margin: const EdgeInsets.only(bottom: 8),
            child: CachedNetworkImage(
              imageUrl: widget.logoUrl!,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              errorWidget: (context, url, error) => _buildTitleText(context),
            ),
          )
        else
          _buildTitleText(context),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.subtitle!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: OnflixColors.lightGray,
                  fontWeight: FontWeight.w400,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        _buildMetadata(context),
      ],
    );
  }

  Widget _buildTitleText(BuildContext context) {
    return Text(
      widget.title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: OnflixColors.white,
        fontWeight: FontWeight.bold,
        shadows: [
          const Shadow(
            offset: Offset(0, 2),
            blurRadius: 4,
            color: Colors.black54,
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata(BuildContext context) {
    final metadata = <Widget>[];

    if (widget.rating != null) {
      metadata.addAll([
        const Icon(
          LucideIcons.star,
          size: 14,
          color: Colors.amber,
        ),
        const SizedBox(width: 4),
        Text(
          widget.rating!.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: OnflixColors.white,
                fontWeight: FontWeight.w500,
              ),
        ),
      ]);
    }

    if (widget.year != null) {
      if (metadata.isNotEmpty) metadata.add(const Text(' • '));
      metadata.add(
        Text(
          widget.year!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: OnflixColors.lightGray,
              ),
        ),
      );
    }

    if (widget.duration != null) {
      if (metadata.isNotEmpty) metadata.add(const Text(' • '));
      metadata.add(
        Text(
          widget.duration!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: OnflixColors.lightGray,
              ),
        ),
      );
    }

    if (widget.ageRating != null) {
      if (metadata.isNotEmpty) metadata.add(const SizedBox(width: 8));
      metadata.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: OnflixColors.lightGray),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.ageRating!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: OnflixColors.lightGray,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      );
    }

    if (metadata.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: metadata,
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.description != null) ...[
          Text(
            widget.description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: OnflixColors.white.withOpacity(0.9),
                  height: 1.4,
                ),
            maxLines: widget.style == HeroCardStyle.featured ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
        ],
        if (widget.genres != null && widget.genres!.isNotEmpty) ...[
          Text(
            'Genres: ${widget.genres!.take(3).join(', ')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: OnflixColors.lightGray,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
        ],
        if (widget.cast != null && widget.cast!.isNotEmpty)
          Text(
            'Cast: ${widget.cast!.take(3).join(', ')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: OnflixColors.lightGray,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (widget.onPlay != null)
          PlayButton.large(
            onPressed: widget.onPlay,
            style: PlayButtonStyle.filled,
            backgroundColor: OnflixColors.primary,
          ),
        const SizedBox(width: 12),
        if (widget.onMoreInfo != null)
          CustomButton.secondary(
            text: 'More Info',
            onPressed: widget.onMoreInfo,
            icon: LucideIcons.info,
            size: CustomButtonSize.medium,
          ),
        const Spacer(),
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
            tooltip: widget.isInWatchlist
                ? 'Remove from Watchlist'
                : 'Add to Watchlist',
          ),
        if (widget.onDownload != null) ...[
          const SizedBox(width: 8),
          OnflixIconButton.download(
            onPressed: widget.onDownload,
            style: IconButtonStyle.filled,
            backgroundColor: OnflixColors.black.withOpacity(0.7),
          ),
        ],
        if (widget.onShare != null) ...[
          const SizedBox(width: 8),
          OnflixIconButton(
            icon: LucideIcons.share,
            onPressed: widget.onShare,
            style: IconButtonStyle.filled,
            backgroundColor: OnflixColors.black.withOpacity(0.7),
            tooltip: 'Share',
          ),
        ],
      ],
    );
  }

  Widget _buildAutoPlayIndicator(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _autoPlayController,
        builder: (context, child) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: OnflixColors.black.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: _autoPlayController.value,
                      strokeWidth: 2,
                      backgroundColor: OnflixColors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          OnflixColors.primary),
                    ),
                  ),
                ),
                const Center(
                  child: Icon(
                    LucideIcons.play,
                    size: 12,
                    color: OnflixColors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  double _getDefaultHeight() {
    switch (widget.size) {
      case HeroCardSize.small:
        return 200;
      case HeroCardSize.medium:
        return 300;
      case HeroCardSize.large:
        return 400;
    }
  }

  EdgeInsetsGeometry _getDefaultPadding() {
    switch (widget.size) {
      case HeroCardSize.small:
        return const EdgeInsets.all(16);
      case HeroCardSize.medium:
        return const EdgeInsets.all(20);
      case HeroCardSize.large:
        return const EdgeInsets.all(24);
    }
  }
}

/// Hero card size enumeration
enum HeroCardSize {
  small,
  medium,
  large,
}

/// Hero card style enumeration
enum HeroCardStyle {
  featured,
  banner,
  compact,
}
