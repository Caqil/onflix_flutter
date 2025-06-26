import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
import 'package:onflix/routes/route_names.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'app_layout.dart';

/// Mobile layout with bottom navigation and drawer
class MobileLayout extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final Function(int index, String route) onNavigationItemSelected;
  final bool isSidebarOpen;
  final VoidCallback onToggleSidebar;
  final VoidCallback onCloseSidebar;
  final Animation<double> sidebarAnimation;
  final Animation<double> overlayAnimation;

  const MobileLayout({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.onNavigationItemSelected,
    required this.isSidebarOpen,
    required this.onToggleSidebar,
    required this.onCloseSidebar,
    required this.sidebarAnimation,
    required this.overlayAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // App bar
              OnflixAppBar(
                showMenuButton: true,
                onMenuPressed: onToggleSidebar,
                centerTitle: true,
                titleWidget: _buildAppTitle(context),
              ),
              
              // Content area
              Expanded(
                child: child,
              ),
            ],
          ),
          
          // Sidebar drawer
          if (isSidebarOpen) _buildSidebarDrawer(context),
          
          // Overlay
          if (isSidebarOpen) _buildOverlay(context),
        ],
      ),
      
      // Bottom navigation
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildAppTitle(BuildContext context) {
    final location = GoRouterState.of(context).path;
    final title = _getTitleFromLocation(location!);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: OnflixColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            LucideIcons.play,
            color: OnflixColors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getTitleFromLocation(String location) {
    if (location.startsWith(RouteNames.home)) return 'Onflix';
    if (location.startsWith(RouteNames.browse)) return 'Browse';
    if (location.startsWith(RouteNames.search)) return 'Search';
    if (location.startsWith(RouteNames.watchlist)) return 'My List';
    if (location.startsWith(RouteNames.downloads)) return 'Downloads';
    if (location.startsWith(RouteNames.profile)) return 'Profile';
    return 'Onflix';
  }

  Widget _buildSidebarDrawer(BuildContext context) {
    return AnimatedBuilder(
      animation: sidebarAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            sidebarAnimation.value * MediaQuery.of(context).size.width * 0.85,
            0,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with close button
                  _buildDrawerHeader(context),
                  
                  // Navigation items
                  Expanded(
                    child: _buildDrawerNavigation(context),
                  ),
                  
                  // Footer
                  _buildDrawerFooter(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: OnflixColors.lightGray.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: OnflixColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.play,
              color: OnflixColors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // App name
          Expanded(
            child: Text(
              'Onflix',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: OnflixColors.primary,
              ),
            ),
          ),
          
          // Close button
          IconButton(
            onPressed: onCloseSidebar,
            icon: const Icon(LucideIcons.x),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerNavigation(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main navigation
          _buildDrawerSection(
            context,
            'Browse',
            AppNavigationItems.mainItems,
          ),
          
          const SizedBox(height: 24),
          
          // Account section
          _buildDrawerSection(
            context,
            'Account',
            AppNavigationItems.userItems,
          ),
          
          const SizedBox(height: 24),
          
          // Additional options
          _buildDrawerSection(
            context,
            'More',
            [
              const NavigationItem(
                label: 'Settings',
                icon: LucideIcons.settings,
                route: '/settings',
              ),
              const NavigationItem(
                label: 'Help & Support',
                icon: LucideIcons.handHelping,
                route: '/help',
              ),
              const NavigationItem(
                label: 'About',
                icon: LucideIcons.info,
                route: '/about',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(
    BuildContext context,
    String title,
    List<NavigationItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: OnflixColors.lightGray,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isMainItem = AppNavigationItems.mainItems.contains(item);
          final itemIndex = isMainItem 
              ? AppNavigationItems.mainItems.indexOf(item)
              : -1;
          final isSelected = isMainItem && selectedIndex == itemIndex;
          
          return _buildDrawerItem(
            context,
            item,
            isSelected,
            () {
              if (isMainItem) {
                onNavigationItemSelected(itemIndex, item.route);
              } else {
                context.go(item.route);
                onCloseSidebar();
              }
            },
          );
        }),
      ],
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    NavigationItem item,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? OnflixColors.primary.withOpacity(0.1) 
                : null,
            border: isSelected 
                ? Border(
                    right: BorderSide(
                      color: OnflixColors.primary,
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                size: 22,
                color: isSelected 
                    ? OnflixColors.primary 
                    : OnflixColors.lightGray,
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected 
                        ? OnflixColors.primary 
                        : null,
                    fontWeight: isSelected 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                  ),
                ),
              ),
              
              if (item.route == RouteNames.downloads)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: OnflixColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '2',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: OnflixColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: OnflixColors.lightGray.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Sign out button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Handle sign out
                onCloseSidebar();
              },
              icon: const Icon(LucideIcons.logOut, size: 16),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(
                  color: OnflixColors.lightGray.withOpacity(0.3),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // App version
          Text(
            'Version 1.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: OnflixColors.lightGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return AnimatedBuilder(
      animation: overlayAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: onCloseSidebar,
          child: Container(
            color: Colors.black.withOpacity(overlayAnimation.value),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    // Only show main navigation items in bottom bar
    final mainItems = AppNavigationItems.mainItems.take(5).toList();
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: OnflixColors.lightGray.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: mainItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = selectedIndex == index;

              return _buildBottomNavItem(
                context,
                item,
                isSelected,
                () => onNavigationItemSelected(index, item.route),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context,
    NavigationItem item,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with selection indicator
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected 
                    ? OnflixColors.primary.withOpacity(0.15) 
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                size: 22,
                color: isSelected 
                    ? OnflixColors.primary 
                    : OnflixColors.lightGray,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Label
            Text(
              item.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected 
                    ? OnflixColors.primary 
                    : OnflixColors.lightGray,
                fontWeight: isSelected 
                    ? FontWeight.w600 
                    : FontWeight.normal,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Selection indicator
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: OnflixColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}