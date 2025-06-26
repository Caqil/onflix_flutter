import 'package:flutter/material.dart';
import 'package:onflix/core/constants/app_constants.dart';
import 'package:onflix/core/constants/asset_paths.dart';
import 'package:onflix/core/extensions/context_extension.dart';
import 'package:onflix/core/utils/responsive_helper.dart';

class DrawerMenu extends StatelessWidget {
  final int? selectedIndex;
  final Function(int)? onItemSelected;
  final List<DrawerMenuItem>? customItems;
  final Widget? header;
  final Widget? footer;
  final bool showUserProfile;
  final EdgeInsets? padding;

  const DrawerMenu({
    super.key,
    this.selectedIndex,
    this.onItemSelected,
    this.customItems,
    this.header,
    this.footer,
    this.showUserProfile = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final items = customItems ?? _getDefaultItems();
    final drawerPadding = padding ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getScaledPadding(context, 0),
          vertical: ResponsiveHelper.getScaledPadding(context, 8),
        );

    return Drawer(
      backgroundColor: context.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            if (header != null)
              header!
            else if (showUserProfile)
              _buildDefaultHeader(context),

            // Menu Items
            Expanded(
              child: ListView(
                padding: drawerPadding,
                children: [
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _buildMenuItem(context, item, index);
                  }).toList(),
                ],
              ),
            ),

            // Footer
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.getScaledPadding(context, 20)),
      decoration: BoxDecoration(
        color: context.colorScheme.primary.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Row(
            children: [
              Image.asset(
                AssetPaths.logoIcon,
                height: ResponsiveHelper.getScaledIconSize(context, 40),
                width: ResponsiveHelper.getScaledIconSize(context, 40),
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.movie,
                    size: ResponsiveHelper.getScaledIconSize(context, 40),
                    color: context.colorScheme.primary,
                  );
                },
              ),
              SizedBox(width: ResponsiveHelper.getScaledPadding(context, 12)),
              Text(
                'Onflix',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.primary,
                  fontSize: ResponsiveHelper.getScaledFontSize(context, 24),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveHelper.getScaledPadding(context, 16)),

          // User Profile Section
          Row(
            children: [
              CircleAvatar(
                radius: ResponsiveHelper.getScaledIconSize(context, 24),
                backgroundColor: context.colorScheme.primary,
                child: Icon(
                  Icons.person,
                  size: ResponsiveHelper.getScaledIconSize(context, 24),
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
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize:
                            ResponsiveHelper.getScaledFontSize(context, 16),
                      ),
                    ),
                    Text(
                      'Premium Member',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        fontSize:
                            ResponsiveHelper.getScaledFontSize(context, 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, DrawerMenuItem item, int index) {
    final isSelected = selectedIndex == index;

    if (item.isDivider) {
      return Divider(
        height: ResponsiveHelper.getScaledPadding(context, 32),
        thickness: 1,
        color: context.colorScheme.outline.withOpacity(0.1),
      );
    }

    if (item.isHeader) {
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
            fontSize: ResponsiveHelper.getScaledFontSize(context, 14),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getScaledPadding(context, 8),
        vertical: ResponsiveHelper.getScaledPadding(context, 2),
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          size: ResponsiveHelper.getScaledIconSize(context, 24),
          color: isSelected
              ? context.colorScheme.primary
              : context.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          item.title,
          style: context.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? context.colorScheme.primary
                : context.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: ResponsiveHelper.getScaledFontSize(context, 16),
          ),
        ),
        trailing: _buildTrailing(context, item, isSelected),
        selected: isSelected,
        selectedTileColor: context.colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        onTap: () {
          onItemSelected?.call(index);
          if (item.onTap != null) {
            item.onTap!();
          }
        },
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getScaledPadding(context, 16),
          vertical: ResponsiveHelper.getScaledPadding(context, 4),
        ),
      ),
    );
  }

  Widget? _buildTrailing(
      BuildContext context, DrawerMenuItem item, bool isSelected) {
    final widgets = <Widget>[];

    // Badge
    if (item.badgeCount != null && item.badgeCount! > 0) {
      widgets.add(
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getScaledPadding(context, 8),
            vertical: ResponsiveHelper.getScaledPadding(context, 2),
          ),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            item.badgeCount! > 99 ? '99+' : item.badgeCount.toString(),
            style: context.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: ResponsiveHelper.getScaledFontSize(context, 10),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Arrow for expandable items
    if (item.isExpandable) {
      widgets.add(
        Icon(
          Icons.keyboard_arrow_right,
          size: ResponsiveHelper.getScaledIconSize(context, 20),
          color: isSelected
              ? context.colorScheme.primary
              : context.colorScheme.onSurfaceVariant,
        ),
      );
    }

    if (widgets.isEmpty) return null;

    if (widgets.length == 1) return widgets.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widgets
          .map((widget) => Padding(
                padding: EdgeInsets.only(
                  left: ResponsiveHelper.getScaledPadding(context, 4),
                ),
                child: widget,
              ))
          .toList(),
    );
  }

  List<DrawerMenuItem> _getDefaultItems() {
    return [
      const DrawerMenuItem(
        icon: Icons.home,
        title: 'Home',
      ),
      const DrawerMenuItem(
        icon: Icons.explore,
        title: 'Browse',
      ),
      const DrawerMenuItem(
        icon: Icons.search,
        title: 'Search',
      ),
      const DrawerMenuItem(
        isDivider: true,
        title: '',
      ),
      const DrawerMenuItem(
        isHeader: true,
        title: 'MY LIBRARY',
      ),
      const DrawerMenuItem(
        icon: Icons.bookmark,
        title: 'Watchlist',
      ),
      const DrawerMenuItem(
        icon: Icons.favorite,
        title: 'Favorites',
      ),
      const DrawerMenuItem(
        icon: Icons.history,
        title: 'Continue Watching',
      ),
      const DrawerMenuItem(
        icon: Icons.download,
        title: 'Downloads',
      ),
      const DrawerMenuItem(
        isDivider: true,
        title: '',
      ),
      const DrawerMenuItem(
        isHeader: true,
        title: 'ACCOUNT',
      ),
      const DrawerMenuItem(
        icon: Icons.person,
        title: 'Profile',
      ),
      const DrawerMenuItem(
        icon: Icons.settings,
        title: 'Settings',
      ),
      const DrawerMenuItem(
        icon: Icons.help,
        title: 'Help & Support',
      ),
      const DrawerMenuItem(
        icon: Icons.logout,
        title: 'Sign Out',
      ),
    ];
  }
}

