
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onflix/core/extensions/context_extension.dart';
import 'package:onflix/core/extensions/widget_extension.dart';
import 'package:onflix/core/utils/responsive_helper.dart';
import 'package:onflix/features/admin/presentation/providers/admin_auth_provider.dart';
import 'package:onflix/features/common/widgets/cards/info_card.dart';
import 'package:onflix/features/common/widgets/buttons/custom_button.dart';
import 'package:onflix/routes/route_names.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Content management page for uploading, editing, and managing video content
class ContentManagementPage extends ConsumerStatefulWidget {
  const ContentManagementPage({super.key});

  @override
  ConsumerState<ContentManagementPage> createState() => _ContentManagementPageState();
}

class _ContentManagementPageState extends ConsumerState<ContentManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  String _sortBy = 'created_desc';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
                _buildAllContentTab(context),
                _buildMoviesTab(context),
                _buildSeriesTab(context),
                _buildPendingTab(context),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Content Management',
        style: context.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        ShadButton.ghost(
          onPressed: _showBulkActionsDialog,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.packageCheck, size: 16),
              SizedBox(width: 8),
              Text('Bulk Actions'),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ShadButton.ghost(
          onPressed: _exportContentList,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.download, size: 16),
              SizedBox(width: 8),
              Text('Export'),
            ],
          ),
        ),
        const SizedBox(width: 16),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'All Content'),
          Tab(text: 'Movies'),
          Tab(text: 'Series'),
          Tab(text: 'Pending'),
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSearchField(context)),
              const SizedBox(width: 12),
              _buildFilterDropdown(context),
              const SizedBox(width: 12),
              _buildSortDropdown(context),
            ],
          ),
          if (!ResponsiveHelper.isMobile(context)) ...[
            const SizedBox(height: 12),
            _buildQuickFilters(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return ShadInput(
      controller: _searchController,
      placeholder: 'Search content by title, genre, or cast...',
      prefix: Icon(
        LucideIcons.search,
        size: 18,
        color: context.colorScheme.onSurface.withOpacity(0.5),
      ),
      suffix: _searchQuery.isNotEmpty
          ? ShadButton.ghost(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              child: Icon(
                LucideIcons.x,
                size: 16,
                color: context.colorScheme.onSurface.withOpacity(0.5),
              ),
            )
          : null,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
        // Implement debounced search
      },
    );
  }

  Widget _buildFilterDropdown(BuildContext context) {
    return ShadDropdownMenu<String>(
      value: _selectedFilter,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedFilter = value;
          });
        }
      },
      children: const [
        ShadDropdownMenuItem(value: 'all', child: Text('All Status')),
        ShadDropdownMenuItem(value: 'published', child: Text('Published')),
        ShadDropdownMenuItem(value: 'draft', child: Text('Draft')),
        ShadDropdownMenuItem(value: 'archived', child: Text('Archived')),
        ShadDropdownMenuItem(value: 'featured', child: Text('Featured')),
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
            Icon(LucideIcons.filter, size: 16),
            const SizedBox(width: 8),
            const Text('Filter'),
            const SizedBox(width: 4),
            const Icon(LucideIcons.chevronDown, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown(BuildContext context) {
    return ShadDropdownMenu<String>(
      value: _sortBy,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _sortBy = value;
          });
        }
      },
      children: const [
        ShadDropdownMenuItem(value: 'created_desc', child: Text('Newest First')),
        ShadDropdownMenuItem(value: 'created_asc', child: Text('Oldest First')),
        ShadDropdownMenuItem(value: 'title_asc', child: Text('Title A-Z')),
        ShadDropdownMenuItem(value: 'title_desc', child: Text('Title Z-A')),
        ShadDropdownMenuItem(value: 'views_desc', child: Text('Most Viewed')),
        ShadDropdownMenuItem(value: 'rating_desc', child: Text('Highest Rated')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.outline.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.arrowUpDown, size: 16),
            SizedBox(width: 8),
            Text('Sort'),
            SizedBox(width: 4),
            Icon(LucideIcons.chevronDown, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilters(BuildContext context) {
    final quickFilters = [
      const _QuickFilter('today', 'Added Today', LucideIcons.calendar),
      const _QuickFilter('week', 'This Week', LucideIcons.calendarDays),
      const _QuickFilter('featured', 'Featured', LucideIcons.star),
      const _QuickFilter('trending', 'Trending', LucideIcons.trendingUp),
    ];

    return Row(
      children: quickFilters.map((filter) {
        final isSelected = _selectedFilter == filter.value;
        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: ShadButton.outline(
            onPressed: () {
              setState(() {
                _selectedFilter = filter.value;
              });
            },
            variant: isSelected ? ShadButtonVariant.default : ShadButtonVariant.outline,
            size: ShadButtonSize.sm,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(filter.icon, size: 14),
                const SizedBox(width: 6),
                Text(filter.label),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAllContentTab(BuildContext context) {
    return _buildContentGrid(context, _getMockContent());
  }

  Widget _buildMoviesTab(BuildContext context) {
    final movies = _getMockContent().where((content) => content.type == 'Movie').toList();
    return _buildContentGrid(context, movies);
  }

  Widget _buildSeriesTab(BuildContext context) {
    final series = _getMockContent().where((content) => content.type == 'Series').toList();
    return _buildContentGrid(context, series);
  }

  Widget _buildPendingTab(BuildContext context) {
    final pending = _getMockContent().where((content) => content.status == 'Pending').toList();
    return _buildContentGrid(context, pending);
  }

  Widget _buildContentGrid(BuildContext context, List<_ContentItem> content) {
    if (content.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Implement refresh logic
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ResponsiveHelper.buildResponsive(
          context,
          mobile: _buildMobileContentList(context, content),
          tablet: _buildTabletContentGrid(context, content),
          desktop: _buildDesktopContentGrid(context, content),
        ),
      ),
    );
  }

  Widget _buildMobileContentList(BuildContext context, List<_ContentItem> content) {
    return Column(
      children: content.map((item) => _buildMobileContentCard(context, item)).toList(),
    );
  }

  Widget _buildTabletContentGrid(BuildContext context, List<_ContentItem> content) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: content.length,
      itemBuilder: (context, index) => _buildContentCard(context, content[index]),
    );
  }

  Widget _buildDesktopContentGrid(BuildContext context, List<_ContentItem> content) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: content.length,
      itemBuilder: (context, index) => _buildContentCard(context, content[index]),
    );
  }

  Widget _buildMobileContentCard(BuildContext context, _ContentItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ShadCard(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  image: item.thumbnail != null
                      ? DecorationImage(
                          image: NetworkImage(item.thumbnail!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: item.thumbnail == null
                    ? Icon(
                        LucideIcons.image,
                        color: context.colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildStatusBadge(context, item.status),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(LucideIcons.calendar, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          item.createdDate,
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.eye, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          item.views,
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ShadButton.outline(
                          onPressed: () => _editContent(item),
                          size: ShadButtonSize.sm,
                          child: const Text('Edit'),
                        ),
                        const SizedBox(width: 8),
                        ShadDropdownMenu<String>(
                          children: [
                            ShadDropdownMenuItem(
                              value: 'view',
                              child: const Row(
                                children: [
                                  Icon(LucideIcons.eye, size: 14),
                                  SizedBox(width: 8),
                                  Text('View Details'),
                                ],
                              ),
                            ),
                            ShadDropdownMenuItem(
                              value: 'duplicate',
                              child: const Row(
                                children: [
                                  Icon(LucideIcons.copy, size: 14),
                                  SizedBox(width: 8),
                                  Text('Duplicate'),
                                ],
                              ),
                            ),
                            ShadDropdownMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(LucideIcons.trash2, size: 14, color: context.colorScheme.error),
                                  const SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: context.colorScheme.error)),
                                ],
                              ),
                            ),
                          ],
                          child: ShadButton.ghost(
                            size: ShadButtonSize.sm,
                            child: Icon(LucideIcons.moreHorizontal, size: 16),
                          ),
                          onChanged: (value) => _handleContentAction(item, value),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, _ContentItem item) {
    return ShadCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                image: item.thumbnail != null
                    ? DecorationImage(
                        image: NetworkImage(item.thumbnail!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  if (item.thumbnail == null)
                    Center(
                      child: Icon(
                        LucideIcons.image,
                        size: 48,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildStatusBadge(context, item.status),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.type,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  if (item.duration != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.duration!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Content info
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.genres.isNotEmpty)
                    Text(
                      item.genres.join(', '),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(LucideIcons.eye, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        item.views,
                        style: context.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      if (item.rating != null) ...[
                        const Icon(LucideIcons.star, size: 12, color: Colors.orange),
                        const SizedBox(width: 2),
                        Text(
                          item.rating!,
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.outline(
                          onPressed: () => _editContent(item),
                          size: ShadButtonSize.sm,
                          child: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ShadDropdownMenu<String>(
                        children: [
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
                            value: 'duplicate',
                            child: const Row(
                              children: [
                                Icon(LucideIcons.copy, size: 14),
                                SizedBox(width: 8),
                                Text('Duplicate'),
                              ],
                            ),
                          ),
                          const ShadDropdownMenuSeparator(),
                          ShadDropdownMenuItem(
                            value: 'delete',
                            child: const Row(
                              children: [
                                Icon(LucideIcons.trash2, size: 14, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        child: ShadButton.ghost(
                          size: ShadButtonSize.sm,
                          child: Icon(LucideIcons.moreHorizontal, size: 16),
                        ),
                        onChanged: (value) => _handleContentAction(item, value),
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

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color badgeColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'published':
        badgeColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'draft':
        badgeColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'pending':
        badgeColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case 'archived':
        badgeColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        break;
      default:
        badgeColor = context.colorScheme.surfaceVariant;
        textColor = context.colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: context.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              LucideIcons.fileVideo,
              size: 48,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No content found',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by uploading your first movie or series',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ShadButton(
            onPressed: _showUploadDialog,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.plus, size: 16),
                SizedBox(width: 8),
                Text('Upload Content'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _showUploadDialog,
      icon: const Icon(LucideIcons.plus),
      label: const Text('Upload'),
      backgroundColor: context.colorScheme.primary,
      foregroundColor: context.colorScheme.onPrimary,
    );
  }

  // Action methods
  void _editContent(_ContentItem item) {
    // Navigate to content edit page
    showDialog(
      context: context,
      builder: (context) => _EditContentDialog(item: item),
    );
  }

  void _handleContentAction(_ContentItem item, String? action) {
    switch (action) {
      case 'view':
        _viewContentDetails(item);
        break;
      case 'duplicate':
        _duplicateContent(item);
        break;
      case 'delete':
        _showDeleteConfirmation(item);
        break;
    }
  }

  void _viewContentDetails(_ContentItem item) {
    showDialog(
      context: context,
      builder: (context) => _ContentDetailsDialog(item: item),
    );
  }

  void _duplicateContent(_ContentItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Content "${item.title}" duplicated successfully'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Implement undo functionality
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(_ContentItem item) {
    showDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Delete Content'),
        description: Text(
          'Are you sure you want to delete "${item.title}"? This action cannot be undone.',
        ),
        actions: [
          ShadButton.ghost(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ShadButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteContent(item);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteContent(_ContentItem item) {
    // Implement delete functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Content "${item.title}" deleted successfully'),
        backgroundColor: context.colorScheme.error,
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => const _UploadContentDialog(),
    );
  }

  void _showBulkActionsDialog() {
    showDialog(
      context: context,
      builder: (context) => const _BulkActionsDialog(),
    );
  }

  void _exportContentList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Content list exported successfully'),
      ),
    );
  }

  // Mock data
  List<_ContentItem> _getMockContent() {
    return [
      const _ContentItem(
        id: '1',
        title: 'The Matrix Resurrections',
        type: 'Movie',
        status: 'Published',
        thumbnail: 'https://via.placeholder.com/300x450',
        genres: ['Action', 'Sci-Fi'],
        duration: '2h 28m',
        views: '125K',
        rating: '8.5',
        createdDate: '2024-01-15',
      ),
      const _ContentItem(
        id: '2',
        title: 'Stranger Things',
        type: 'Series',
        status: 'Published',
        thumbnail: 'https://via.placeholder.com/300x450',
        genres: ['Drama', 'Fantasy', 'Horror'],
        duration: '4 seasons',
        views: '2.1M',
        rating: '9.2',
        createdDate: '2024-01-10',
      ),
      const _ContentItem(
        id: '3',
        title: 'Top Gun: Maverick',
        type: 'Movie',
        status: 'Draft',
        thumbnail: 'https://via.placeholder.com/300x450',
        genres: ['Action', 'Drama'],
        duration: '2h 11m',
        views: '87K',
        rating: '8.8',
        createdDate: '2024-01-12',
      ),
      const _ContentItem(
        id: '4',
        title: 'The Witcher',
        type: 'Series',
        status: 'Pending',
        genres: ['Fantasy', 'Adventure'],
        duration: '3 seasons',
        views: '1.5M',
        rating: '8.7',
        createdDate: '2024-01-08',
      ),
      const _ContentItem(
        id: '5',
        title: 'Dune',
        type: 'Movie',
        status: 'Archived',
        thumbnail: 'https://via.placeholder.com/300x450',
        genres: ['Sci-Fi', 'Adventure'],
        duration: '2h 35m',
        views: '320K',
        rating: '9.0',
        createdDate: '2024-01-05',
      ),
    ];
  }
}

// Helper classes
class _QuickFilter {
  final String value;
  final String label;
  final IconData icon;

  const _QuickFilter(this.value, this.label, this.icon);
}

class _ContentItem {
  final String id;
  final String title;
  final String type;
  final String status;
  final String? thumbnail;
  final List<String> genres;
  final String? duration;
  final String views;
  final String? rating;
  final String createdDate;

  const _ContentItem({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    this.thumbnail,
    required this.genres,
    this.duration,
    required this.views,
    this.rating,
    required this.createdDate,
  });
}

// Dialog widgets
class _UploadContentDialog extends StatefulWidget {
  const _UploadContentDialog();

  @override
  State<_UploadContentDialog> createState() => _UploadContentDialogState();
}

class _UploadContentDialogState extends State<_UploadContentDialog> {
  String _selectedType = 'movie';
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Upload New Content'),
      description: const Text('Add a new movie or series to your content library'),
      content: SizedBox(
        width: ResponsiveHelper.isDesktop(context) ? 500 : double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Content type selection
            Row(
              children: [
                Expanded(
                  child: ShadRadio<String>(
                    value: 'movie',
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    label: const Text('Movie'),
                  ),
                ),
                Expanded(
                  child: ShadRadio<String>(
                    value: 'series',
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    label: const Text('Series'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Title field
            ShadInput(
              controller: _titleController,
              placeholder: 'Enter content title',
              label: const Text('Title'),
            ),
            const SizedBox(height: 16),
            
            // Description field
            ShadInput(
              controller: _descriptionController,
              placeholder: 'Enter content description',
              label: const Text('Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // File upload area
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.colorScheme.outline.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.upload,
                    size: 32,
                    color: context.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Drop video files here or click to browse',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Supports MP4, MOV, AVI (Max 5GB)',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
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
              SnackBar(
                content: Text('Content upload started for "${_titleController.text}"'),
              ),
            );
          },
          child: const Text('Upload'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _EditContentDialog extends StatefulWidget {
  final _ContentItem item;

  const _EditContentDialog({required this.item});

  @override
  State<_EditContentDialog> createState() => _EditContentDialogState();
}

class _EditContentDialogState extends State<_EditContentDialog> {
  late TextEditingController _titleController;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _selectedStatus = widget.item.status;
  }

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Edit Content'),
      description: const Text('Modify content details and settings'),
      actions: [
        ShadButton.ghost(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ShadButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Content "${_titleController.text}" updated successfully'),
              ),
            );
          },
          child: const Text('Save Changes'),
        ),
      ],
      child: SizedBox(
        width: ResponsiveHelper.isDesktop(context) ? 500 : double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShadInput(
              controller: _titleController,
              label: const Text('Title'),
            ),
            const SizedBox(height: 16),
            
            ShadDropdownMenu<String>(
              value: _selectedStatus,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
              children: const [
                ShadDropdownMenuItem(value: 'Published', child: Text('Published')),
                ShadDropdownMenuItem(value: 'Draft', child: Text('Draft')),
                ShadDropdownMenuItem(value: 'Pending', child: Text('Pending')),
                ShadDropdownMenuItem(value: 'Archived', child: Text('Archived')),
              ],
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colorScheme.outline.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text('Status: $_selectedStatus'),
                    const Spacer(),
                    const Icon(LucideIcons.chevronDown, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

class _ContentDetailsDialog extends StatelessWidget {
  final _ContentItem item;

  const _ContentDetailsDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Content Details'),
      content: SizedBox(
        width: ResponsiveHelper.isDesktop(context) ? 600 : double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.thumbnail != null) ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(item.thumbnail!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            Text(
              item.title,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            _buildDetailRow(context, 'Type', item.type),
            _buildDetailRow(context, 'Status', item.status),
            _buildDetailRow(context, 'Genres', item.genres.join(', ')),
            if (item.duration != null)
              _buildDetailRow(context, 'Duration', item.duration!),
            _buildDetailRow(context, 'Views', item.views),
            if (item.rating != null)
              _buildDetailRow(context, 'Rating', '${item.rating}/10'),
            _buildDetailRow(context, 'Created', item.createdDate),
          ],
        ),
      ),
      actions: [
        ShadButton.ghost(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ShadButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Navigate to edit page
          },
          child: const Text('Edit'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _BulkActionsDialog extends StatefulWidget {
  const _BulkActionsDialog();

  @override
  State<_BulkActionsDialog> createState() => _BulkActionsDialogState();
}

class _BulkActionsDialogState extends State<_BulkActionsDialog> {
  String _selectedAction = 'publish';
  final List<String> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Bulk Actions'),
      description: const Text('Apply actions to multiple content items'),
      content: SizedBox(
        width: ResponsiveHelper.isDesktop(context) ? 500 : double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShadDropdownMenu<String>(
              value: _selectedAction,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedAction = value;
                  });
                }
              },
              children: const [
                ShadDropdownMenuItem(value: 'publish', child: Text('Publish Selected')),
                ShadDropdownMenuItem(value: 'draft', child: Text('Move to Draft')),
                ShadDropdownMenuItem(value: 'archive', child: Text('Archive Selected')),
                ShadDropdownMenuItem(value: 'delete', child: Text('Delete Selected')),
              ],
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colorScheme.outline.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text('Action: ${_selectedAction.toUpperCase()}'),
                    const Spacer(),
                    const Icon(LucideIcons.chevronDown, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'This action will be applied to all selected content items.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
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
              SnackBar(
                content: Text('Bulk action "$_selectedAction" applied successfully'),
              ),
            );
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}