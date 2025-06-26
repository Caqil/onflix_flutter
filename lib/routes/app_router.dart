import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/profile_selection_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/home/presentation/pages/browse_page.dart';
import '../features/home/presentation/pages/search_page.dart';
import '../features/player/presentation/pages/content_details_page.dart';
import '../features/player/presentation/pages/video_player_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/watchlist/presentation/pages/watchlist_page.dart';
import '../features/downloads/presentation/pages/downloads_page.dart';
import '../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../features/admin/presentation/pages/admin_login_page.dart';
import '../features/common/widgets/layouts/app_layout.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'guards/auth_guard.dart';
import 'guards/admin_guard.dart';
import 'route_names.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.home,
    redirect: (context, state) {
      final isLoggedIn = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, __) => false,
      );

      final isLoggingIn =
          state.path == RouteNames.login || state.path == RouteNames.register;

      // Redirect to login if not authenticated
      if (!isLoggedIn && !isLoggingIn) {
        return RouteNames.login;
      }

      // Redirect to home if already logged in and trying to access login
      if (isLoggedIn && isLoggingIn) {
        return RouteNames.home;
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        pageBuilder: (context, state) => ShadPage(
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        pageBuilder: (context, state) => ShadPage(
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.profileSelection,
        name: 'profile-selection',
        pageBuilder: (context, state) => ShadPage(
          child: const ProfileSelectionPage(),
        ),
      ),

      // Main App Shell
      ShellRoute(
        builder: (context, state, child) => AppLayout(child: child),
        routes: [
          // Home Routes
          GoRoute(
            path: RouteNames.home,
            name: 'home',
            pageBuilder: (context, state) => ShadPage(
              child: const HomePage(),
            ),
          ),
          GoRoute(
            path: RouteNames.browse,
            name: 'browse',
            pageBuilder: (context, state) => ShadPage(
              child: BrowsePage(
                category: state.queryParameters['category'],
              ),
            ),
          ),
          GoRoute(
            path: RouteNames.search,
            name: 'search',
            pageBuilder: (context, state) => ShadPage(
              child: SearchPage(
                query: state.queryParameters['q'],
              ),
            ),
          ),

          // Content Routes
          GoRoute(
            path: '${RouteNames.content}/:id',
            name: 'content-details',
            pageBuilder: (context, state) => ShadPage(
              child: ContentDetailsPage(
                contentId: state.pathParameters['id']!,
              ),
            ),
          ),
          GoRoute(
            path: '${RouteNames.player}/:id',
            name: 'player',
            pageBuilder: (context, state) => ShadPage(
              child: VideoPlayerPage(
                contentId: state.pathParameters['id']!,
                episodeId: state.queryParameters['episode'],
              ),
            ),
          ),

          // User Routes
          GoRoute(
            path: RouteNames.profile,
            name: 'profile',
            pageBuilder: (context, state) => ShadPage(
              child: const ProfilePage(),
            ),
          ),
          GoRoute(
            path: RouteNames.watchlist,
            name: 'watchlist',
            pageBuilder: (context, state) => ShadPage(
              child: const WatchlistPage(),
            ),
          ),
          GoRoute(
            path: RouteNames.downloads,
            name: 'downloads',
            pageBuilder: (context, state) => ShadPage(
              child: const DownloadsPage(),
            ),
          ),
        ],
      ),

      // Admin Routes
      GoRoute(
        path: RouteNames.adminLogin,
        name: 'admin-login',
        pageBuilder: (context, state) => ShadPage(
          child: const AdminLoginPage(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminGuard(child: child),
        routes: [
          GoRoute(
            path: RouteNames.admin,
            name: 'admin',
            pageBuilder: (context, state) => ShadPage(
              child: const AdminDashboardPage(),
            ),
            routes: [
              GoRoute(
                path: 'content',
                name: 'admin-content',
                pageBuilder: (context, state) => ShadPage(
                  child:
                      const AdminDashboardPage(), // Replace with ContentManagementPage
                ),
              ),
              GoRoute(
                path: 'users',
                name: 'admin-users',
                pageBuilder: (context, state) => ShadPage(
                  child:
                      const AdminDashboardPage(), // Replace with UserManagementPage
                ),
              ),
              GoRoute(
                path: 'analytics',
                name: 'admin-analytics',
                pageBuilder: (context, state) => ShadPage(
                  child:
                      const AdminDashboardPage(), // Replace with AnalyticsPage
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorPageBuilder: (context, state) => ShadPage(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShadImage.square(
              LucideIcons.alertTriangle,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: ShadTheme.of(context).textTheme.h3,
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.path}" could not be found.',
              style: ShadTheme.of(context).textTheme.muted,
            ),
            const SizedBox(height: 16),
            ShadButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
