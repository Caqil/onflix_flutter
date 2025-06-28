import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onflix/core/extensions/context_extension.dart';
import 'package:onflix/core/extensions/widget_extension.dart';
import 'package:onflix/core/utils/responsive_helper.dart';
import 'package:onflix/features/admin/presentation/providers/analytics_provider.dart';
import 'package:onflix/features/admin/presentation/providers/admin_auth_provider.dart';
import 'package:onflix/features/common/widgets/layouts/app_layout.dart';
import 'package:onflix/features/common/widgets/cards/info_card.dart';
import 'package:onflix/features/common/widgets/buttons/custom_button.dart';
import 'package:onflix/routes/route_names.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Admin dashboard page that provides an overview of key metrics and quick access to admin features
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Refresh dashboard data on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardStatsProvider.notifier).refreshDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);

    if (!isAuthenticated) {
      return const AdminLoginRedirect();
    }

    return ResponsiveHelper.buildResponsive(
      context,
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(context),
            const SizedBox(height: 24),
            _buildMetricsGrid(context, crossAxisCount: 2),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildRecentActivity(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(context),
            const SizedBox(height: 32),
            _buildMetricsGrid(context, crossAxisCount: 3),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildQuickActions(context),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: _buildRecentActivity(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  _buildMetricsGrid(context, crossAxisCount: 4),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildQuickActions(context),
                            const SizedBox(height: 24),
                            _buildSystemStatus(context),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: _buildRecentActivity(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Admin Dashboard',
        style: context.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        _buildUserMenu(context),
        const SizedBox(width: 16),
      ],
      elevation: 0,
      backgroundColor: context.colorScheme.surface,
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: context.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(context),
          Expanded(
            child: _buildSidebarMenu(context),
          ),
          _buildSidebarFooter(context),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LucideIcons.shield,
              color: context.colorScheme.onPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Admin Panel',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarMenu(BuildContext context) {
    final menuItems = [
      const _SidebarItem(
        icon: LucideIcons.layoutDashboard,
        label: 'Dashboard',
        route: RouteNames.admin,
        isActive: true,
      ),
      const _SidebarItem(
        icon: LucideIcons.users,
        label: 'User Management',
        route: '${RouteNames.admin}/users',
      ),
      const _SidebarItem(
        icon: LucideIcons.fileText,
        label: 'Content Management',
        route: '${RouteNames.admin}/content',
      ),
      const _SidebarItem(
        icon: LucideIcons.chartBarStacked,
        label: 'Analytics',
        route: '${RouteNames.admin}/analytics',
      ),
      const _SidebarItem(
        icon: LucideIcons.creditCard,
        label: 'Subscriptions',
        route: '${RouteNames.admin}/subscriptions',
      ),
      const _SidebarItem(
        icon: LucideIcons.chartPie,
        label: 'Reports',
        route: '${RouteNames.admin}/reports',
      ),
      const _SidebarItem(
        icon: LucideIcons.settings,
        label: 'Settings',
        route: '${RouteNames.admin}/settings',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildSidebarMenuItem(context, item);
      },
    );
  }

  Widget _buildSidebarMenuItem(BuildContext context, _SidebarItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ShadButton.ghost(
        onPressed: () => context.go(item.route),
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 18,
                color: item.isActive
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: item.isActive
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight:
                      item.isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ShadButton.ghost(
            onPressed: () => _showLogoutDialog(context),
            width: double.infinity,
            child: Row(
              children: [
                Icon(
                  LucideIcons.logOut,
                  size: 18,
                  color: context.colorScheme.error,
                ),
                const SizedBox(width: 12),
                Text(
                  'Logout',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: context.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Monitor and manage your Onflix platform',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        _buildUserMenu(context),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final adminUser = ref.watch(currentAdminUserProvider);

    return ShadCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                LucideIcons.user,
                color: context.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  adminUser.when(
                    data: (user) => Text(
                      user?.email ?? 'Admin User',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    loading: () => Text(
                      'Loading...',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    error: (_, __) => Text(
                      'Admin User',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ShadButton(
              onPressed: () => ref.refresh(dashboardStatsProvider),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.refreshCw, size: 16),
                  SizedBox(width: 8),
                  Text('Refresh'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context,
      {required int crossAxisCount}) {
    final dashboardStats = ref.watch(dashboardStatsProvider);

    return dashboardStats.when(
      data: (stats) => _buildMetricsGridContent(context, stats, crossAxisCount),
      loading: () => _buildMetricsGridLoading(context, crossAxisCount),
      error: (error, _) => _buildErrorCard(context, error.toString()),
    );
  }

  Widget _buildMetricsGridContent(
    BuildContext context,
    Map<String, dynamic>? stats,
    int crossAxisCount,
  ) {
    final metrics = [
      _MetricCard(
        title: 'Total Users',
        value: '${stats?['total_users'] ?? 0}',
        icon: LucideIcons.users,
        trend: stats?['user_growth']?.toString(),
        trendIsPositive: (stats?['user_growth'] ?? 0) >= 0,
        color: context.colorScheme.primary,
      ),
      _MetricCard(
        title: 'Active Subscriptions',
        value: '${stats?['active_subscriptions'] ?? 0}',
        icon: LucideIcons.creditCard,
        trend: stats?['subscription_growth']?.toString(),
        trendIsPositive: (stats?['subscription_growth'] ?? 0) >= 0,
        color: Colors.green,
      ),
      _MetricCard(
        title: 'Total Content',
        value: '${stats?['total_content'] ?? 0}',
        icon: LucideIcons.fileVideo,
        trend: stats?['content_growth']?.toString(),
        trendIsPositive: (stats?['content_growth'] ?? 0) >= 0,
        color: Colors.blue,
      ),
      _MetricCard(
        title: 'Revenue',
        value: '\$${stats?['total_revenue'] ?? '0'}',
        icon: LucideIcons.dollarSign,
        trend: stats?['revenue_growth']?.toString(),
        trendIsPositive: (stats?['revenue_growth'] ?? 0) >= 0,
        color: Colors.orange,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: ResponsiveHelper.isMobile(context) ? 1.5 : 2.5,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) =>
          _buildMetricCard(context, metrics[index]),
    );
  }

  Widget _buildMetricsGridLoading(BuildContext context, int crossAxisCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: ResponsiveHelper.isMobile(context) ? 1.5 : 2.5,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => _buildMetricCardSkeleton(context),
    );
  }

  Widget _buildMetricCard(BuildContext context, _MetricCard metric) {
    return ShadCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: metric.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    metric.icon,
                    color: metric.color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                if (metric.trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: metric.trendIsPositive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          metric.trendIsPositive
                              ? LucideIcons.trendingUp
                              : LucideIcons.trendingDown,
                          size: 12,
                          color: metric.trendIsPositive
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${metric.trend}%',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: metric.trendIsPositive
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              metric.value,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              metric.title,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCardSkeleton(BuildContext context) {
    return ShadCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 80,
              height: 32,
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        title: 'Add Content',
        description: 'Upload new movies or shows',
        icon: LucideIcons.plus,
        onTap: () => context.go('${RouteNames.admin}/content'),
      ),
      _QuickAction(
        title: 'Manage Users',
        description: 'View and manage user accounts',
        icon: LucideIcons.userPlus,
        onTap: () => context.go('${RouteNames.admin}/users'),
      ),
      _QuickAction(
        title: 'View Analytics',
        description: 'Check platform performance',
        icon: LucideIcons.chartBar,
        onTap: () => context.go('${RouteNames.admin}/analytics'),
      ),
      _QuickAction(
        title: 'System Settings',
        description: 'Configure platform settings',
        icon: LucideIcons.settings,
        onTap: () => context.go('${RouteNames.admin}/settings'),
      ),
    ];

    return ShadCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...actions.map((action) => _buildQuickActionItem(context, action)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(BuildContext context, _QuickAction action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ShadButton.ghost(
        onPressed: action.onTap,
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  action.icon,
                  color: context.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      action.description,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: context.colorScheme.onSurface.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    // Mock data - replace with actual data from provider
    final activities = [
      const _Activity(
        title: 'New user registered',
        description: 'john.doe@example.com joined the platform',
        time: '5 minutes ago',
        icon: LucideIcons.userPlus,
        type: _ActivityType.user,
      ),
      const _Activity(
        title: 'Content uploaded',
        description: 'The Matrix Resurrections was added',
        time: '2 hours ago',
        icon: LucideIcons.upload,
        type: _ActivityType.content,
      ),
      const _Activity(
        title: 'Payment processed',
        description: 'Premium subscription renewed',
        time: '4 hours ago',
        icon: LucideIcons.creditCard,
        type: _ActivityType.payment,
      ),
      const _Activity(
        title: 'Content report',
        description: 'User reported inappropriate content',
        time: '6 hours ago',
        icon: LucideIcons.flag,
        type: _ActivityType.report,
      ),
    ];

    return ShadCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent Activity',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ShadButton.ghost(
                  onPressed: () {
                    // Navigate to full activity log
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...activities
                .map((activity) => _buildActivityItem(context, activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, _Activity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getActivityColor(activity.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              activity.icon,
              color: _getActivityColor(activity.type),
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity.time,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus(BuildContext context) {
    return ShadCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Status',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusItem(context, 'API Services', true),
            _buildStatusItem(context, 'Database', true),
            _buildStatusItem(context, 'CDN', true),
            _buildStatusItem(context, 'Payment Gateway', false),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, String service, bool isOnline) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            service,
            style: context.textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: context.textTheme.bodySmall?.copyWith(
              color: isOnline ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context) {
    return ShadDropdownMenu<String>(
      children: [
        ShadDropdownMenuItem<String>(
          value: 'profile',
          child: const Row(
            children: [
              Icon(LucideIcons.user, size: 16),
              SizedBox(width: 8),
              Text('Profile'),
            ],
          ),
        ),
        ShadDropdownMenuItem<String>(
          value: 'settings',
          child: const Row(
            children: [
              Icon(LucideIcons.settings, size: 16),
              SizedBox(width: 8),
              Text('Settings'),
            ],
          ),
        ),
        const ShadDropdownMenuSeparator(),
        ShadDropdownMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(LucideIcons.logOut,
                  size: 16, color: context.colorScheme.error),
              const SizedBox(width: 8),
              Text('Logout',
                  style: TextStyle(color: context.colorScheme.error)),
            ],
          ),
        ),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          LucideIcons.user,
          color: context.colorScheme.primary,
          size: 20,
        ),
      ),
      onChanged: (value) {
        switch (value) {
          case 'profile':
            // Handle profile
            break;
          case 'settings':
            context.go('${RouteNames.admin}/settings');
            break;
          case 'logout':
            _showLogoutDialog(context);
            break;
        }
      },
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return ShadCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              LucideIcons.alertCircle,
              color: context.colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading dashboard',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ShadButton(
              onPressed: () => ref.refresh(dashboardStatsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Logout'),
        description:
            const Text('Are you sure you want to logout from the admin panel?'),
        actions: [
          ShadButton.ghost(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ShadButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(adminAuthProvider.notifier).logout();
              context.go(RouteNames.adminLogin);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(_ActivityType type) {
    switch (type) {
      case _ActivityType.user:
        return Colors.blue;
      case _ActivityType.content:
        return Colors.green;
      case _ActivityType.payment:
        return Colors.orange;
      case _ActivityType.report:
        return Colors.red;
    }
  }
}

// Helper classes
class _SidebarItem {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    this.isActive = false,
  });
}

class _MetricCard {
  final String title;
  final String value;
  final IconData icon;
  final String? trend;
  final bool trendIsPositive;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.trend,
    this.trendIsPositive = true,
    required this.color,
  });
}

class _QuickAction {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });
}

class _Activity {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final _ActivityType type;

  const _Activity({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.type,
  });
}

enum _ActivityType { user, content, payment, report }

// Redirect widget for non-authenticated users
class AdminLoginRedirect extends StatelessWidget {
  const AdminLoginRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(RouteNames.adminLogin);
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.shield,
              size: 64,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Redirecting to login...',
              style: context.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
