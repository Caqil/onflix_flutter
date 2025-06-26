import os
import uuid

def create_directory(path):
    os.makedirs(path, exist_ok=True)

def create_file(path, content=""):
    with open(path, 'w') as f:
        f.write(content)

def create_project_structure():
    # Root directory
    create_directory('lib')

    # Main files
    main_files = ['lib/main.dart', 'lib/app.dart']
    for file in main_files:
        create_file(file)

    # Core directories
    core_dirs = [
        'lib/core/config/theme', 'lib/core/constants', 'lib/core/extensions',
        'lib/core/utils', 'lib/core/errors', 'lib/core/network'
    ]
    for dir in core_dirs:
        create_directory(dir)

    # Core files
    core_files = [
        'lib/core/config/app_config.dart',
        'lib/core/config/environment.dart',
        'lib/core/config/theme/app_theme.dart',
        'lib/core/config/theme/dark_theme.dart',
        'lib/core/config/theme/light_theme.dart',
        'lib/core/config/theme/responsive_breakpoints.dart',
        'lib/core/constants/app_constants.dart',
        'lib/core/constants/api_endpoints.dart',
        'lib/core/constants/asset_paths.dart',
        'lib/core/constants/storage_keys.dart',
        'lib/core/extensions/context_extension.dart',
        'lib/core/extensions/string_extension.dart',
        'lib/core/extensions/datetime_extension.dart',
        'lib/core/extensions/widget_extension.dart',
        'lib/core/utils/validators.dart',
        'lib/core/utils/formatters.dart',
        'lib/core/utils/helpers.dart',
        'lib/core/utils/responsive_helper.dart',
        'lib/core/errors/exceptions.dart',
        'lib/core/errors/failures.dart',
        'lib/core/errors/error_handler.dart',
        'lib/core/network/pocketbase_client.dart',
        'lib/core/network/api_client.dart',
        'lib/core/network/interceptors.dart',
        'lib/core/network/network_info.dart'
    ]
    for file in core_files:
        create_file(file)

    # Features directories
    feature_dirs = [
        'lib/features/auth/data/models', 'lib/features/auth/data/repositories',
        'lib/features/auth/data/datasources', 'lib/features/auth/domain/entities',
        'lib/features/auth/domain/repositories', 'lib/features/auth/presentation/providers',
        'lib/features/auth/presentation/pages', 'lib/features/auth/presentation/widgets',
        'lib/features/home/data/models', 'lib/features/home/data/repositories',
        'lib/features/home/data/datasources', 'lib/features/home/domain/entities',
        'lib/features/home/domain/repositories', 'lib/features/home/presentation/providers',
        'lib/features/home/presentation/pages', 'lib/features/home/presentation/widgets',
        'lib/features/player/data/models', 'lib/features/player/data/repositories',
        'lib/features/player/data/datasources', 'lib/features/player/domain/entities',
        'lib/features/player/domain/repositories', 'lib/features/player/presentation/providers',
        'lib/features/player/presentation/pages', 'lib/features/player/presentation/widgets',
        'lib/features/watchlist/data/models', 'lib/features/watchlist/data/repositories',
        'lib/features/watchlist/data/datasources', 'lib/features/watchlist/domain/entities',
        'lib/features/watchlist/domain/repositories', 'lib/features/watchlist/presentation/providers',
        'lib/features/watchlist/presentation/pages', 'lib/features/watchlist/presentation/widgets',
        'lib/features/downloads/data/models', 'lib/features/downloads/data/repositories',
        'lib/features/downloads/data/datasources', 'lib/features/downloads/domain/entities',
        'lib/features/downloads/domain/repositories', 'lib/features/downloads/presentation/providers',
        'lib/features/downloads/presentation/pages', 'lib/features/downloads/presentation/widgets',
        'lib/features/profile/data/models', 'lib/features/profile/data/repositories',
        'lib/features/profile/data/datasources', 'lib/features/profile/domain/entities',
        'lib/features/profile/domain/repositories', 'lib/features/profile/presentation/providers',
        'lib/features/profile/presentation/pages', 'lib/features/profile/presentation/widgets',
        'lib/features/admin/data/models', 'lib/features/admin/data/repositories',
        'lib/features/admin/data/datasources', 'lib/features/admin/domain/entities',
        'lib/features/admin/domain/repositories', 'lib/features/admin/presentation/providers',
        'lib/features/admin/presentation/pages', 'lib/features/admin/presentation/widgets',
        'lib/features/common/widgets/layouts', 'lib/features/common/widgets/navigation',
        'lib/features/common/widgets/buttons', 'lib/features/common/widgets/inputs',
        'lib/features/common/widgets/cards', 'lib/features/common/widgets/loading',
        'lib/features/common/widgets/dialogs', 'lib/features/common/widgets/images',
        'lib/features/common/widgets/misc', 'lib/features/common/providers'
    ]
    for dir in feature_dirs:
        create_directory(dir)

    # Features files
    feature_files = [
        'lib/features/auth/data/models/user_model.dart',
        'lib/features/auth/data/models/auth_response_model.dart',
        'lib/features/auth/data/models/subscription_model.dart',
        'lib/features/auth/data/repositories/auth_repository_impl.dart',
        'lib/features/auth/data/datasources/auth_local_datasource.dart',
        'lib/features/auth/data/datasources/auth_remote_datasource.dart',
        'lib/features/auth/domain/entities/user.dart',
        'lib/features/auth/domain/entities/subscription.dart',
        'lib/features/auth/domain/repositories/auth_repository.dart',
        'lib/features/auth/presentation/providers/auth_provider.dart',
        'lib/features/auth/presentation/providers/user_provider.dart',
        'lib/features/auth/presentation/providers/subscription_provider.dart',
        'lib/features/auth/presentation/pages/login_page.dart',
        'lib/features/auth/presentation/pages/register_page.dart',
        'lib/features/auth/presentation/pages/forgot_password_page.dart',
        'lib/features/auth/presentation/pages/profile_selection_page.dart',
        'lib/features/auth/presentation/pages/subscription_page.dart',
        'lib/features/auth/presentation/widgets/auth_form.dart',
        'lib/features/auth/presentation/widgets/social_login_buttons.dart',
        'lib/features/auth/presentation/widgets/profile_card.dart',
        'lib/features/auth/presentation/widgets/subscription_card.dart',
        'lib/features/home/data/models/content_model.dart',
        'lib/features/home/data/models/category_model.dart',
        'lib/features/home/data/models/collection_model.dart',
        'lib/features/home/data/models/recommendation_model.dart',
        'lib/features/home/data/repositories/home_repository_impl.dart',
        'lib/features/home/data/datasources/home_local_datasource.dart',
        'lib/features/home/data/datasources/home_remote_datasource.dart',
        'lib/features/home/domain/entities/content.dart',
        'lib/features/home/domain/entities/category.dart',
        'lib/features/home/domain/entities/collection.dart',
        'lib/features/home/domain/repositories/home_repository.dart',
        'lib/features/home/presentation/providers/home_provider.dart',
        'lib/features/home/presentation/providers/featured_content_provider.dart',
        'lib/features/home/presentation/providers/trending_provider.dart',
        'lib/features/home/presentation/providers/recommendations_provider.dart',
        'lib/features/home/presentation/pages/home_page.dart',
        'lib/features/home/presentation/pages/browse_page.dart',
        'lib/features/home/presentation/pages/search_page.dart',
        'lib/features/home/presentation/widgets/hero_banner.dart',
        'lib/features/home/presentation/widgets/content_row.dart',
        'lib/features/home/presentation/widgets/content_card.dart',
        'lib/features/home/presentation/widgets/category_tabs.dart',
        'lib/features/home/presentation/widgets/search_bar_widget.dart',
        'lib/features/home/presentation/widgets/filter_chips.dart',
        'lib/features/player/data/models/episode_model.dart',
        'lib/features/player/data/models/series_model.dart',
        'lib/features/player/data/models/season_model.dart',
        'lib/features/player/data/models/watch_history_model.dart',
        'lib/features/player/data/repositories/player_repository_impl.dart',
        'lib/features/player/data/datasources/player_local_datasource.dart',
        'lib/features/player/data/datasources/player_remote_datasource.dart',
        'lib/features/player/domain/entities/episode.dart',
        'lib/features/player/domain/entities/series.dart',
        'lib/features/player/domain/entities/watch_progress.dart',
        'lib/features/player/domain/repositories/player_repository.dart',
        'lib/features/player/presentation/providers/video_player_provider.dart',
        'lib/features/player/presentation/providers/playback_provider.dart',
        'lib/features/player/presentation/providers/subtitle_provider.dart',
        'lib/features/player/presentation/providers/watch_history_provider.dart',
        'lib/features/player/presentation/pages/video_player_page.dart',
        'lib/features/player/presentation/pages/content_details_page.dart',
        'lib/features/player/presentation/pages/episodes_page.dart',
        'lib/features/player/presentation/widgets/video_player_widget.dart',
        'lib/features/player/presentation/widgets/player_controls.dart',
        'lib/features/player/presentation/widgets/progress_bar.dart',
        'lib/features/player/presentation/widgets/quality_selector.dart',
        'lib/features/player/presentation/widgets/subtitle_settings.dart',
        'lib/features/player/presentation/widgets/episode_list.dart',
        'lib/features/player/presentation/widgets/content_info_panel.dart',
        'lib/features/watchlist/data/models/watchlist_model.dart',
        'lib/features/watchlist/data/repositories/watchlist_repository_impl.dart',
        'lib/features/watchlist/data/datasources/watchlist_local_datasource.dart',
        'lib/features/watchlist/data/datasources/watchlist_remote_datasource.dart',
        'lib/features/watchlist/domain/entities/watchlist_item.dart',
        'lib/features/watchlist/domain/repositories/watchlist_repository.dart',
        'lib/features/watchlist/presentation/providers/watchlist_provider.dart',
        'lib/features/watchlist/presentation/pages/watchlist_page.dart',
        'lib/features/watchlist/presentation/widgets/watchlist_grid.dart',
        'lib/features/watchlist/presentation/widgets/watchlist_item_card.dart',
        'lib/features/downloads/data/models/download_model.dart',
        'lib/features/downloads/data/repositories/downloads_repository_impl.dart',
        'lib/features/downloads/data/datasources/downloads_local_datasource.dart',
        'lib/features/downloads/data/datasources/downloads_remote_datasource.dart',
        'lib/features/downloads/domain/entities/download_item.dart',
        'lib/features/downloads/domain/repositories/downloads_repository.dart',
        'lib/features/downloads/presentation/providers/downloads_provider.dart',
        'lib/features/downloads/presentation/pages/downloads_page.dart',
        'lib/features/downloads/presentation/widgets/download_item_card.dart',
        'lib/features/downloads/presentation/widgets/download_progress_bar.dart',
        'lib/features/downloads/presentation/widgets/download_quality_selector.dart',
        'lib/features/profile/data/models/profile_model.dart',
        'lib/features/profile/data/models/notification_model.dart',
        'lib/features/profile/data/repositories/profile_repository_impl.dart',
        'lib/features/profile/data/datasources/profile_local_datasource.dart',
        'lib/features/profile/data/datasources/profile_remote_datasource.dart',
        'lib/features/profile/domain/entities/user_profile.dart',
        'lib/features/profile/domain/entities/notification.dart',
        'lib/features/profile/domain/repositories/profile_repository.dart',
        'lib/features/profile/presentation/providers/profile_provider.dart',
        'lib/features/profile/presentation/providers/preferences_provider.dart',
        'lib/features/profile/presentation/providers/notifications_provider.dart',
        'lib/features/profile/presentation/pages/profile_page.dart',
        'lib/features/profile/presentation/pages/account_settings_page.dart',
        'lib/features/profile/presentation/pages/manage_profiles_page.dart',
        'lib/features/profile/presentation/pages/notifications_page.dart',
        'lib/features/profile/presentation/pages/preferences_page.dart',
        'lib/features/profile/presentation/widgets/profile_header.dart',
        'lib/features/profile/presentation/widgets/settings_tile.dart',
        'lib/features/profile/presentation/widgets/profile_avatar.dart',
        'lib/features/profile/presentation/widgets/notification_item.dart',
        'lib/features/admin/data/models/admin_user_model.dart',
        'lib/features/admin/data/models/analytics_model.dart',
        'lib/features/admin/data/models/content_report_model.dart',
        'lib/features/admin/data/models/payment_history_model.dart',
        'lib/features/admin/data/repositories/admin_repository_impl.dart',
        'lib/features/admin/data/datasources/admin_local_datasource.dart',
        'lib/features/admin/data/datasources/admin_remote_datasource.dart',
        'lib/features/admin/domain/entities/admin_user.dart',
        'lib/features/admin/domain/entities/analytics_data.dart',
        'lib/features/admin/domain/entities/content_report.dart',
        'lib/features/admin/domain/repositories/admin_repository.dart',
        'lib/features/admin/presentation/providers/admin_auth_provider.dart',
        'lib/features/admin/presentation/providers/content_management_provider.dart',
        'lib/features/admin/presentation/providers/user_management_provider.dart',
        'lib/features/admin/presentation/providers/analytics_provider.dart',
        'lib/features/admin/presentation/providers/reports_provider.dart',
        'lib/features/admin/presentation/pages/admin_dashboard_page.dart',
        'lib/features/admin/presentation/pages/admin_login_page.dart',
        'lib/features/admin/presentation/pages/content_management_page.dart',
        'lib/features/admin/presentation/pages/user_management_page.dart',
        'lib/features/admin/presentation/pages/analytics_page.dart',
        'lib/features/admin/presentation/pages/reports_page.dart',
        'lib/features/admin/presentation/pages/subscription_management_page.dart',
        'lib/features/admin/presentation/pages/settings_management_page.dart',
        'lib/features/admin/presentation/widgets/admin_sidebar.dart',
        'lib/features/admin/presentation/widgets/dashboard_card.dart',
        'lib/features/admin/presentation/widgets/data_table_widget.dart',
        'lib/features/admin/presentation/widgets/chart_widget.dart',
        'lib/features/admin/presentation/widgets/content_editor.dart',
        'lib/features/admin/presentation/widgets/user_actions_menu.dart',
        'lib/features/admin/presentation/widgets/analytics_chart.dart',
        'lib/features/common/widgets/layouts/app_layout.dart',
        'lib/features/common/widgets/layouts/mobile_layout.dart',
        'lib/features/common/widgets/layouts/tablet_layout.dart',
        'lib/features/common/widgets/layouts/desktop_layout.dart',
        'lib/features/common/widgets/layouts/responsive_layout.dart',
        'lib/features/common/widgets/navigation/bottom_nav_bar.dart',
        'lib/features/common/widgets/navigation/sidebar_navigation.dart',
        'lib/features/common/widgets/navigation/app_bar_widget.dart',
        'lib/features/common/widgets/navigation/drawer_menu.dart',
        'lib/features/common/widgets/buttons/custom_button.dart',
        'lib/features/common/widgets/buttons/icon_button_widget.dart',
        'lib/features/common/widgets/buttons/floating_action_button.dart',
        'lib/features/common/widgets/buttons/play_button.dart',
        'lib/features/common/widgets/inputs/custom_text_field.dart',
        'lib/features/common/widgets/inputs/search_input.dart',
        'lib/features/common/widgets/inputs/dropdown_field.dart',
        'lib/features/common/widgets/inputs/checkbox_field.dart',
        'lib/features/common/widgets/cards/content_card.dart',
        'lib/features/common/widgets/cards/hero_card.dart',
        'lib/features/common/widgets/cards/info_card.dart',
        'lib/features/common/widgets/cards/shimmer_card.dart',
        'lib/features/common/widgets/loading/loading_spinner.dart',
        'lib/features/common/widgets/loading/shimmer_loading.dart',
        'lib/features/common/widgets/loading/skeleton_loader.dart',
        'lib/features/common/widgets/loading/progress_indicator.dart',
        'lib/features/common/widgets/dialogs/confirmation_dialog.dart',
        'lib/features/common/widgets/dialogs/error_dialog.dart',
        'lib/features/common/widgets/dialogs/loading_dialog.dart',
        'lib/features/common/widgets/dialogs/custom_dialog.dart',
        'lib/features/common/widgets/images/cached_network_image.dart',
        'lib/features/common/widgets/images/image_placeholder.dart',
        'lib/features/common/widgets/images/gradient_overlay.dart',
        'lib/features/common/widgets/misc/empty_state.dart',
        'lib/features/common/widgets/misc/error_widget.dart',
        'lib/features/common/widgets/misc/rating_widget.dart',
        'lib/features/common/widgets/misc/badge_widget.dart',
        'lib/features/common/widgets/misc/divider_widget.dart',
        'lib/features/common/providers/app_state_provider.dart',
        'lib/features/common/providers/theme_provider.dart',
        'lib/features/common/providers/connectivity_provider.dart',
        'lib/features/common/providers/locale_provider.dart'
    ]
    for file in feature_files:
        create_file(file)

    # Shared directories
    shared_dirs = ['lib/shared/services', 'lib/shared/managers', 'lib/shared/models']
    for dir in shared_dirs:
        create_directory(dir)

    # Shared files
    shared_files = [
        'lib/shared/services/storage_service.dart',
        'lib/shared/services/notification_service.dart',
        'lib/shared/services/analytics_service.dart',
        'lib/shared/services/download_service.dart',
        'lib/shared/services/streaming_service.dart',
        'lib/shared/services/payment_service.dart',
        'lib/shared/managers/auth_manager.dart',
        'lib/shared/managers/download_manager.dart',
        'lib/shared/managers/cache_manager.dart',
        'lib/shared/managers/session_manager.dart',
        'lib/shared/models/api_response.dart',
        'lib/shared/models/pagination.dart',
        'lib/shared/models/base_model.dart',
        'lib/shared/models/error_model.dart'
    ]
    for file in shared_files:
        create_file(file)

    # Routes directories
    create_directory('lib/routes/guards')
    create_directory('lib/routes/transitions')

    # Routes files
    routes_files = [
        'lib/routes/app_router.dart',
        'lib/routes/route_names.dart',
        'lib/routes/guards/auth_guard.dart',
        'lib/routes/guards/subscription_guard.dart',
        'lib/routes/guards/admin_guard.dart',
        'lib/routes/transitions/fade_transition.dart',
        'lib/routes/transitions/slide_transition.dart',
        'lib/routes/transitions/scale_transition.dart'
    ]
    for file in routes_files:
        create_file(file)

if __name__ == '__main__':
    create_project_structure()
    print("Flutter project structure created successfully!")