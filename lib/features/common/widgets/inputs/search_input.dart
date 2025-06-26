import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onflix/core/config/theme/color_scheme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../buttons/icon_button_widget.dart';

/// Enhanced search input widget with suggestions, filters, and history
class SearchInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onFocus;
  final VoidCallback? onUnfocus;
  final List<String>? suggestions;
  final List<SearchFilter>? filters;
  final List<String>? searchHistory;
  final bool showSuggestions;
  final bool showHistory;
  final bool showFilters;
  final bool autofocus;
  final bool enabled;
  final int? maxSuggestions;
  final int? maxHistory;
  final Duration debounceDelay;
  final SearchInputStyle style;
  final SearchInputSize size;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final FocusNode? focusNode;
  final bool enableVoiceSearch;
  final VoidCallback? onVoiceSearch;
  final bool enableBarcode;
  final VoidCallback? onBarcodeSearch;

  const SearchInput({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onFocus,
    this.onUnfocus,
    this.suggestions,
    this.filters,
    this.searchHistory,
    this.showSuggestions = true,
    this.showHistory = true,
    this.showFilters = false,
    this.autofocus = false,
    this.enabled = true,
    this.maxSuggestions = 5,
    this.maxHistory = 10,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.style = SearchInputStyle.filled,
    this.size = SearchInputSize.medium,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
    this.focusNode,
    this.enableVoiceSearch = false,
    this.onVoiceSearch,
    this.enableBarcode = false,
    this.onBarcodeSearch,
  });

  // Named constructors for common use cases
  const SearchInput.compact({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.suggestions,
    this.showSuggestions = true,
    this.showHistory = false,
    this.showFilters = false,
    this.enabled = true,
    this.maxSuggestions = 3,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.backgroundColor,
    this.borderRadius,
    this.focusNode,
  })  : initialValue = null,
        onFocus = null,
        onUnfocus = null,
        filters = null,
        searchHistory = null,
        autofocus = false,
        maxHistory = null,
        style = SearchInputStyle.filled,
        size = SearchInputSize.small,
        prefixIcon = null,
        suffixIcon = null,
        borderColor = null,
        focusedBorderColor = null,
        contentPadding = null,
        textStyle = null,
        hintStyle = null,
        enableVoiceSearch = false,
        onVoiceSearch = null,
        enableBarcode = false,
        onBarcodeSearch = null;

  const SearchInput.withFilters({
    super.key,
    this.controller,
    this.hintText = 'Search and filter...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.suggestions,
    required this.filters,
    this.showSuggestions = true,
    this.showHistory = false,
    this.showFilters = true,
    this.enabled = true,
    this.maxSuggestions = 5,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.backgroundColor,
    this.borderRadius,
    this.focusNode,
  })  : initialValue = null,
        onFocus = null,
        onUnfocus = null,
        searchHistory = null,
        autofocus = false,
        maxHistory = null,
        style = SearchInputStyle.outlined,
        size = SearchInputSize.medium,
        prefixIcon = null,
        suffixIcon = null,
        borderColor = null,
        focusedBorderColor = null,
        contentPadding = null,
        textStyle = null,
        hintStyle = null,
        enableVoiceSearch = false,
        onVoiceSearch = null,
        enableBarcode = false,
        onBarcodeSearch = null;

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  bool _isFocused = false;
  bool _showOverlay = false;
  String _currentQuery = '';
  List<String> _filteredSuggestions = [];
  List<String> _filteredHistory = [];
  List<SearchFilter> _activeFilters = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _initializeFilters();
  }

  void _initializeControllers() {
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);

    _currentQuery = _controller.text;
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
  }

  void _initializeFilters() {
    _activeFilters =
        widget.filters?.where((filter) => filter.isActive).toList() ?? [];
  }

  @override
  void didUpdateWidget(SearchInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_handleTextChange);
      _controller = widget.controller ?? _controller;
      _controller.addListener(_handleTextChange);
    }

    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode = widget.focusNode ?? _focusNode;
      _focusNode.addListener(_handleFocusChange);
    }

    if (widget.filters != oldWidget.filters) {
      _initializeFilters();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _controller.removeListener(_handleTextChange);

    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }

    _fadeController.dispose();
    _scaleController.dispose();
    _closeOverlay();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      widget.onFocus?.call();
      _updateSuggestions();
      _showOverlayIfNeeded();
    } else {
      widget.onUnfocus?.call();
      _closeOverlay();
    }
  }

  void _handleTextChange() {
    final newQuery = _controller.text;
    if (newQuery != _currentQuery) {
      setState(() {
        _currentQuery = newQuery;
      });

      widget.onChanged?.call(newQuery);
      _updateSuggestions();
      _showOverlayIfNeeded();
    }
  }

  void _updateSuggestions() {
    if (widget.suggestions != null) {
      _filteredSuggestions = widget.suggestions!
          .where((suggestion) =>
              suggestion.toLowerCase().contains(_currentQuery.toLowerCase()) &&
              suggestion.toLowerCase() != _currentQuery.toLowerCase())
          .take(widget.maxSuggestions ?? 5)
          .toList();
    }

    if (widget.searchHistory != null) {
      _filteredHistory = widget.searchHistory!
          .where((item) =>
              item.toLowerCase().contains(_currentQuery.toLowerCase()) &&
              item.toLowerCase() != _currentQuery.toLowerCase())
          .take(widget.maxHistory ?? 10)
          .toList();
    }
  }

  void _showOverlayIfNeeded() {
    final shouldShow = _isFocused &&
        ((_filteredSuggestions.isNotEmpty && widget.showSuggestions) ||
            (_filteredHistory.isNotEmpty &&
                widget.showHistory &&
                _currentQuery.isEmpty) ||
            (widget.showFilters &&
                widget.filters != null &&
                widget.filters!.isNotEmpty));

    if (shouldShow && !_showOverlay) {
      _showOverlay = true;
      _createOverlay();
      _fadeController.forward();
      _scaleController.forward();
    } else if (!shouldShow && _showOverlay) {
      _closeOverlay();
    }
  }

  void _createOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildOverlay(),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeOverlay() {
    if (_overlayEntry != null) {
      _fadeController.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _showOverlay = false;
      });
    }
  }

  void _handleSuggestionTapped(String suggestion) {
    _controller.text = suggestion;
    _currentQuery = suggestion;
    widget.onChanged?.call(suggestion);
    widget.onSubmitted?.call(suggestion);
    _focusNode.unfocus();
  }

  void _handleFilterToggled(SearchFilter filter) {
    setState(() {
      filter.isActive = !filter.isActive;
      if (filter.isActive) {
        _activeFilters.add(filter);
      } else {
        _activeFilters.remove(filter);
      }
    });

    filter.onChanged?.call(filter.isActive);
  }

  void _handleClear() {
    _controller.clear();
    _currentQuery = '';
    widget.onChanged?.call('');
    widget.onClear?.call();
    _updateSuggestions();
  }

  void _handleSubmit() {
    widget.onSubmitted?.call(_currentQuery);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchField(context),
          if (widget.showFilters && _activeFilters.isNotEmpty)
            _buildActiveFilters(context),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: _buildDecoration(context),
      child: Row(
        children: [
          _buildPrefixIcon(),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: widget.textStyle ?? _getDefaultTextStyle(context),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: widget.hintStyle ?? _getDefaultHintStyle(context),
                border: InputBorder.none,
                contentPadding:
                    widget.contentPadding ?? _getDefaultContentPadding(),
              ),
              textInputAction: TextInputAction.search,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              onSubmitted: (_) => _handleSubmit(),
            ),
          ),
          _buildSuffixActions(),
        ],
      ),
    );
  }

  Widget _buildPrefixIcon() {
    if (widget.prefixIcon != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: widget.prefixIcon!,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Icon(
        LucideIcons.search,
        size: _getIconSize(),
        color: _isFocused ? OnflixColors.primary : OnflixColors.lightGray,
      ),
    );
  }

  Widget _buildSuffixActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_currentQuery.isNotEmpty)
          OnflixIconButton(
            icon: LucideIcons.x,
            onPressed: _handleClear,
            style: IconButtonStyle.ghost,
            iconSize: _getIconSize(),
          ),
        if (widget.enableVoiceSearch)
          OnflixIconButton(
            icon: LucideIcons.mic,
            onPressed: widget.onVoiceSearch,
            style: IconButtonStyle.ghost,
            iconSize: _getIconSize(),
            tooltip: 'Voice Search',
          ),
        if (widget.enableBarcode)
          OnflixIconButton(
            icon: LucideIcons.scan,
            onPressed: widget.onBarcodeSearch,
            style: IconButtonStyle.ghost,
            iconSize: _getIconSize(),
            tooltip: 'Scan Barcode',
          ),
        if (widget.suffixIcon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: widget.suffixIcon!,
          ),
        if (widget.showFilters &&
            widget.filters != null &&
            widget.filters!.isNotEmpty)
          OnflixIconButton(
            icon: LucideIcons.listFilter,
            onPressed: () => _showFiltersDialog(context),
            style: IconButtonStyle.ghost,
            iconSize: _getIconSize(),
            tooltip: 'Filters',
            showBadge: _activeFilters.isNotEmpty,
            badgeText: _activeFilters.length.toString(),
          ),
      ],
    );
  }

  Widget _buildActiveFilters(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: _activeFilters.map((filter) {
          return FilterChip(
            label: Text(
              filter.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: OnflixColors.white,
                  ),
            ),
            onDeleted: () => _handleFilterToggled(filter),
            deleteIcon: const Icon(
              LucideIcons.x,
              size: 14,
              color: OnflixColors.white,
            ),
            backgroundColor: OnflixColors.primary,
            selectedColor: OnflixColors.primary,
            selected: true,
            onSelected: (bool value) {
              _handleFilterToggled(filter);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverlay() {
    return CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      offset: const Offset(0, 4),
      child: AnimatedBuilder(
        animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.topCenter,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surface,
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 300,
                    minWidth: 200,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: OnflixColors.lightGray.withOpacity(0.2),
                    ),
                  ),
                  child: _buildOverlayContent(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverlayContent() {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (widget.showHistory &&
            _currentQuery.isEmpty &&
            _filteredHistory.isNotEmpty) ...[
          _buildSectionHeader('Recent Searches'),
          ..._filteredHistory.map((item) => _buildHistoryItem(item)),
          if (_filteredSuggestions.isNotEmpty) const Divider(),
        ],
        if (widget.showSuggestions && _filteredSuggestions.isNotEmpty) ...[
          if (_currentQuery.isNotEmpty) _buildSectionHeader('Suggestions'),
          ..._filteredSuggestions
              .map((suggestion) => _buildSuggestionItem(suggestion)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: OnflixColors.lightGray,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSuggestionItem(String suggestion) {
    return InkWell(
      onTap: () => _handleSuggestionTapped(suggestion),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              LucideIcons.search,
              size: 16,
              color: OnflixColors.lightGray,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              LucideIcons.arrowUpLeft,
              size: 16,
              color: OnflixColors.lightGray,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String item) {
    return InkWell(
      onTap: () => _handleSuggestionTapped(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              LucideIcons.clock,
              size: 16,
              color: OnflixColors.lightGray,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFiltersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filters'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.filters!.map((filter) {
              return CheckboxListTile(
                value: filter.isActive,
                onChanged: (value) {
                  setState(() {
                    filter.isActive = value ?? false;
                  });
                  filter.onChanged?.call(filter.isActive);
                  Navigator.of(context).pop();
                },
                title: Text(filter.label),
                subtitle: filter.description != null
                    ? Text(filter.description!)
                    : null,
                activeColor: OnflixColors.primary,
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildDecoration(BuildContext context) {
    final borderColor = _isFocused
        ? (widget.focusedBorderColor ?? OnflixColors.primary)
        : (widget.borderColor ?? OnflixColors.lightGray.withOpacity(0.3));

    switch (widget.style) {
      case SearchInputStyle.outlined:
        return BoxDecoration(
          color: widget.backgroundColor ?? Colors.transparent,
          borderRadius: widget.borderRadius ?? _getDefaultBorderRadius(),
          border: Border.all(
            color: borderColor,
            width: _isFocused ? 2 : 1,
          ),
        );
      case SearchInputStyle.filled:
        return BoxDecoration(
          color: widget.backgroundColor ?? _getDefaultFillColor(context),
          borderRadius: widget.borderRadius ?? _getDefaultBorderRadius(),
          border: _isFocused ? Border.all(color: borderColor, width: 2) : null,
        );
      case SearchInputStyle.underlined:
        return BoxDecoration(
          color: widget.backgroundColor ?? Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: borderColor,
              width: _isFocused ? 2 : 1,
            ),
          ),
        );
    }
  }

  // Style getters
  TextStyle _getDefaultTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
  }

  TextStyle _getDefaultHintStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: OnflixColors.lightGray,
            ) ??
        const TextStyle();
  }

  Color _getDefaultFillColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? OnflixColors.mediumGray.withOpacity(0.3)
        : OnflixColors.veryLightGray.withOpacity(0.5);
  }

  BorderRadius _getDefaultBorderRadius() {
    return BorderRadius.circular(25);
  }

  EdgeInsetsGeometry _getDefaultContentPadding() {
    switch (widget.size) {
      case SearchInputSize.small:
        return const EdgeInsets.symmetric(vertical: 8);
      case SearchInputSize.medium:
        return const EdgeInsets.symmetric(vertical: 12);
      case SearchInputSize.large:
        return const EdgeInsets.symmetric(vertical: 16);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case SearchInputSize.small:
        return 18;
      case SearchInputSize.medium:
        return 20;
      case SearchInputSize.large:
        return 22;
    }
  }
}

/// Search filter model
class SearchFilter {
  final String id;
  final String label;
  final String? description;
  bool isActive;
  final ValueChanged<bool>? onChanged;

  SearchFilter({
    required this.id,
    required this.label,
    this.description,
    this.isActive = false,
    this.onChanged,
  });
}

/// Search input style enumeration
enum SearchInputStyle {
  outlined,
  filled,
  underlined,
}

/// Search input size enumeration
enum SearchInputSize {
  small,
  medium,
  large,
}