class CollapsibleDrawerMenu extends StatefulWidget {
  final int? selectedIndex;
  final Function(int)? onItemSelected;
  final List<DrawerMenuItem>? customItems;
  final Widget? header;
  final Widget? footer;
  final bool showUserProfile;
  final bool initiallyExpanded;

  const CollapsibleDrawerMenu({
    super.key,
    this.selectedIndex,
    this.onItemSelected,
    this.customItems,
    this.header,
    this.footer,
    this.showUserProfile = true,
    this.initiallyExpanded = true,
  });

  @override
  State<CollapsibleDrawerMenu> createState() => _CollapsibleDrawerMenuState();
}

class _CollapsibleDrawerMenuState extends State<CollapsibleDrawerMenu>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.customItems ?? _getDefaultItems();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: ResponsiveHelper.responsive(
            context,
            mobile: 280 * _animation.value + 80 * (1 - _animation.value),
            tablet: 320 * _animation.value + 80 * (1 - _animation.value),
            desktop: 320 * _animation.value + 80 * (1 - _animation.value),
          ),
          color: context.colorScheme.surface,
          child: SafeArea(
            child: Column(
              children: [
                // Toggle Button
                Container(
                  padding: EdgeInsets.all(
                      ResponsiveHelper.getScaledPadding(context, 16)),
                  child: Row(
                    children: [
                      if (_isExpanded) ...[
                        Image.asset(
                          AssetPaths.logoIcon,
                          height:
                              ResponsiveHelper.getScaledIconSize(context, 32),
                          width:
                              ResponsiveHelper.getScaledIconSize(context, 32),
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.movie,
                              size: ResponsiveHelper.getScaledIconSize(
                                  context, 32),
                              color: context.colorScheme.primary,
                            );
                          },
                        ),
                        SizedBox(
                            width:
                                ResponsiveHelper.getScaledPadding(context, 12)),
                        Expanded(
                          child: Text(
                            'Onflix',
                            style: context.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                      IconButton(
                        icon: Icon(
                          _isExpanded ? Icons.menu_open : Icons.menu,
                          size: ResponsiveHelper.getScaledIconSize(context, 24),
                        ),
                        onPressed: _toggleExpanded,
                      ),
                    ],
                  ),
                ),

                // Menu Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getScaledPadding(context, 8),
                    ),
                    children: items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildCollapsibleMenuItem(context, item, index);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollapsibleMenuItem(
      BuildContext context, DrawerMenuItem item, int index) {
    final isSelected = widget.selectedIndex == index;

    if (item.isDivider) {
      return SizedBox(height: ResponsiveHelper.getScaledPadding(context, 16));
    }

    if (item.isHeader) {
      if (!_isExpanded) return const SizedBox.shrink();
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
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getScaledPadding(context, 2)),
      child: ListTile(
        leading: Icon(
          item.icon,
          size: ResponsiveHelper.getScaledIconSize(context, 24),
          color: isSelected
              ? context.colorScheme.primary
              : context.colorScheme.onSurfaceVariant,
        ),
        title: _isExpanded
            ? Text(
                item.title,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              )
            : null,
        selected: isSelected,
        selectedTileColor: context.colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        onTap: () {
          widget.onItemSelected?.call(index);
          if (item.onTap != null) {
            item.onTap!();
          }
        },
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getScaledPadding(context, 16),
          vertical: ResponsiveHelper.getScaledPadding(context, 4),
        ),
      ),
    );
  }

  List<DrawerMenuItem> _getDefaultItems() {
    return [
      const DrawerMenuItem(icon: Icons.home, title: 'Home'),
      const DrawerMenuItem(icon: Icons.explore, title: 'Browse'),
      const DrawerMenuItem(icon: Icons.search, title: 'Search'),
      const DrawerMenuItem(isDivider: true, title: ''),
      const DrawerMenuItem(isHeader: true, title: 'LIBRARY'),
      const DrawerMenuItem(icon: Icons.bookmark, title: 'Watchlist'),
      const DrawerMenuItem(icon: Icons.favorite, title: 'Favorites'),
      const DrawerMenuItem(icon: Icons.history, title: 'History'),
      const DrawerMenuItem(icon: Icons.download, title: 'Downloads'),
      const DrawerMenuItem(isDivider: true, title: ''),
      const DrawerMenuItem(icon: Icons.person, title: 'Profile'),
      const DrawerMenuItem(icon: Icons.settings, title: 'Settings'),
      const DrawerMenuItem(icon: Icons.logout, title: 'Sign Out'),
    ];
  }
}

class DrawerMenuItem {
  final IconData? icon;
  final String title;
  final int? badgeCount;
  final bool isDivider;
  final bool isHeader;
  final bool isExpandable;
  final VoidCallback? onTap;
  final List<DrawerMenuItem>? children;

  const DrawerMenuItem({
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
