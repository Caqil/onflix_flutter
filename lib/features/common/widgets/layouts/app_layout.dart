import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
import 'package:onflix/core/constants/app_constants.dart';
import 'package:onflix/core/extensions/context_extension.dart';
import 'package:onflix/core/utils/responsive_helper.dart';
import 'package:onflix/routes/route_names.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../providers/theme_provider.dart';
import 'desktop_layout.dart';
import 'mobile_layout.dart';
import 'tablet_layout.dart';
import 'responsive_layout.dart';

/// Main app layout that adapts to different screen sizes and provides consistent navigation
class AppLayout extends ConsumerStatefulWidget {
  final Widget child;

  const AppLayout({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends ConsumerState<AppLayout>
    with TickerProviderStateMixin {
  late AnimationController _sidebarController;
  late AnimationController _overlayController;
  late Animation<double> _sidebarAnimation;
  late Animation<double> _overlayAnimation;

  bool _isSidebarOpen = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateSelectedIndex();
  }

  void _initializeAnimations() {
    _sidebarController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _overlayController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );

    _sidebarAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeInOut,
    ));

    _overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final location = GoRouterState.of(context).path;
    setState(() {
      _selectedIndex = _getIndexFromLocation(location!);
    });
  }

  int _getIndexFromLocation(String location) {
    if (location.startsWith(RouteNames.home)) return 0;
    if (location.startsWith(RouteNames.browse)) return 1;
    if (location.startsWith(RouteNames.search)) return 2;
    if (location.startsWith(RouteNames.watchlist)) return 3;
    if (location.startsWith(RouteNames.downloads)) return 4;
    if (location.startsWith(RouteNames.profile)) return 5;
    return 0;
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });

    if (_isSidebarOpen) {
      _sidebarController.forward();
      _overlayController.forward();
    } else {
      _sidebarController.reverse();
      _overlayController.reverse();
    }
  }

  void _closeSidebar() {
    if (_isSidebarOpen) {
      setState(() {
        _isSidebarOpen = false;
      });
      _sidebarController.reverse();
      _overlayController.reverse();
    }
  }

  void _onNavigationItemSelected(int index, String route) {
    setState(() {
      _selectedIndex = index;
    });

    if (context.isMobile) {
      _closeSidebar();
    }

    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: MobileLayout(
        selectedIndex: _selectedIndex,
        onNavigationItemSelected: _onNavigationItemSelected,
        isSidebarOpen: _isSidebarOpen,
        onToggleSidebar: _toggleSidebar,
        onCloseSidebar: _closeSidebar,
        sidebarAnimation: _sidebarAnimation,
        overlayAnimation: _overlayAnimation,
        child: widget.child,
      ),
      tablet: TabletLayout(
        selectedIndex: _selectedIndex,
        onNavigationItemSelected: _onNavigationItemSelected,
        isSidebarOpen: _isSidebarOpen,
        onToggleSidebar: _toggleSidebar,
        onCloseSidebar: _closeSidebar,
        sidebarAnimation: _sidebarAnimation,
        overlayAnimation: _overlayAnimation,
        child: widget.child,
      ),
      desktop: DesktopLayout(
        selectedIndex: _selectedIndex,
        onNavigationItemSelected: _onNavigationItemSelected,
        child: widget.child,
      ),
    );
  }
}

/// Navigation item model for consistent navigation across layouts
class NavigationItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String route;
  final bool requiresAuth;
  final List<NavigationItem>? subItems;

  const NavigationItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    required this.route,
    this.requiresAuth = true,
    this.subItems,
  });
}

/// Predefined navigation items for the app
class AppNavigationItems {
  static const List<NavigationItem> mainItems = [
    NavigationItem(
      label: 'Home',
      icon: LucideIcons.house,
      activeIcon: LucideIcons.house600,
      route: RouteNames.home,
    ),
    NavigationItem(
      label: 'Browse',
      icon: LucideIcons.compass,
      activeIcon: LucideIcons.compass,
      route: RouteNames.browse,
    ),
    NavigationItem(
      label: 'Search',
      icon: LucideIcons.search,
      activeIcon: LucideIcons.search,
      route: RouteNames.search,
    ),
    NavigationItem(
      label: 'My List',
      icon: LucideIcons.bookmark,
      activeIcon: LucideIcons.bookmark,
      route: RouteNames.watchlist,
    ),
    NavigationItem(
      label: 'Downloads',
      icon: LucideIcons.download,
      activeIcon: LucideIcons.download,
      route: RouteNames.downloads,
    ),
  ];

