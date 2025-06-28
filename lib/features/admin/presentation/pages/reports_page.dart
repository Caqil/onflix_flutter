import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onflix/core/extensions/context_extension.dart';
import 'package:onflix/core/extensions/widget_extension.dart';
import 'package:onflix/core/utils/responsive_helper.dart';
import 'package:onflix/features/admin/presentation/providers/admin_auth_provider.dart';
import 'package:onflix/features/common/widgets/buttons/custom_button.dart';
import 'package:onflix/routes/route_names.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Reports page for generating and viewing various platform reports
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '30d';
  String _selectedFormat = 'pdf';
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
                _buildContentReportsTab(context),
                _buildUserReportsTab(context),
                _buildRevenueReportsTab(context),
                _buildSystemReportsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Reports & Analytics',
        style: context.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        ShadButton.ghost(
          onPressed: _scheduleReport,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.calendar, size: 16),
              SizedBox(width: 8),
              Text('Schedule'),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ShadButton(
          onPressed: _generateCustomReport,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.fileText, size: 16),
              SizedBox(width: 8),
              Text('Generate Report'),
            ],
          ),
        ),
        const SizedBox(width: 16),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Content Reports'),
          Tab(text: 'User Reports'),
          Tab(text: 'Revenue Reports'),
          Tab(text: 'System Reports'),
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
            Expanded(child: _buildPeriodDropdown(context)),
            const SizedBox(width: 12),
            Expanded(child: _buildFormatDropdown(context)),
          ],
        ),
        const SizedBox(height: 12),
        _buildCustomDatePicker(context),
      ],
    );
  }

  Widget _buildTabletFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildCustomDatePicker(context)),
        const SizedBox(width: 16),
        _buildPeriodDropdown(context),
        const SizedBox(width: 16),
        _buildFormatDropdown(context),
      ],
    );
  }

  Widget _buildDesktopFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildCustomDatePicker(context)),
        const SizedBox(width: 16),
        _buildPeriodDropdown(context),
        const SizedBox(width: 16),
        _buildFormatDropdown(context),
        const SizedBox(width: 16),
        _buildQuickActions(context),
      ],
    );
  }

  Widget _buildPeriodDropdown(BuildContext context) {
    return ShadDropdownMenu<String>(
      value: _selectedPeriod,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPeriod = value;
          });
        }
      },
      children: const [
        ShadDropdownMenuItem(value: '7d', child: Text('Last 7 Days')),
        ShadDropdownMenuItem(value: '30d', child: Text('Last 30 Days')),
        ShadDropdownMenuItem(value: '90d', child: Text('Last 90 Days')),
        ShadDropdownMenuItem(value: '1y', child: Text('Last Year')),
        ShadDropdownMenuItem(value: 'custom', child: Text('Custom Range')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border:
              Border.all(color: context.colorScheme.outline.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.calendar, size: 16),
            const SizedBox(width: 8),
            Text(_getPeriodLabel(_selectedPeriod)),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronDown, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatDropdown(BuildContext context) {
    return ShadDropdownMenu<String>(
      value: _selectedFormat,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedFormat = value;
          });
        }
      },
      children: const [
        ShadDropdownMenuItem(value: 'pdf', child: Text('PDF')),
        ShadDropdownMenuItem(value: 'excel', child: Text('Excel')),
        ShadDropdownMenuItem(value: 'csv', child: Text('CSV')),
        ShadDropdownMenuItem(value: 'json', child: Text('JSON')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border:
              Border.all(color: context.colorScheme.outline.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getFormatIcon(_selectedFormat), size: 16),
            const SizedBox(width: 8),
            Text(_selectedFormat.toUpperCase()),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronDown, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDatePicker(BuildContext context) {
    return ShadButton.outline(
      onPressed: _showCustomDatePicker,
      width: double.infinity,
      child: Row(
        children: [
          const Icon(LucideIcons.calendarDays, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _customDateRange != null
                  ? '${_formatDate(_customDateRange!.start)} - ${_formatDate(_customDateRange!.end)}'
                  : 'Select Custom Date Range',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        ShadButton.ghost(
          onPressed: _exportAllReports,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.downloadCloud, size: 16),
              const SizedBox(width: 8),
              const Text('Export All'),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ShadButton.ghost(
          onPressed: _viewReportHistory,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.history, size: 16),
              SizedBox(width: 8),
              Text('History'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentReportsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReportTypeGrid(context, _getContentReportTypes()),
          const SizedBox(height: 24),
          _buildRecentReports(context, 'Content Reports'),
        ],
      ),
    );
  }

  Widget _buildUserReportsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReportTypeGrid(context, _getUserReportTypes()),
          const SizedBox(height: 24),
          _buildRecentReports(context, 'User Reports'),
        ],
      ),
    );
  }

  Widget _buildRevenueReportsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReportTypeGrid(context, _getRevenueReportTypes()),
          const SizedBox(height: 24),
          _buildRecentReports(context, 'Revenue Reports'),
        ],
      ),
    );
  }

  Widget _buildSystemReportsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReportTypeGrid(context, _getSystemReportTypes()),
          const SizedBox(height: 24),
          _buildRecentReports(context, 'System Reports'),
        ],
      ),
    );
  }

  Widget _buildReportTypeGrid(
      BuildContext context, List<_ReportType> reportTypes) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isMobile(context)
            ? 1
            : ResponsiveHelper.isTablet(context)
                ? 2
                : 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: ResponsiveHelper.isMobile(context) ? 3 : 2,
      ),
      itemCount: reportTypes.length,
      itemBuilder: (context, index) =>
          _buildReportTypeCard(context, reportTypes[index]),
    );
  }

  Widget _buildReportTypeCard(BuildContext context, _ReportType reportType) {
    return ShadCard(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: reportType.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    reportType.icon,
                    color: reportType.color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: reportType.isPopular
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: reportType.isPopular
                      ? Text(
                          'Popular',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
            const Spacer(),
            Text(
              reportType.title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              reportType.description,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ShadButton.outline(
                    onPressed: () => _previewReport(reportType),
                    size: ShadButtonSize.sm,
                    child: const Text('Preview'),
                  ),
                ),
                const SizedBox(width: 8),
                ShadButton(
                  onPressed: () => _generateReport(reportType),
                  size: ShadButtonSize.sm,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.download, size: 14),
                      SizedBox(width: 4),
                      Text('Generate'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReports(BuildContext context, String category) {
    final recentReports = _getRecentReports(category);

    return ShadCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent Reports',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ShadButton.ghost(
                  onPressed: _viewAllReports,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentReports.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.fileX,
                      size: 48,
                      color: context.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No recent reports found',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Generate your first report to see it here',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...recentReports
                  .map((report) => _buildReportListItem(context, report)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportListItem(BuildContext context, _ReportItem report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: context.colorScheme.outline.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getReportStatusColor(report.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getReportStatusIcon(report.status),
              color: _getReportStatusColor(report.status),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${report.type} • Generated ${report.generatedDate}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          _buildReportStatusBadge(context, report.status),
          const SizedBox(width: 12),
          ShadDropdownMenu<String>(
            children: [
              ShadDropdownMenuItem(
                value: 'download',
                child: const Row(
                  children: [
                    Icon(LucideIcons.download, size: 14),
                    SizedBox(width: 8),
                    Text('Download'),
                  ],
                ),
              ),
              ShadDropdownMenuItem(
                value: 'view',
                child: const Row(
                  children: [
                    Icon(LucideIcons.eye, size: 14),
                    SizedBox(width: 8),
                    Text('View'),
                  ],
                ),
              ),
              ShadDropdownMenuItem(
                value: 'regenerate',
                child: const Row(
                  children: [
                    Icon(LucideIcons.refreshCw, size: 14),
                    SizedBox(width: 8),
                    Text('Regenerate'),
                  ],
                ),
              ),
              const ShadDropdownMenuSeparator(),
              ShadDropdownMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(LucideIcons.trash2,
                        size: 14, color: context.colorScheme.error),
                    const SizedBox(width: 8),
                    Text('Delete',
                        style: TextStyle(color: context.colorScheme.error)),
                  ],
                ),
              ),
            ],
            child: ShadButton.ghost(
              child: Icon(LucideIcons.moreHorizontal, size: 16),
            ),
            onChanged: (value) => _handleReportAction(report, value),
          ),
        ],
      ),
    );
  }

  Widget _buildReportStatusBadge(BuildContext context, String status) {
    final color = _getReportStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: context.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  // Action methods
  void _generateReport(_ReportType reportType) {
    showDialog(
      context: context,
      builder: (context) => _GenerateReportDialog(
        reportType: reportType,
        selectedPeriod: _selectedPeriod,
        selectedFormat: _selectedFormat,
        customDateRange: _customDateRange,
      ),
    );
  }

  void _previewReport(_ReportType reportType) {
    showDialog(
      context: context,
      builder: (context) => _PreviewReportDialog(reportType: reportType),
    );
  }

  void _generateCustomReport() {
    showDialog(
      context: context,
      builder: (context) => const _CustomReportDialog(),
    );
  }

  void _scheduleReport() {
    showDialog(
      context: context,
      builder: (context) => const _ScheduleReportDialog(),
    );
  }

  void _exportAllReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting all reports...'),
      ),
    );
  }

  void _viewReportHistory() {
    // Navigate to report history page
  }

  void _viewAllReports() {
    // Navigate to all reports page
  }

  void _handleReportAction(_ReportItem report, String? action) {
    switch (action) {
      case 'download':
        _downloadReport(report);
        break;
      case 'view':
        _viewReport(report);
        break;
      case 'regenerate':
        _regenerateReport(report);
        break;
      case 'delete':
        _deleteReport(report);
        break;
    }
  }

  void _downloadReport(_ReportItem report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${report.title}...')),
    );
  }

  void _viewReport(_ReportItem report) {
    // Navigate to report viewer
  }

  void _regenerateReport(_ReportItem report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Regenerating ${report.title}...')),
    );
  }

  void _deleteReport(_ReportItem report) {
    showDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Delete Report'),
        description: Text('Are you sure you want to delete "${report.title}"?'),
        actions: [
          ShadButton.ghost(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ShadButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${report.title} deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCustomDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customDateRange,
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedPeriod = 'custom';
      });
    }
  }

  // Helper methods
  String _getPeriodLabel(String period) {
    switch (period) {
      case '7d':
        return 'Last 7 Days';
      case '30d':
        return 'Last 30 Days';
      case '90d':
        return 'Last 90 Days';
      case '1y':
        return 'Last Year';
      case 'custom':
        return 'Custom Range';
      default:
        return period;
    }
  }

  IconData _getFormatIcon(String format) {
    switch (format) {
      case 'pdf':
        return LucideIcons.fileText;
      case 'excel':
        return LucideIcons.sheet;
      case 'csv':
        return LucideIcons.fileSpreadsheet;
      case 'json':
        return LucideIcons.braces;
      default:
        return LucideIcons.file;
    }
  }

  Color _getReportStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'failed':
        return Colors.red;
      case 'scheduled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getReportStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return LucideIcons.checkCircle;
      case 'processing':
        return LucideIcons.loader;
      case 'failed':
        return LucideIcons.xCircle;
      case 'scheduled':
        return LucideIcons.clock;
      default:
        return LucideIcons.file;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Mock data methods
  List<_ReportType> _getContentReportTypes() {
    return [
      _ReportType(
        id: 'content_performance',
        title: 'Content Performance',
        description:
            'Detailed analytics on content views, engagement, and ratings',
        icon: LucideIcons.barChart3,
        color: Colors.blue,
        isPopular: true,
      ),
      const _ReportType(
        id: 'top_content',
        title: 'Top Performing Content',
        description: 'List of most viewed and highest rated content',
        icon: LucideIcons.trophy,
        color: Colors.orange,
      ),
      const _ReportType(
        id: 'content_library',
        title: 'Content Library Summary',
        description: 'Overview of all content by genre, type, and status',
        icon: LucideIcons.library,
        color: Colors.green,
      ),
    ];
  }

  List<_ReportType> _getUserReportTypes() {
    return [
      const _ReportType(
        id: 'user_engagement',
        title: 'User Engagement',
        description: 'User activity, session duration, and engagement metrics',
        icon: LucideIcons.users,
        color: Colors.purple,
        isPopular: true,
      ),
      const _ReportType(
        id: 'subscription_analysis',
        title: 'Subscription Analysis',
        description: 'Subscription trends, churn rate, and user lifecycle',
        icon: LucideIcons.creditCard,
        color: Colors.indigo,
      ),
      const _ReportType(
        id: 'user_demographics',
        title: 'User Demographics',
        description: 'User distribution by age, location, and preferences',
        icon: LucideIcons.mapPin,
        color: Colors.teal,
      ),
    ];
  }

  List<_ReportType> _getRevenueReportTypes() {
    return [
      const _ReportType(
        id: 'revenue_summary',
        title: 'Revenue Summary',
        description: 'Total revenue, growth trends, and forecasting',
        icon: LucideIcons.dollarSign,
        color: Colors.green,
        isPopular: true,
      ),
      const _ReportType(
        id: 'payment_analysis',
        title: 'Payment Analysis',
        description: 'Payment methods, success rates, and failed transactions',
        icon: LucideIcons.creditCard,
        color: Colors.blue,
      ),
      const _ReportType(
        id: 'subscription_revenue',
        title: 'Subscription Revenue',
        description: 'Revenue breakdown by subscription plans and tiers',
        icon: LucideIcons.repeat,
        color: Colors.purple,
      ),
    ];
  }

  List<_ReportType> _getSystemReportTypes() {
    return [
      const _ReportType(
        id: 'system_performance',
        title: 'System Performance',
        description: 'Server uptime, response times, and system health',
        icon: LucideIcons.activity,
        color: Colors.red,
      ),
      const _ReportType(
        id: 'security_audit',
        title: 'Security Audit',
        description: 'Security events, login attempts, and threat analysis',
        icon: LucideIcons.shield,
        color: Colors.orange,
      ),
      const _ReportType(
        id: 'storage_usage',
        title: 'Storage Usage',
        description: 'Content storage, bandwidth usage, and CDN statistics',
        icon: LucideIcons.hardDrive,
        color: Colors.cyan,
      ),
    ];
  }

  List<_ReportItem> _getRecentReports(String category) {
    return [
      const _ReportItem(
        id: '1',
        title: 'Content Performance Report',
        type: 'PDF',
        status: 'Completed',
        generatedDate: '2 hours ago',
      ),
      const _ReportItem(
        id: '2',
        title: 'User Engagement Analysis',
        type: 'Excel',
        status: 'Processing',
        generatedDate: '1 day ago',
      ),
      const _ReportItem(
        id: '3',
        title: 'Revenue Summary Q1',
        type: 'PDF',
        status: 'Completed',
        generatedDate: '3 days ago',
      ),
    ];
  }
}

