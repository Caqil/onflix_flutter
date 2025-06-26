import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'core/config/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'features/common/providers/theme_provider.dart';

class OnflixApp extends ConsumerWidget {
  const OnflixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return ShadApp.router(
      title: 'Onflix - Stream Unlimited',
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => ResponsiveWrapper.builder(
        ClampingScrollWrapper.builder(context, child!),
        maxWidth: 1920,
        minWidth: 320,
        defaultScale: true,
        breakpoints: [
          const ResponsiveBreakpoint.resize(320, name: MOBILE),
          const ResponsiveBreakpoint.autoScale(600, name: TABLET),
          const ResponsiveBreakpoint.resize(1200, name: DESKTOP),
          const ResponsiveBreakpoint.autoScale(1920, name: '4K'),
        ],
      ),
    );
  }
}

