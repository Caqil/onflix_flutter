import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onflix/core/constants/app_constants.dart';
import 'package:onflix/core/extensions/context_extension.dart';
import 'package:onflix/core/utils/responsive_helper.dart';

import '../navigation/app_bar_widget.dart';
import '../navigation/sidebar_navigation.dart';


class DesktopLayout extends ConsumerWidget {
  final Widget child;
  final int? selectedIndex;
  final Function(int,String)? onNavigationItemSelected;
  final bool showSidebar;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const DesktopLayout({
    super.key,
    required this.child,
    this.selectedIndex,
    this.onNavigationItemSelected,
    this.showSidebar = true,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarWidth = ResponsiveHelper.getSidebarWidth(context);
    final navigationHeight = ResponsiveHelper.getNavigationHeight(context);
    final contentPadding = ResponsiveHelper.getScaledPadding(
      context,
      AppConstants.defaultPadding,
    );
    final maxContentWidth = ResponsiveHelper.getMaxContentWidth(context);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Row(
        children: [
          // Sidebar (if enabled)
          if (showSidebar)
            SidebarNavigation(
              width: sidebarWidth,
              height: context.screenHeight,
              selectedIndex: selectedIndex ?? 0,
              onItemSelected: onNavigationItemSelected,
            ),

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
                            padding: EdgeInsets.all(contentPadding),
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

class DesktopDashboardLayout extends ConsumerWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool extendBodyBehindAppBar;

  const DesktopDashboardLayout({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.drawer,
    this.endDrawer,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationHeight = ResponsiveHelper.getNavigationHeight(context);
    final gridSpacing = ResponsiveHelper.getGridSpacing(context);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      drawer: drawer,
      endDrawer: endDrawer,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(navigationHeight),
        child: AppBarWidget(
          height: navigationHeight,
          title: title,
          actions: actions,
          showBackButton: false,
          backgroundColor: context.colorScheme.surface,
          elevation: 2,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: context.colorScheme.background,
        padding: EdgeInsets.all(gridSpacing),
        child: child,
      ),
    );
  }
}

class DesktopContentLayout extends ConsumerWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? header;
  final Widget? footer;
  final bool centerContent;
  final EdgeInsets? padding;

  const DesktopContentLayout({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.actions,
    this.header,
    this.footer,
    this.centerContent = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentPadding = padding ??
        EdgeInsets.all(
          ResponsiveHelper.getScaledPadding(
            context,
            AppConstants.largePadding,
          ),
        );

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Column(
        children: [
          // Header Section
          if (header != null)
            header!
          else if (title != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(
                ResponsiveHelper.getScaledPadding(
                  context,
                  AppConstants.defaultPadding,
                ),
              ),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: context.colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
            ),

          // Main Content
          Expanded(
            child: Container(
              width: double.infinity,
              color: context.colorScheme.background,
              child: centerContent
                  ? Center(
                      child: Padding(
                        padding: contentPadding,
                        child: child,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: contentPadding,
                        child: child,
                      ),
                    ),
            ),
          ),

          // Footer Section
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class DesktopSplitLayout extends ConsumerWidget {
  final Widget leftPanel;
  final Widget rightPanel;
  final double leftPanelWidth;
  final bool resizable;
  final Color? dividerColor;
  final double? dividerThickness;

  const DesktopSplitLayout({
    super.key,
    required this.leftPanel,
    required this.rightPanel,
    this.leftPanelWidth = 400,
    this.resizable = false,
    this.dividerColor,
    this.dividerThickness,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thickness = dividerThickness ?? 1;
    final color = dividerColor ?? context.colorScheme.outline.withOpacity(0.2);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Row(
        children: [
          // Left Panel
          Container(
            width: leftPanelWidth,
            height: double.infinity,
            color: context.colorScheme.surface,
            child: leftPanel,
          ),

          // Divider
          Container(
            width: thickness,
            height: double.infinity,
            color: color,
          ),

          // Right Panel
          Expanded(
            child: Container(
              color: context.colorScheme.background,
              child: rightPanel,
            ),
          ),
        ],
      ),
    );
  }
}
