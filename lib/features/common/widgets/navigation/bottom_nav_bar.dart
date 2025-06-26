import 'package:flutter/material.dart';
import 'package:onflix/core/constants/app_constants.dart';
import 'package:onflix/core/extensions/context_extension.dart';
import 'package:onflix/core/utils/responsive_helper.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int, String)? onItemSelected;
  final List<BottomNavItem>? customItems;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? height;
  final bool showLabels;
  final BottomNavType type;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    this.onItemSelected,
    this.customItems,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.height,
    this.showLabels = true,
    this.type = BottomNavType.fixed,
  });

  const BottomNavBar.floating({
    super.key,
    required this.selectedIndex,
    this.onItemSelected,
    this.customItems,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.height,
    this.showLabels = true,
  }) : type = BottomNavType.floating;

  @override
  Widget build(BuildContext context) {
    final items = customItems ?? _getDefaultItems();
    final navHeight = height ??
        ResponsiveHelper.responsive(
          context,
          mobile: 80.0,
          tablet: 90.0,
          desktop: 100.0,
        );

    if (type == BottomNavType.floating) {
      return _buildFloatingNav(context, items, navHeight!);
    }

    return _buildFixedNav(context, items, navHeight!);
  }

  Widget _buildFixedNav(
      BuildContext context, List<BottomNavItem> items, double navHeight) {
    return Container(
      height: navHeight,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == selectedIndex;

            return Expanded(
              child: _buildNavItem(
                context,
                item,
                isSelected,
                () => onItemSelected?.call(index, item.label ?? ''),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFloatingNav(
      BuildContext context, List<BottomNavItem> items, double navHeight) {
    return Container(
      margin: EdgeInsets.all(ResponsiveHelper.getScaledPadding(context, 16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.extraLargeRadius),
        child: Container(
          height: navHeight - 32,
          decoration: BoxDecoration(
            color: backgroundColor ?? context.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == selectedIndex;

              return Expanded(
                child: _buildNavItem(
                  context,
                  item,
                  isSelected,
                  () => onItemSelected?.call(index, item.label ?? ''),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    BottomNavItem item,
    bool isSelected,
    VoidCallback? onTap,
  ) {
    final primaryColor = selectedItemColor ?? context.colorScheme.primary;
    final secondaryColor =
        unselectedItemColor ?? context.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.getScaledPadding(context, 8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: AppConstants.shortAnimation,
                    padding: EdgeInsets.all(
                      ResponsiveHelper.getScaledPadding(context, 8),
                    ),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                AppConstants.defaultRadius),
                          )
                        : null,
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: ResponsiveHelper.getScaledIconSize(context, 24),
                      color: isSelected ? primaryColor : secondaryColor,
                    ),
                  ),

                  // Badge
                  if (item.badgeCount != null && item.badgeCount! > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              ResponsiveHelper.getScaledPadding(context, 6),
                          vertical:
                              ResponsiveHelper.getScaledPadding(context, 2),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
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
                            fontSize:
                                ResponsiveHelper.getScaledFontSize(context, 10),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  // Dot indicator
                  if (item.showDot == true)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: ResponsiveHelper.getScaledIconSize(context, 8),
                        height: ResponsiveHelper.getScaledIconSize(context, 8),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),

              // Label
              if (showLabels && item.label != null) ...[
                SizedBox(height: ResponsiveHelper.getScaledPadding(context, 4)),
                AnimatedDefaultTextStyle(
                  duration: AppConstants.shortAnimation,
                  style: context.textTheme.bodySmall!.copyWith(
                    color: isSelected ? primaryColor : secondaryColor,
                    fontSize: ResponsiveHelper.getScaledFontSize(context, 11),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  child: Text(
                    item.label!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<BottomNavItem> _getDefaultItems() {
    return [
      BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      BottomNavItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
        label: 'Browse',
      ),
      BottomNavItem(
        icon: Icons.search_outlined,
        activeIcon: Icons.search,
        label: 'Search',
      ),
      BottomNavItem(
        icon: Icons.bookmark_outline,
        activeIcon: Icons.bookmark,
        label: 'Watchlist',
      ),
      BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
      ),
    ];
  }
}

class AnimatedBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int)? onItemSelected;
  final List<BottomNavItem> items;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? height;
  final bool showLabels;
  final AnimationType animationType;

  const AnimatedBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.items,
    this.onItemSelected,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.height,
    this.showLabels = true,
    this.animationType = AnimationType.slide,
  });

  @override
  State<AnimatedBottomNavBar> createState() => _AnimatedBottomNavBarState();
}

class _AnimatedBottomNavBarState extends State<AnimatedBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _slideController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navHeight = widget.height ??
        ResponsiveHelper.responsive(
          context,
          mobile: 80.0,
          tablet: 90.0,
          desktop: 100.0,
        );

    return Container(
      height: navHeight,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? context.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Sliding indicator
            if (widget.animationType == AnimationType.slide)
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: (MediaQuery.of(context).size.width /
                            widget.items.length) *
                        widget.selectedIndex,
                    top: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width /
                          widget.items.length,
                      height: 3,
                      color: widget.selectedItemColor ??
                          context.colorScheme.primary,
                    ),
                  );
                },
              ),

            // Navigation items
            Row(
              children: widget.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == widget.selectedIndex;

                return Expanded(
                  child: _buildAnimatedNavItem(
                    context,
                    item,
                    isSelected,
                    () => widget.onItemSelected?.call(index),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedNavItem(
    BuildContext context,
    BottomNavItem item,
    bool isSelected,
    VoidCallback? onTap,
  ) {
    final primaryColor =
        widget.selectedItemColor ?? context.colorScheme.primary;
    final secondaryColor =
        widget.unselectedItemColor ?? context.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppConstants.mediumAnimation,
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.getScaledPadding(context, 12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon
              AnimatedScale(
                duration: AppConstants.mediumAnimation,
                scale: isSelected ? 1.1 : 1.0,
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: ResponsiveHelper.getScaledIconSize(context, 24),
                  color: isSelected ? primaryColor : secondaryColor,
                ),
              ),

              // Animated label
              if (widget.showLabels && item.label != null) ...[
                SizedBox(height: ResponsiveHelper.getScaledPadding(context, 4)),
                AnimatedOpacity(
                  duration: AppConstants.mediumAnimation,
                  opacity: isSelected ? 1.0 : 0.7,
                  child: Text(
                    item.label!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: isSelected ? primaryColor : secondaryColor,
                      fontSize: ResponsiveHelper.getScaledFontSize(context, 11),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int)? onItemSelected;
  final List<CustomNavItem> items;
  final Color? backgroundColor;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.items,
    this.onItemSelected,
    this.backgroundColor,
    this.height,
    this.padding,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final navHeight = height ??
        ResponsiveHelper.responsive(
          context,
          mobile: 80.0,
          tablet: 90.0,
          desktop: 100.0,
        );

    return Container(
      height: navHeight,
      margin: padding ??
          EdgeInsets.all(ResponsiveHelper.getScaledPadding(context, 16)),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorScheme.surface,
        borderRadius: borderRadius ??
            BorderRadius.circular(AppConstants.extraLargeRadius),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
      ),
      child: Row(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == selectedIndex;

          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onItemSelected?.call(index),
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveHelper.getScaledPadding(context, 12),
                  ),
                  child: item.builder(context, isSelected),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String? label;
  final int? badgeCount;
  final bool? showDot;

  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    this.label,
    this.badgeCount,
    this.showDot,
  });
}

class CustomNavItem {
  final Widget Function(BuildContext context, bool isSelected) builder;

  const CustomNavItem({
    required this.builder,
  });
}

enum BottomNavType {
  fixed,
  floating,
}

enum AnimationType {
  slide,
  scale,
  fade,
}
