class AssetPaths {
  // Base paths
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _fonts = 'assets/fonts';
  static const String _videos = 'assets/videos';
  static const String _animations = 'assets/animations';
  static const String _audio = 'assets/audio';

  // Logo assets
  static const String _logos = '$_images/logos';
  static const String appLogo = '$_logos/app_logo.png';
  static const String appLogoDark = '$_logos/app_logo_dark.png';
  static const String appLogoWhite = '$_logos/app_logo_white.png';
  static const String splashLogo = '$_logos/splash_logo.png';
  static const String logoIcon = '$_logos/logo_icon.png';
  static const String logoText = '$_logos/logo_text.png';

  // Background images
  static const String _backgrounds = '$_images/backgrounds';
  static const String loginBackground = '$_backgrounds/login_bg.jpg';
  static const String splashBackground = '$_backgrounds/splash_bg.png';
  static const String defaultBackground = '$_backgrounds/default_bg.jpg';
  static const String gradientOverlay = '$_backgrounds/gradient_overlay.png';
  static const String noiseTexture = '$_backgrounds/noise_texture.png';

  // Placeholder images
  static const String _placeholders = '$_images/placeholders';
  static const String contentPlaceholder =
      '$_placeholders/content_placeholder.png';
  static const String avatarPlaceholder =
      '$_placeholders/avatar_placeholder.png';
  static const String posterPlaceholder =
      '$_placeholders/poster_placeholder.png';
  static const String backdropPlaceholder =
      '$_placeholders/backdrop_placeholder.png';
  static const String loadingPlaceholder =
      '$_placeholders/loading_placeholder.gif';
  static const String errorPlaceholder = '$_placeholders/error_placeholder.png';
  static const String noImagePlaceholder = '$_placeholders/no_image.png';

  // Profile icons
  static const String _profileIcons = '$_images/profile_icons';
  static const String profileIcon1 = '$_profileIcons/profile_1.png';
  static const String profileIcon2 = '$_profileIcons/profile_2.png';
  static const String profileIcon3 = '$_profileIcons/profile_3.png';
  static const String profileIcon4 = '$_profileIcons/profile_4.png';
  static const String profileIcon5 = '$_profileIcons/profile_5.png';
  static const String kidsProfile = '$_profileIcons/kids_profile.png';

  // UI Icons (SVG)
  static const String playIcon = '$_icons/play_icon.svg';
  static const String pauseIcon = '$_icons/pause_icon.svg';
  static const String stopIcon = '$_icons/stop_icon.svg';
  static const String downloadIcon = '$_icons/download_icon.svg';
  static const String addIcon = '$_icons/add_icon.svg';
  static const String shareIcon = '$_icons/share_icon.svg';
  static const String likeIcon = '$_icons/like_icon.svg';
  static const String dislikeIcon = '$_icons/dislike_icon.svg';
  static const String watchlistIcon = '$_icons/watchlist_icon.svg';
  static const String settingsIcon = '$_icons/settings_icon.svg';
  static const String menuIcon = '$_icons/menu_icon.svg';
  static const String closeIcon = '$_icons/close_icon.svg';
  static const String backIcon = '$_icons/back_icon.svg';
  static const String forwardIcon = '$_icons/forward_icon.svg';
  static const String volumeIcon = '$_icons/volume_icon.svg';
  static const String volumeMuteIcon = '$_icons/volume_mute_icon.svg';
  static const String fullscreenIcon = '$_icons/fullscreen_icon.svg';
  static const String exitFullscreenIcon = '$_icons/exit_fullscreen_icon.svg';
  static const String subtitlesIcon = '$_icons/subtitles_icon.svg';
  static const String qualityIcon = '$_icons/quality_icon.svg';
  static const String speedIcon = '$_icons/speed_icon.svg';

  // Category icons
  static const String _categoryIcons = '$_icons/categories';
  static const String actionIcon = '$_categoryIcons/action.svg';
  static const String comedyIcon = '$_categoryIcons/comedy.svg';
  static const String dramaIcon = '$_categoryIcons/drama.svg';
  static const String horrorIcon = '$_categoryIcons/horror.svg';
  static const String romanceIcon = '$_categoryIcons/romance.svg';
  static const String scifiIcon = '$_categoryIcons/scifi.svg';
  static const String thrillerIcon = '$_categoryIcons/thriller.svg';
  static const String documentaryIcon = '$_categoryIcons/documentary.svg';
  static const String animationIcon = '$_categoryIcons/animation.svg';
  static const String familyIcon = '$_categoryIcons/family.svg';
  static const String musicIcon = '$_categoryIcons/music.svg';
  static const String sportsIcon = '$_categoryIcons/sports.svg';

  // Fonts
  static const String netflixSansRegular = '$_fonts/Netflix_Sans_Regular.ttf';
  static const String netflixSansMedium = '$_fonts/Netflix_Sans_Medium.ttf';
  static const String netflixSansBold = '$_fonts/Netflix_Sans_Bold.ttf';
  static const String netflixSansLight = '$_fonts/Netflix_Sans_Light.ttf';

  // Sample videos
  static const String sampleTrailer = '$_videos/sample_trailer.mp4';
  static const String introVideo = '$_videos/intro_video.mp4';
  static const String logoAnimation = '$_videos/logo_animation.mp4';

  // Lottie animations
  static const String loadingAnimation = '$_animations/loading.json';
  static const String successAnimation = '$_animations/success.json';
  static const String errorAnimation = '$_animations/error.json';
  static const String splashAnimation = '$_animations/splash.json';
  static const String emptyStateAnimation = '$_animations/empty_state.json';
  static const String downloadingAnimation = '$_animations/downloading.json';
  static const String heartAnimation = '$_animations/heart.json';
  static const String starAnimation = '$_animations/star.json';
  static const String confettiAnimation = '$_animations/confetti.json';

  // Audio files
  static const String notificationSound = '$_audio/notification.mp3';
  static const String buttonClickSound = '$_audio/button_click.mp3';
  static const String errorSound = '$_audio/error_sound.mp3';
  static const String successSound = '$_audio/success_sound.mp3';

  // Utility methods
  static List<String> get allProfileIcons => [
        profileIcon1,
        profileIcon2,
        profileIcon3,
        profileIcon4,
        profileIcon5,
        kidsProfile,
      ];

  static String getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'action':
        return actionIcon;
      case 'comedy':
        return comedyIcon;
      case 'drama':
        return dramaIcon;
      case 'horror':
        return horrorIcon;
      case 'romance':
        return romanceIcon;
      case 'sci-fi':
      case 'science fiction':
        return scifiIcon;
      case 'thriller':
        return thrillerIcon;
      case 'documentary':
        return documentaryIcon;
      case 'animation':
        return animationIcon;
      case 'family':
        return familyIcon;
      case 'music':
        return musicIcon;
      case 'sports':
        return sportsIcon;
      default:
        return contentPlaceholder;
    }
  }

  static String getProfileIcon(int index) {
    final icons = allProfileIcons;
    return icons[index % icons.length];
  }
}
