import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onflix/core/constants/asset_paths.dart';
import 'package:onflix/core/extensions/context_extension.dart';
import 'package:onflix/core/utils/responsive_helper.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool showMenuButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final double? height;
  final PreferredSizeWidget? bottom;
  final bool showLogo;
  final bool automaticallyImplyLeading;
  final SystemUiOverlayStyle? systemOverlayStyle;

  const AppBarWidget({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.showMenuButton = false,
    this.onBackPressed,
    this.onMenuPressed,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = false,
    this.height,
    this.bottom,
    this.showLogo = false,
    this.automaticallyImplyLeading = true,
    this.systemOverlayStyle,
  });

  const AppBarWidget.main({
    super.key,
    this.title = 'Onflix',
    this.actions,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.bottom,
    this.systemOverlayStyle,
  })  : titleWidget = null,
        leading = null,
        showBackButton = false,
        showMenuButton = true,
        onBackPressed = null,
        onMenuPressed = null,
        centerTitle = false,
        showLogo = true,
        automaticallyImplyLeading = false;

  const AppBarWidget.search({
    super.key,
    this.title = 'Search',
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.systemOverlayStyle,
  })  : titleWidget = null,
        leading = null,
        showMenuButton = false,
        onMenuPressed = null,
        centerTitle = false,
        showLogo = false,
        automaticallyImplyLeading = false,
        bottom = null;

  const AppBarWidget.profile({
    super.key,
    this.title = 'Profile',
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.systemOverlayStyle,
  })  : titleWidget = null,
        leading = null,
        showMenuButton = false,
        onMenuPressed = null,
        centerTitle = true,
        showLogo = false,
        automaticallyImplyLeading = false,
        bottom = null;

  @override
  Widget build(BuildContext context) {
    final appBarHeight =
        height ?? ResponsiveHelper.getNavigationHeight(context);

    return AppBar(
      title: _buildTitle(context),
      titleSpacing: ResponsiveHelper.getScaledPadding(context, 16),
      leading: _buildLeading(context),
      actions: _buildActions(context),
      elevation: elevation ?? 1,
      backgroundColor: backgroundColor ?? context.colorScheme.surface,
      foregroundColor: foregroundColor ?? context.colorScheme.onSurface,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      systemOverlayStyle:
          systemOverlayStyle ?? _getSystemUiOverlayStyle(context),
      toolbarHeight: appBarHeight,
      bottom: bottom,
      scrolledUnderElevation: elevation ?? 1,
    );
  }

  Widget? _buildTitle(BuildContext context) {
    if (titleWidget != null) {
      return titleWidget;
    }

    if (showLogo) {
      return _buildLogoTitle(context);
    }

    if (title != null) {
      return Text(
        title!,
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: ResponsiveHelper.getScaledFontSize(context, 20),
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    return null;
  }

  Widget _buildLogoTitle(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        SizedBox(width: ResponsiveHelper.getScaledPadding(context, 8)),
        Text(
          'Onflix',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.getScaledFontSize(context, 24),
            color: context.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) {
      return leading;
    }

    if (showBackButton) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back,
          size: ResponsiveHelper.getScaledIconSize(context, 24),
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    if (showMenuButton) {
      return IconButton(
        icon: Icon(
          Icons.menu,
          size: ResponsiveHelper.getScaledIconSize(context, 24),
        ),
        onPressed: onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
        tooltip: 'Menu',
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    final actionWidgets = <Widget>[];

    // Add custom actions if provided
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    // Add default actions based on app bar type
    if (showLogo) {
      actionWidgets.addAll(_buildMainActions(context));
    }

    return actionWidgets.isNotEmpty ? actionWidgets : null;
  }

  List<Widget> _buildMainActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(
          Icons.search,
          size: ResponsiveHelper.getScaledIconSize(context, 24),
        ),
        onPressed: () {
          // Navigate to search
        },
        tooltip: 'Search',
      ),
      IconButton(
        icon: Icon(
          Icons.notifications_outlined,
          size: ResponsiveHelper.getScaledIconSize(context, 24),
        ),
        onPressed: () {
          // Navigate to notifications
        },
        tooltip: 'Notifications',
      ),
      PopupMenuButton<String>(
        icon: CircleAvatar(
          radius: ResponsiveHelper.getScaledIconSize(context, 16),
          backgroundColor: context.colorScheme.primary,
          child: Icon(
            Icons.person,
            size: ResponsiveHelper.getScaledIconSize(context, 18),
            color: context.colorScheme.onPrimary,
          ),
        ),
        onSelected: (value) {
          // Handle menu selection
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'profile',
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                'Profile',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getScaledFontSize(context, 14),
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: 'settings',
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: Text(
                'Settings',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getScaledFontSize(context, 14),
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: 'logout',
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: Text(
                'Logout',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getScaledFontSize(context, 14),
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    ];
  }

  SystemUiOverlayStyle _getSystemUiOverlayStyle(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        (height ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
      );
}

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool autofocus;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SearchAppBar({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onBackPressed,
    this.actions,
    this.autofocus = true,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height ?? kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          size: ResponsiveHelper.getScaledIconSize(context, 24),
        ),
        onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      title: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: context.textTheme.bodyLarge?.copyWith(
          fontSize: ResponsiveHelper.getScaledFontSize(context, 16),
        ),
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search movies, shows...',
          hintStyle: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            fontSize: ResponsiveHelper.getScaledFontSize(context, 16),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.getScaledPadding(context, 8),
          ),
        ),
      ),
      actions: [
        if (_controller.text.isNotEmpty)
          IconButton(
            icon: Icon(
              Icons.clear,
              size: ResponsiveHelper.getScaledIconSize(context, 20),
            ),
            onPressed: () {
              _controller.clear();
              widget.onChanged?.call('');
            },
          ),
        ...?widget.actions,
      ],
      backgroundColor: widget.backgroundColor ?? context.colorScheme.surface,
      foregroundColor: widget.foregroundColor ?? context.colorScheme.onSurface,
      elevation: 1,
      toolbarHeight:
          widget.height ?? ResponsiveHelper.getNavigationHeight(context),
    );
  }
}

