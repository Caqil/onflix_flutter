import 'package:flutter/material.dart';
import 'package:onflix/core/constants/app_constants.dart';
import 'package:onflix/core/constants/asset_paths.dart';
import 'package:onflix/core/extensions/context_extension.dart';
import 'package:onflix/core/utils/responsive_helper.dart';

class SidebarNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int, String)? onItemSelected;
  final List<SidebarMenuItem>? customItems;
  final double? width;
  final double? height;
  final Widget? header;
  final Widget? footer;
  final bool showUserProfile;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const SidebarNavigation({
    super.key,
    required this.selectedIndex,
    this.onItemSelected,
    this.customItems,
    this.width,
    this.height,
    this.header,
    this.footer,
    this.showUserProfile = true,
    this.isCollapsed = false,
    this.onToggleCollapse,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final items = customItems ?? _getDefaultItems();
    final sidebarWidth = width ?? ResponsiveHelper.getSidebarWidth(context);
    final sidebarHeight = height ?? double.infinity;
    final sidebarPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getScaledPadding(context, 8),
          vertical: ResponsiveHelper.getScaledPadding(context, 16),
        );

    return Container(
      width: isCollapsed ? 80 : sidebarWidth,
      height: sidebarHeight,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: context.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          if (header != null) header! else _buildDefaultHeader(context),

          // Menu Items
          Expanded(
            child: ListView(
              padding: sidebarPadding,
              children: [
                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildMenuItem(context, item, index);
                }),
              ],
            ),
          ),

          // Footer
          if (footer != null) footer! else _buildDefaultFooter(context),
        ],
      ),
    );
  }

  Widget _buildDefaultHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.getScaledPadding(context, 16)),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo and Toggle
          Row(
            children: [
              if (!isCollapsed) ...[
                Image.asset(
                  AssetPaths.logoIcon,
                  height: ResponsiveHelper.getScaledIconSize(context, 32),
                  width: ResponsiveHelper.getScaledIconSize(context, 32),
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.movie,
                      size: ResponsiveHelper.getScaledIconSize(context, 32),
                      color: context.colorScheme.primary,
                    );
                  },
                ),
                SizedBox(width: ResponsiveHelper.getScaledPadding(context, 12)),
                Expanded(
                  child: Text(
                    'Onflix',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.primary,
                      fontSize: ResponsiveHelper.getScaledFontSize(context, 20),
                    ),
                  ),
                ),
              ],
              if (onToggleCollapse != null)
                IconButton(
                  icon: Icon(
                    isCollapsed ? Icons.menu : Icons.menu_open,
                    size: ResponsiveHelper.getScaledIconSize(context, 24),
                  ),
                  onPressed: onToggleCollapse,
                  tooltip: isCollapsed ? 'Expand' : 'Collapse',
                ),
            ],
          ),

          // User Profile (if not collapsed and enabled)
          if (!isCollapsed && showUserProfile) ...[
            SizedBox(height: ResponsiveHelper.getScaledPadding(context, 16)),
            _buildUserProfile(context),
          ],
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getScaledPadding(context, 12)),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: ResponsiveHelper.getScaledIconSize(context, 20),
            backgroundColor: context.colorScheme.primary,
            child: Icon(
              Icons.person,
              size: ResponsiveHelper.getScaledIconSize(context, 20),
              color: context.colorScheme.onPrimary,
            ),
          ),
          SizedBox(width: ResponsiveHelper.getScaledPadding(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveHelper.getScaledFontSize(context, 14),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Premium',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.primary,
                    fontSize: ResponsiveHelper.getScaledFontSize(context, 11),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, SidebarMenuItem item, int index) {
    final isSelected = selectedIndex == index;

    if (item.isDivider) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getScaledPadding(context, 8),
        ),
        child: Divider(
          thickness: 1,
          color: context.colorScheme.outline.withOpacity(0.1),
        ),
      );
    }

    if (item.isHeader) {
      if (isCollapsed) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.fromLTRB(
          ResponsiveHelper.getScaledPadding(context, 16),
          ResponsiveHelper.getScaledPadding(context, 24),
          ResponsiveHelper.getScaledPadding(context, 16),
          ResponsiveHelper.getScaledPadding(context, 8),
        ),
        child: Text(
          item.title,
          style: context.textTheme.titleSmall?.copyWith(
            color: context.colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveHelper.getScaledFontSize(context, 12),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.getScaledPadding(context, 2),
      ),
      child: Tooltip(
        message: isCollapsed ? item.title : '',
        child: InkWell(
          onTap: () {
            onItemSelected?.call(index, item.title);
            if (item.onTap != null) {
              item.onTap!();
            }
          },
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          child: AnimatedContainer(
            duration: AppConstants.shortAnimation,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getScaledPadding(context, 16),
              vertical: ResponsiveHelper.getScaledPadding(context, 12),
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              border: isSelected
                  ? Border.all(
                      color: context.colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Icon with badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      item.icon,
                      size: ResponsiveHelper.getScaledIconSize(context, 24),
                      color: isSelected
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurfaceVariant,
                    ),
                    if (item.badgeCount != null && item.badgeCount! > 0)
                      Positioned(
                        right: -8,
                        top: -8,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                ResponsiveHelper.getScaledPadding(context, 4),
                            vertical:
                                ResponsiveHelper.getScaledPadding(context, 2),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          constraints: BoxConstraints(
                            minWidth:
                                ResponsiveHelper.getScaledIconSize(context, 16),
                            minHeight:
                                ResponsiveHelper.getScaledIconSize(context, 16),
                          ),
                          child: Text(
                            item.badgeCount! > 99
                                ? '99+'
                                : item.badgeCount.toString(),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontSize: ResponsiveHelper.getScaledFontSize(
                                  context, 9),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),

                // Title (if not collapsed)
                if (!isCollapsed) ...[
                  SizedBox(
                      width: ResponsiveHelper.getScaledPadding(context, 16)),
                  Expanded(
                    child: Text(
                      item.title,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? context.colorScheme.primary
                            : context.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize:
                            ResponsiveHelper.getScaledFontSize(context, 15),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                // Trailing icons
                if (!isCollapsed && item.isExpandable)
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: ResponsiveHelper.getScaledIconSize(context, 20),
                    color: isSelected
                        ? context.colorScheme.primary
                        : context.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultFooter(BuildContext context) {
    if (isCollapsed) {
      return Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getScaledPadding(context, 16)),
        child: Column(
          children: [
            IconButton(
              icon: Icon(
                Icons.settings,
                size: ResponsiveHelper.getScaledIconSize(context, 24),
                color: context.colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                // Navigate to settings
              },
              tooltip: 'Settings',
            ),
            SizedBox(height: ResponsiveHelper.getScaledPadding(context, 8)),
            IconButton(
              icon: Icon(
                Icons.logout,
                size: ResponsiveHelper.getScaledIconSize(context, 24),
                color: context.colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                // Handle logout
              },
              tooltip: 'Sign Out',
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getScaledPadding(context, 16)),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.settings,
              size: ResponsiveHelper.getScaledIconSize(context, 20),
              color: context.colorScheme.onSurfaceVariant,
            ),
            title: Text(
              'Settings',
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: ResponsiveHelper.getScaledFontSize(context, 14),
              ),
            ),
            onTap: () {
              // Navigate to settings
            },
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getScaledPadding(context, 8),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              size: ResponsiveHelper.getScaledIconSize(context, 20),
              color: Colors.red,
            ),
            title: Text(
              'Sign Out',
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.red,
                fontSize: ResponsiveHelper.getScaledFontSize(context, 14),
              ),
            ),
            onTap: () {
              // Handle logout
            },
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getScaledPadding(context, 8),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            ),
          ),
        ],
      ),
    );
  }

  List<SidebarMenuItem> _getDefaultItems() {
    return [
      const SidebarMenuItem(
        icon: Icons.home,
        title: 'Home',
      ),
      const SidebarMenuItem(
        icon: Icons.explore,
        title: 'Browse',
      ),
      const SidebarMenuItem(
        icon: Icons.search,
        title: 'Search',
      ),
      const SidebarMenuItem(
        isDivider: true,
        title: '',
      ),
      const SidebarMenuItem(
        isHeader: true,
        title: 'MY LIBRARY',
      ),
      const SidebarMenuItem(
        icon: Icons.bookmark,
        title: 'Watchlist',
      ),
      const SidebarMenuItem(
        icon: Icons.favorite,
        title: 'Favorites',
      ),
      const SidebarMenuItem(
        icon: Icons.history,
        title: 'Continue Watching',
      ),
      const SidebarMenuItem(
        icon: Icons.download,
        title: 'Downloads',
      ),
      const SidebarMenuItem(
        isDivider: true,
        title: '',
      ),
      const SidebarMenuItem(
        isHeader: true,
        title: 'CATEGORIES',
      ),
      const SidebarMenuItem(
        icon: Icons.movie,
        title: 'Movies',
      ),
      const SidebarMenuItem(
        icon: Icons.tv,
        title: 'TV Shows',
      ),
      const SidebarMenuItem(
        icon: Icons.description,
        title: 'Documentaries',
      ),
    ];
  }
}

class AnimatedSidebarNavigation extends StatefulWidget {
  final int selectedIndex;
  final Function(int, String)? onItemSelected;
  final List<SidebarMenuItem>? customItems;
  final double? width;
  final double? height;
  final bool initiallyCollapsed;
  final Duration animationDuration;

  const AnimatedSidebarNavigation({
    super.key,
    required this.selectedIndex,
    this.onItemSelected,
    this.customItems,
    this.width,
    this.height,
    this.initiallyCollapsed = false,
    this.animationDuration = AppConstants.mediumAnimation,
  });

  @override
  State<AnimatedSidebarNavigation> createState() =>
      _AnimatedSidebarNavigationState();
}

class _AnimatedSidebarNavigationState extends State<AnimatedSidebarNavigation>
    with SingleTickerProviderStateMixin {
  late bool _isCollapsed;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.initiallyCollapsed;
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (!_isCollapsed) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
      if (_isCollapsed) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final fullWidth =
            widget.width ?? ResponsiveHelper.getSidebarWidth(context);
        final collapsedWidth = 80.0;
        final currentWidth =
            collapsedWidth + (fullWidth - collapsedWidth) * _animation.value;

        return SidebarNavigation(
          selectedIndex: widget.selectedIndex,
          onItemSelected: widget.onItemSelected,
          customItems: widget.customItems,
          width: currentWidth,
          height: widget.height,
          isCollapsed: _animation.value < 0.5,
          onToggleCollapse: _toggleCollapse,
        );
      },
    );
  }
}

class SidebarMenuItem {
  final IconData? icon;
  final String title;
  final int? badgeCount;
  final bool isDivider;
  final bool isHeader;
  final bool isExpandable;
  final VoidCallback? onTap;
  final List<SidebarMenuItem>? children;

  const SidebarMenuItem({
    this.icon,
    required this.title,
    this.badgeCount,
    this.isDivider = false,
    this.isHeader = false,
    this.isExpandable = false,
    this.onTap,
    this.children,
  });
}
