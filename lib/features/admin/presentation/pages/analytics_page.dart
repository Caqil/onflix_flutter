import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onflix/core/extensions/context_extension.dart';
import 'package:onflix/core/extensions/widget_extension.dart';
import 'package:onflix/core/utils/responsive_helper.dart';
import 'package:onflix/features/admin/presentation/providers/analytics_provider.dart';
import 'package:onflix/features/admin/presentation/providers/admin_auth_provider.dart';
import 'package:onflix/features/common/widgets/cards/info_card.dart';
import 'package:onflix/features/common/widgets/buttons/custom_button.dart';
import 'package:onflix/routes/route_names.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:fl_chart/fl_chart.dart';

/// Analytics page displaying comprehensive platform metrics and performance data
class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;
  String _selectedGranularity = 'daily';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAnalytics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);
    
    if (!isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(RouteNames.adminLogin);
      });
      return const SizedBox();
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildFilterSection(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context),
                _buildUserAnalyticsTab(context),
                _buildContentAnalyticsTab(context),
                _buildRevenueAnalyticsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(context) {
    return AppBar(
      title: Text(
        'Analytics Dashboard',
        style: context.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        ShadButton.ghost(
          onPressed: _exportData,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.download, size: 16),
              const SizedBox(width: 8),
              Text('Export'),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ShadButton(
          onPressed: _refreshAnalytics,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.refreshCw, size: 16),
              const SizedBox(width: 8),
              Text('Refresh'),
            ],
          ),
        ),
        const SizedBox(width: 16),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Users'),
          Tab(text: 'Content'),
          Tab(text: 'Revenue'),
        ],
      ),
      elevation: 0,
      backgroundColor: context.colorScheme.surface,
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: ResponsiveHelper.buildResponsive(
        context,
        mobile: _buildMobileFilters(context),
        tablet: _buildTabletFilters(context),
        desktop: _buildDesktopFilters(context),
      ),
    );
  }

  Widget _buildMobileFilters(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDateRangePicker(context)),
            const SizedBox(width: 12),
            _buildGranularityDropdown(context),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildDateRangePicker(context)),
        const SizedBox(width: 16),
        _buildGranularityDropdown(context),
        const SizedBox(width: 16),
        _buildQuickFilters(context),
      ],
    );
  }

  Widget _buildDesktopFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildDateRangePicker(context)),
        const SizedBox(width: 16),
        _buildGranularityDropdown(context),
        const SizedBox(width: 16),
        _buildQuickFilters(context),
        const Spacer(),
        _buildMetricsToggle(context),
      ],
    );
  }

  Widget _buildDateRangePicker(BuildContext context) {
    return ShadButton.outline(
      onPressed: _showDateRangePicker,
      width: double.infinity,
      child: Row(
        children: [
          Icon(LucideIcons.calendar, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _selectedDateRange != null
                  ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                  : 'Select Date Range',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGranularityDropdown(BuildContext context) {
    return ShadDropdownMenu<String>(
      value: _selectedGranularity,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedGranularity = value;
          });
          _refreshAnalytics();
        }
      },
      children: const [
        ShadDropdownMenuItem(value: 'hourly', child: Text('Hourly')),
        ShadDropdownMenuItem(value: 'daily', child: Text('Daily')),
        ShadDropdownMenuItem(value: 'weekly', child: Text('Weekly')),
        ShadDropdownMenuItem(value: 'monthly', child: Text('Monthly')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.outline.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selectedGranularity.toUpperCase()),
            const SizedBox(width: 8),
            Icon(LucideIcons.chevronDown, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilters(BuildContext context) {
    final quickFilters = ['7d', '30d', '90d', '1y'];
    
    return Row(
      children: quickFilters.map((filter) {
        final isSelected = _isQuickFilterSelected(filter);
        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: ShadButton.outline(
            onPressed: () => _applyQuickFilter(filter),
            variant: isSelected ? ShadButtonVariant.default : ShadButtonVariant.outline,
            size: ShadButtonSize.sm,
            child: Text(filter),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricsToggle(BuildContext context) {
    return Row(
      children: [
        Text(
          'Real-time',
          style: context.textTheme.bodySmall,
        ),
        const SizedBox(width: 8),
        ShadSwitch(
          value: false, // Replace with actual real-time toggle state
          onChanged: (value) {
            // Handle real-time toggle
          },
        ),
      ],
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKPICards(context),
          const SizedBox(height: 24),
          _buildChartsSection(context),
          const SizedBox(height: 24),
          _buildTopContentSection(context),
        ],
      ),
    );
  }

  Widget _buildKPICards(BuildContext context) {
    final dashboardStats = ref.watch(dashboardStatsProvider);
    
    return dashboardStats.when(
      data: (stats) => _buildKPICardsContent(context, stats),
      loading: () => _buildKPICardsLoading(context),
      error: (error, _) => _buildErrorCard(context, error.toString()),
    );
  }

  Widget _buildKPICardsContent(BuildContext context, Map<String, dynamic>? stats) {
    final kpis = [
      _KPICard(
        title: 'Total Views',
        value: '${stats?['total_views'] ?? 0}',
        change: '+12.5%',
        isPositive: true,
        icon: LucideIcons.eye,
        color: Colors.blue,
      ),
      _KPICard(
        title: 'Active Users',
        value: '${stats?['active_users'] ?? 0}',
        change: '+8.2%',
        isPositive: true,
        icon: LucideIcons.users,
        color: Colors.green,
      ),
      _KPICard(
        title: 'Avg. Session',
        value: '${stats?['avg_session_duration'] ?? '0m'}',
        change: '+5.1%',
        isPositive: true,
        icon: LucideIcons.clock,
        color: Colors.orange,
      ),
      _KPICard(
        title: 'Conversion Rate',
        value: '${stats?['conversion_rate'] ?? '0'}%',
        change: '-2.3%',
        isPositive: false,
        icon: LucideIcons.target,
        color: Colors.purple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: ResponsiveHelper.isMobile(context) ? 1.2 : 1.5,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) => _buildKPICard(context, kpis[index]),
    );
  }

  Widget _buildKPICardsLoading(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: ResponsiveHelper.isMobile(context) ? 1.2 : 1.5,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => _buildKPICardSkeleton(context),
    );
  }

  Widget _buildKPICard(BuildContext context, _KPICard kpi) {
    return ShadCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: kpi.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    kpi.icon,
                    color: kpi.color,
                    size: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: kpi.isPositive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        kpi.isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                        size: 10,
                        color: kpi.isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        kpi.change,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: kpi.isPositive ? Colors.green : Colors.red,
                          fontSize: 10,
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
              kpi.value,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              kpi.title,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICardSkeleton(BuildContext context) {
    return ShadCard(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 16,
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 60,
              height: 24,
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 12,
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

  Widget _buildChartsSection(BuildContext context) {
    return Column(
      children: [
        if (ResponsiveHelper.isDesktop(context))
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildMainChart(context)),
              const SizedBox(width: 16),
              Expanded(child: _buildPieChart(context)),
            ],
          )
        else ...[
          _buildMainChart(context),
          const SizedBox(height: 16),
          _buildPieChart(context),
        ],
      ],
    );
  }

  Widget _buildMainChart(BuildContext context) {
    return ShadCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Views Over Time',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ShadDropdownMenu<String>(
                  children: const [
                    ShadDropdownMenuItem(value: 'views', child: Text('Views')),
                    ShadDropdownMenuItem(value: 'users', child: Text('Users')),
                    ShadDropdownMenuItem(value: 'revenue', child: Text('Revenue')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.colorScheme.outline.withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Views', style: context.textTheme.bodySmall),
                        const SizedBox(width: 4),
                        Icon(LucideIcons.chevronDown, size: 12),
                      ],
                    ),
                  ),
                  onChanged: (value) {
                    // Handle chart metric change
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: context.colorScheme.outline.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          // Format dates for bottom axis
                          return Text(
                            '${value.toInt()}',
                            style: context.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}K',
                            style: context.textTheme.bodySmall,
                          );
                        },
                        reservedSize: 42,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 11,
                  minY: 0,
                  maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateSampleData(),
                      isCurved: true,
                      color: context.colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: context.colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    return ShadCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Distribution',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _generatePieData(context),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildPieChartLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartLegend(BuildContext context) {
    final legendItems = [
      _LegendItem(color: Colors.blue, label: 'Premium', value: '65%'),
      _LegendItem(color: Colors.green, label: 'Free', value: '30%'),
      _LegendItem(color: Colors.orange, label: 'Trial', value: '5%'),
    ];

    return Column(
      children: legendItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: context.textTheme.bodySmall,
                ),
              ),
              Text(
                item.value,
                style: context.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopContentSection(BuildContext context) {
    return ShadCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Top Performing Content',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ShadButton.ghost(
                  onPressed: () {
                    // Navigate to full content analytics
                  },
                  child: Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContentTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContentTable(BuildContext context) {
    final mockContent = [
      _ContentItem(
        title: 'The Matrix Resurrections',
        type: 'Movie',
        views: '125K',
        engagement: '8.5',
        revenue: '\$12.5K',
      ),
      _ContentItem(
        title: 'Stranger Things S4',
        type: 'Series',
        views: '98K',
        engagement: '9.2',
        revenue: '\$8.9K',
      ),
      _ContentItem(
        title: 'Top Gun: Maverick',
        type: 'Movie',
        views: '87K',
        engagement: '8.8',
        revenue: '\$7.2K',
      ),
    ];

    return Column(
      children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('Content', style: context.textTheme.labelMedium)),
              Expanded(child: Text('Type', style: context.textTheme.labelMedium)),
              Expanded(child: Text('Views', style: context.textTheme.labelMedium)),
              Expanded(child: Text('Score', style: context.textTheme.labelMedium)),
              Expanded(child: Text('Revenue', style: context.textTheme.labelMedium)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Table rows
        ...mockContent.map((item) => _buildContentRow(context, item)),
      ],
    );
  }

  Widget _buildContentRow(BuildContext context, _ContentItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.title,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: item.type == 'Movie' 
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.type,
                style: context.textTheme.bodySmall?.copyWith(
                  color: item.type == 'Movie' ? Colors.blue : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.views,
              style: context.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(LucideIcons.star, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  item.engagement,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              item.revenue,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAnalyticsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUserMetricsGrid(context),
          const SizedBox(height: 24),
          _buildUserDemographics(context),
          const SizedBox(height: 24),
          _buildUserBehaviorChart(context),
        ],
      ),
    );
  }

  Widget _buildContentAnalyticsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildContentMetricsGrid(context),
          const SizedBox(height: 24),
          _buildContentPerformanceChart(context),
          const SizedBox(height: 24),
          _buildContentCategoryAnalysis(context),
        ],
      ),
    );
  }

  Widget _buildRevenueAnalyticsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRevenueMetricsGrid(context),
          const SizedBox(height: 24),
          _buildRevenueChart(context),
          const SizedBox(height: 24),
          _buildSubscriptionAnalysis(context),
        ],
      ),
    );
  }

  // Additional tab content methods would go here...
  Widget _buildUserMetricsGrid(BuildContext context) {
    return Container(
      child: Text('User metrics grid placeholder'),
    );
  }

  Widget _buildUserDemographics(BuildContext context) {
    return Container(
      child: Text('User demographics placeholder'),
    );
  }

  Widget _buildUserBehaviorChart(BuildContext context) {
    return Container(
      child: Text('User behavior chart placeholder'),
    );
  }

  Widget _buildContentMetricsGrid(BuildContext context) {
    return Container(
      child: Text('Content metrics grid placeholder'),
    );
  }

  Widget _buildContentPerformanceChart(BuildContext context) {
    return Container(
      child: Text('Content performance chart placeholder'),
    );
  }

  Widget _buildContentCategoryAnalysis(BuildContext context) {
    return Container(
      child: Text('Content category analysis placeholder'),
    );
  }

  Widget _buildRevenueMetricsGrid(BuildContext context) {
    return Container(
      child: Text('Revenue metrics grid placeholder'),
    );
  }

  Widget _buildRevenueChart(BuildContext context) {
    return Container(
      child: Text('Revenue chart placeholder'),
    );
  }

  Widget _buildSubscriptionAnalysis(BuildContext context) {
    return Container(
      child: Text('Subscription analysis placeholder'),
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
              'Error loading analytics',
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
              onPressed: _refreshAnalytics,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  void _refreshAnalytics() {
    ref.read(analyticsParametersStateProvider.notifier).updateDateRange(
      _selectedDateRange?.start,
      _selectedDateRange?.end,
    );
    ref.refresh(currentAnalyticsProvider);
    ref.refresh(dashboardStatsProvider);
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _refreshAnalytics();
    }
  }

  void _exportData() async {
    final isExporting = ref.read(analyticsExportStateProvider);
    if (isExporting) return;

    try {
      final data = await ref.read(analyticsExportStateProvider.notifier).exportAnalyticsData();
      if (data != null) {
        // Handle export success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analytics data exported successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  bool _isQuickFilterSelected(String filter) {
    if (_selectedDateRange == null) return false;
    
    final now = DateTime.now();
    final days = {
      '7d': 7,
      '30d': 30,
      '90d': 90,
      '1y': 365,
    }[filter] ?? 30;
    
    final expectedStart = now.subtract(Duration(days: days));
    final daysDiff = _selectedDateRange!.start.difference(expectedStart).inDays.abs();
    
    return daysDiff <= 1; // Allow 1 day tolerance
  }

  void _applyQuickFilter(String filter) {
    final now = DateTime.now();
    final days = {
      '7d': 7,
      '30d': 30,
      '90d': 90,
      '1y': 365,
    }[filter] ?? 30;
    
    setState(() {
      _selectedDateRange = DateTimeRange(
        start: now.subtract(Duration(days: days)),
        end: now,
      );
    });
    _refreshAnalytics();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  List<FlSpot> _generateSampleData() {
    return [
      const FlSpot(0, 3),
      const FlSpot(2.6, 2),
      const FlSpot(4.9, 5),
      const FlSpot(6.8, 3.1),
      const FlSpot(8, 4),
      const FlSpot(9.5, 3),
      const FlSpot(11, 4),
    ];
  }

  List<PieChartSectionData> _generatePieData(BuildContext context) {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: 65,
        title: '65%',
        radius: 60,
        titleStyle: context.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: 30,
        title: '30%',
        radius: 60,
        titleStyle: context.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: 5,
        title: '5%',
        radius: 60,
        titleStyle: context.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }
}

// Helper classes
class _KPICard {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;

  const _KPICard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
  });
}

class _LegendItem {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });
}

class _ContentItem {
  final String title;
  final String type;
  final String views;
  final String engagement;
  final String revenue;

  const _ContentItem({
    required this.title,
    required this.type,
    required this.views,
    required this.engagement,
    required this.revenue,
  });
}