  static const List<NavigationItem> userItems = [
    NavigationItem(
      label: 'Profile',
      icon: LucideIcons.user,
      activeIcon: LucideIcons.user,
      route: RouteNames.profile,
    ),
  ];

  static const List<NavigationItem> settingsItems = [
    NavigationItem(
      label: 'Settings',
      icon: LucideIcons.settings,
      activeIcon: LucideIcons.settings,
      route: '/settings',
    ),
  ];
}

/// App bar widget for consistent top navigation
class OnflixAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const OnflixAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.showMenuButton = false,
    this.onMenuPressed,
    this.centerTitle = false,
    this.elevation,
    this.backgroundColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      leading: showMenuButton
          ? IconButton(
              icon: const Icon(LucideIcons.menu),
              onPressed: onMenuPressed,
            )
          : null,
      actions: [
        ...?actions,
        // Theme toggle button
        IconButton(
          icon: Icon(
            themeMode == ThemeMode.dark ? LucideIcons.sun : LucideIcons.moon,
          ),
          onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          tooltip: 'Toggle theme',
        ),
        // Profile button
        IconButton(
          icon: const Icon(LucideIcons.user),
          onPressed: () => context.go(RouteNames.profile),
          tooltip: 'Profile',
        ),
        const SizedBox(width: 8),
      ],
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      elevation: elevation,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}

/// Bottom navigation bar for mobile layout
class OnflixBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<NavigationItem> items;

  const OnflixBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.items = AppNavigationItems.mainItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: OnflixColors.lightGray.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = selectedIndex == index;

              return GestureDetector(
                onTap: () => onItemSelected(index),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                        size: 24,
                        color: isSelected
                            ? OnflixColors.primary
                            : OnflixColors.lightGray,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? OnflixColors.primary
                                  : OnflixColors.lightGray,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Sidebar navigation for tablet and desktop layouts
class OnflixSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isCollapsed;
  final List<NavigationItem> mainItems;
  final List<NavigationItem> userItems;
  final List<NavigationItem> settingsItems;

  const OnflixSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsed = false,
    this.mainItems = AppNavigationItems.mainItems,
    this.userItems = AppNavigationItems.userItems,
    this.settingsItems = AppNavigationItems.settingsItems,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = ResponsiveHelper.getSidebarWidth(context);

    return Container(
      width: isCollapsed ? 72 : sidebarWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          right: BorderSide(
            color: OnflixColors.lightGray.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo section
            _buildLogoSection(context),

            const SizedBox(height: 24),

            // Main navigation items
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...mainItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildNavigationItem(
                        context,
                        item,
                        index,
                        selectedIndex == index,
                      );
                    }),

                    const SizedBox(height: 24),

                    // User section
                    if (!isCollapsed) _buildSectionDivider(context, 'Account'),

                    ...userItems.asMap().entries.map((entry) {
                      final index = entry.key + mainItems.length;
                      final item = entry.value;
                      return _buildNavigationItem(
                        context,
                        item,
                        index,
                        selectedIndex == index,
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Settings section
            if (!isCollapsed) _buildSectionDivider(context, 'Settings'),

            ...settingsItems.map((item) {
              return _buildNavigationItem(
                context,
                item,
                -1, // Settings items don't participate in selection
                false,
              );
            }),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Container(
      height: ResponsiveHelper.getNavigationHeight(context),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // App logo
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: OnflixColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.play,
              color: OnflixColors.white,
              size: 20,
            ),
          ),

          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Text(
              'Onflix',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: OnflixColors.primary,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionDivider(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: OnflixColors.lightGray,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    NavigationItem item,
    int index,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? OnflixColors.primary.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                  size: 20,
                  color: isSelected
                      ? OnflixColors.primary
                      : OnflixColors.lightGray,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected ? OnflixColors.primary : null,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