// Helper classes
class _ReportType {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isPopular;

  const _ReportType({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isPopular = false,
  });
}

class _ReportItem {
  final String id;
  final String title;
  final String type;
  final String status;
  final String generatedDate;

  const _ReportItem({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.generatedDate,
  });
}

// Dialog classes would be defined here...
class _GenerateReportDialog extends StatelessWidget {
  final _ReportType reportType;
  final String selectedPeriod;
  final String selectedFormat;
  final DateTimeRange? customDateRange;

  const _GenerateReportDialog({
    required this.reportType,
    required this.selectedPeriod,
    required this.selectedFormat,
    this.customDateRange,
  });

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: Text('Generate ${reportType.title}'),
      content: Container(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Generate a ${reportType.title.toLowerCase()} report with the current settings.'),
            const SizedBox(height: 16),
            _buildSetting('Period', selectedPeriod),
            _buildSetting('Format', selectedFormat.toUpperCase()),
            if (customDateRange != null)
              _buildSetting(
                  'Date Range',
                  '${customDateRange!.start.day}/${customDateRange!.start.month}/${customDateRange!.start.year} - '
                      '${customDateRange!.end.day}/${customDateRange!.end.month}/${customDateRange!.end.year}'),
          ],
        ),
      ),
      actions: [
        ShadButton.ghost(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ShadButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Generating ${reportType.title}...')),
            );
          },
          child: const Text('Generate'),
        ),
      ],
    );
  }

  Widget _buildSetting(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}

class _PreviewReportDialog extends StatelessWidget {
  final _ReportType reportType;

  const _PreviewReportDialog({required this.reportType});

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: Text('Preview ${reportType.title}'),
      content: Container(
        width: 500,
        height: 300,
        child: const Center(
          child: Text('Report preview would be displayed here'),
        ),
      ),
      actions: [
        ShadButton.ghost(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _CustomReportDialog extends StatelessWidget {
  const _CustomReportDialog();

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Create Custom Report'),
      content: Container(
        width: 500,
        child: const Text('Custom report builder would go here'),
      ),
      actions: [
        ShadButton.ghost(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ShadButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _ScheduleReportDialog extends StatelessWidget {
  const _ScheduleReportDialog();

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Schedule Report'),
      child: const SizedBox(
        width: 400,
        child: Text('Report scheduling options would go here'),
      ),
      actions: [
        ShadButton.ghost(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ShadButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}