class CollapsibleAppBar extends StatelessWidget {
  final Widget? title;
  final Widget? background;
  final List<Widget>? actions;
  final double expandedHeight;
  final double collapsedHeight;
  final bool pinned;
  final bool floating;
  final bool snap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CollapsibleAppBar({
    super.key,
    this.title,
    this.background,
    this.actions,
    this.expandedHeight = 200.0,
    this.collapsedHeight = kToolbarHeight,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: title,
      actions: actions,
      expandedHeight: ResponsiveHelper.responsive(
        context,
        mobile: expandedHeight * 0.8,
        tablet: expandedHeight,
        desktop: expandedHeight * 1.2,
      ),
      collapsedHeight: collapsedHeight,
      pinned: pinned,
      floating: floating,
      snap: snap,
      backgroundColor: backgroundColor ?? context.colorScheme.surface,
      foregroundColor: foregroundColor ?? context.colorScheme.onSurface,
      flexibleSpace: FlexibleSpaceBar(
        background: background,
        collapseMode: CollapseMode.parallax,
        titlePadding: EdgeInsets.only(
          left: ResponsiveHelper.getScaledPadding(context, 16),
          bottom: ResponsiveHelper.getScaledPadding(context, 16),
        ),
      ),
    );
  }
}

class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Tab> tabs;
  final TabController? controller;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? indicatorColor;
  final double? height;

  const TabAppBar({
    super.key,
    this.title,
    required this.tabs,
    this.controller,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.indicatorColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final appBarHeight =
        height ?? ResponsiveHelper.getNavigationHeight(context);

    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getScaledFontSize(context, 20),
              ),
            )
          : null,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: ResponsiveHelper.getScaledIconSize(context, 24),
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
      backgroundColor: backgroundColor ?? context.colorScheme.surface,
      foregroundColor: foregroundColor ?? context.colorScheme.onSurface,
      elevation: 1,
      toolbarHeight: appBarHeight,
      bottom: TabBar(
        controller: controller,
        tabs: tabs,
        indicatorColor: indicatorColor ?? context.colorScheme.primary,
        labelColor: context.colorScheme.primary,
        unselectedLabelColor: context.colorScheme.onSurfaceVariant,
        labelStyle: TextStyle(
          fontSize: ResponsiveHelper.getScaledFontSize(context, 14),
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: ResponsiveHelper.getScaledFontSize(context, 14),
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        (height ?? kToolbarHeight) + kTextTabBarHeight,
      );
}
