import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onflix/core/constants/app_constants.dart';
import 'package:onflix/core/extensions/context_extension.dart';
import 'package:onflix/core/utils/responsive_helper.dart';

import '../navigation/app_bar_widget.dart';
import '../navigation/bottom_nav_bar.dart';
import '../navigation/drawer_menu.dart';

class TabletLayout extends ConsumerWidget {
  final Widget child;
  final int? selectedIndex;
  final Function(int, String)? onNavigationItemSelected;
  final bool? isSidebarOpen;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onCloseSidebar;
  final Animation<double>? sidebarAnimation;
  final Animation<double>? overlayAnimation;
  final bool showBottomNavigation;
  final bool showDrawer;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const TabletLayout({
    super.key,
    required this.child,
    this.selectedIndex,
    this.onNavigationItemSelected,
    this.isSidebarOpen,
    this.onToggleSidebar,
    this.onCloseSidebar,
    this.sidebarAnimation,
    this.overlayAnimation,
    this.showBottomNavigation = false,
    this.showDrawer = false,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationHeight = ResponsiveHelper.getNavigationHeight(context);
    final contentPadding = ResponsiveHelper.getScaledPadding(
      context,
      AppConstants.defaultPadding,
    );
    final maxContentWidth = ResponsiveHelper.getMaxContentWidth(context);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: context.colorScheme.surface,
      drawer: showDrawer ? const DrawerMenu() : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: showBottomNavigation
          ? BottomNavBar(
              selectedIndex: selectedIndex ?? 0,
              onItemSelected: onNavigationItemSelected,
            )
          : null,
      body: Row(
        children: [
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Navigation Bar
                AppBarWidget(
                  height: navigationHeight,
                  title: title,
                  actions: actions,
                  showBackButton: false,
                  showMenuButton: showDrawer,
                  onMenuPressed: onToggleSidebar,
                  backgroundColor: context.colorScheme.surface,
                  elevation: 1,
                ),

                // Main Content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: context.colorScheme.background,
                    child: SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxContentWidth,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: contentPadding,
                              vertical: contentPadding * 0.75,
                            ),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TabletGridLayout extends ConsumerWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool showSearch;
  final bool showFilter;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const TabletGridLayout({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.showSearch = true,
    this.showFilter = true,
    this.onSearchTap,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationHeight = ResponsiveHelper.getNavigationHeight(context);
    final gridSpacing = ResponsiveHelper.getGridSpacing(context);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Column(
        children: [
          // Top Navigation with Search/Filter
          AppBarWidget(
            height: navigationHeight,
            title: title,
            actions: [
              if (showSearch)
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onSearchTap,
                ),
              if (showFilter)
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onFilterTap,
                ),
              if (actions != null) ...actions!,
            ],
            backgroundColor: context.colorScheme.surface,
            elevation: 1,
          ),

          // Grid Content
          Expanded(
            child: Container(
              width: double.infinity,
              color: context.colorScheme.background,
              padding: EdgeInsets.all(gridSpacing),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class TabletDetailsLayout extends ConsumerWidget {
  final Widget content;
  final Widget? sidebar;
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double sidebarWidth;

  const TabletDetailsLayout({
    super.key,
    required this.content,
    this.sidebar,
    this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.sidebarWidth = 320,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationHeight = ResponsiveHelper.getNavigationHeight(context);
    final contentPadding = ResponsiveHelper.getScaledPadding(
      context,
      AppConstants.defaultPadding,
    );

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Column(
        children: [
          // Top Navigation
          AppBarWidget(
            height: navigationHeight,
            title: title,
            actions: actions,
            showBackButton: showBackButton,
            onBackPressed: onBackPressed,
            backgroundColor: context.colorScheme.surface,
            elevation: 1,
          ),

          // Content Area
          Expanded(
            child: Container(
              color: context.colorScheme.background,
              child: sidebar != null
                  ? Row(
                      children: [
                        // Main Content
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(contentPadding),
                              child: content,
                            ),
                          ),
                        ),

                        // Sidebar
                        Container(
                          width: sidebarWidth,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: context.colorScheme.surface,
                            border: Border(
                              left: BorderSide(
                                color: context.colorScheme.outline
                                    .withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          ),
                          child: sidebar!,
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(contentPadding),
                        child: content,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class TabletModalLayout extends ConsumerWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final double? maxWidth;
  final double? maxHeight;

  const TabletModalLayout({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.showCloseButton = true,
    this.onClose,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modalWidth = maxWidth ?? ResponsiveHelper.getModalWidth(context);
    final modalHeight = maxHeight ?? ResponsiveHelper.getModalHeight(context);
    final contentPadding = ResponsiveHelper.getScaledPadding(
      context,
      AppConstants.defaultPadding,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(
        ResponsiveHelper.getScaledPadding(context, 16),
      ),
      child: Container(
        width: modalWidth,
        height: modalHeight,
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            if (title != null || showCloseButton || actions != null)
              Container(
                padding: EdgeInsets.all(contentPadding),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: context.colorScheme.outline.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    if (actions != null) ...actions!,
                    if (showCloseButton)
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: onClose ?? () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
              ),

            // Content
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(contentPadding),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TabletFormLayout extends ConsumerWidget {
  final Widget form;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? footer;
  final bool centerContent;

  const TabletFormLayout({
    super.key,
    required this.form,
    this.title,
    this.subtitle,
    this.actions,
    this.footer,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentPadding = ResponsiveHelper.getScaledPadding(
      context,
      AppConstants.largePadding,
    );
    final maxContentWidth = ResponsiveHelper.getMaxContentWidth(context) * 0.8;

    return Scaffold(
      backgroundColor: context.colorScheme.background,
      body: SafeArea(
        child: centerContent
            ? Center(
                child: SingleChildScrollView(
                  child: _buildContent(
                    context,
                    contentPadding,
                    maxContentWidth,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(contentPadding),
                  child: _buildContent(
                    context,
                    contentPadding,
                    maxContentWidth,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    double contentPadding,
    double maxContentWidth,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxContentWidth),
      child: Card(
        elevation: AppConstants.mediumElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              if (title != null)
                Column(
                  children: [
                    Text(
                      title!,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle!,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    SizedBox(height: contentPadding),
                  ],
                ),

              // Form Content
              form,

              // Actions
              if (actions != null) ...[
                SizedBox(height: contentPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!
                      .map((action) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: action,
                          ))
                      .toList(),
                ),
              ],

              // Footer
              if (footer != null) ...[
                SizedBox(height: contentPadding),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
