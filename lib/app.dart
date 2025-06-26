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
      builder: (context, child) => ResponsiveBreakpoints.builder(
        breakpoints: [
          const Breakpoint(start: 0, end: 599, name: MOBILE),
          const Breakpoint(start: 600, end: 1199, name: TABLET),
          const Breakpoint(start: 1200, end: 1919, name: DESKTOP),
          const Breakpoint(start: 1920, end: double.infinity, name: '4K'),
        ],
        child: child!,
      ),
    );
  }
}
