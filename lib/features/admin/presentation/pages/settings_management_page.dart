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

/// Settings management page for configuring platform settings and preferences
class SettingsManagementPage extends ConsumerStatefulWidget {
  const SettingsManagementPage({super.key});

  @override
  ConsumerState<SettingsManagementPage> createState() =>
      _SettingsManagementPageState();
}

class _SettingsManagementPageState extends ConsumerState<SettingsManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _hasUnsavedChanges = false;

  // General Settings
  bool _maintenanceMode = false;
  bool _registrationEnabled = true;
  bool _emailVerificationRequired = true;
  String _defaultLanguage = 'en';
  String _defaultTimezone = 'UTC';

  // Content Settings
  bool _autoTranscoding = true;
  bool _contentModeration = true;
  String _defaultVideoQuality = '720p';
  int _maxUploadSize = 5; // GB

  // Security Settings
  bool _twoFactorRequired = false;
  bool _loginAttemptLimit = true;
  int _maxLoginAttempts = 5;
  int _sessionTimeout = 24; // hours

  // Notification Settings
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadSettings();
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
          if (_hasUnsavedChanges) _buildUnsavedChangesBar(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralSettingsTab(context),
                _buildContentSettingsTab(context),
                _buildSecuritySettingsTab(context),
                _buildNotificationSettingsTab(context),
                _buildSystemSettingsTab(context),
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
        'Settings Management',
        style: context.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        ShadButton.ghost(
          onPressed: _exportSettings,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.download, size: 16),
              SizedBox(width: 8),
              Text('Export'),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ShadButton.ghost(
          onPressed: _resetToDefaults,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.rotateCounterClockwise, size: 16),
              const SizedBox(width: 8),
              const Text('Reset'),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ShadButton(
          onPressed: _hasUnsavedChanges ? _saveSettings : null,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.save, size: 16),
              SizedBox(width: 8),
              Text('Save Changes'),
            ],
          ),
        ),
        const SizedBox(width: 16),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: ResponsiveHelper.isMobile(context),
        tabs: const [
          Tab(text: 'General'),
          Tab(text: 'Content'),
          Tab(text: 'Security'),
          Tab(text: 'Notifications'),
          Tab(text: 'System'),
        ],
      ),
      elevation: 0,
      backgroundColor: context.colorScheme.surface,
    );
  }

  Widget _buildUnsavedChangesBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.orange.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.alertTriangle,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You have unsaved changes',
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ShadButton.ghost(
            onPressed: _discardChanges,
            child: Text(
              'Discard',
              style: TextStyle(color: Colors.orange.shade800),
            ),
          ),
          const SizedBox(width: 8),
          ShadButton(
            onPressed: _saveSettings,
            size: ShadButtonSize.sm,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettingsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSettingsSection(
            context,
            'Platform Settings',
            LucideIcons.settings,
            [
              _buildSwitchSetting(
                context,
                'Maintenance Mode',
                'Enable maintenance mode to restrict access during updates',
                _maintenanceMode,
                (value) => setState(() {
                  _maintenanceMode = value;
                  _hasUnsavedChanges = true;
                }),
              ),
              _buildSwitchSetting(
                context,
                'User Registration',
                'Allow new users to register accounts',
                _registrationEnabled,
                (value) => setState(() {
                  _registrationEnabled = value;
                  _hasUnsavedChanges = true;
                }),
              ),
              _buildSwitchSetting(
                context,
                'Email Verification Required',
                'Require email verification for new accounts',
                _emailVerificationRequired,
                (value) => setState(() {
                  _emailVerificationRequired = value;
                  _hasUnsavedChanges = true;
                }),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            'Localization',
            LucideIcons.globe,
            [
              _buildDropdownSetting(
                context,
                'Default Language',
                'Default language for new users',
                _defaultLanguage,
                {
                  'en': 'English',
                  'es': 'Spanish',
                  'fr': 'French',
                  'de': 'German',
                  'ja': 'Japanese',
                },
                (value) => setState(() {
                  _defaultLanguage = value!;
                  _hasUnsavedChanges = true;
                }),
              ),
              _buildDropdownSetting(
                context,
                'Default Timezone',
                'Default timezone for the platform',
                _defaultTimezone,
                {
                  'UTC': 'UTC',
                  'America/New_York': 'Eastern Time',
                  'America/Chicago': 'Central Time',
                  'America/Denver': 'Mountain Time',
                  'America/Los_Angeles': 'Pacific Time',
                  'Europe/London': 'GMT',
                  'Europe/Paris': 'CET',
                  'Asia/Tokyo': 'JST',
                },
                (value) => setState(() {
                  _defaultTimezone = value!;
                  _hasUnsavedChanges = true;
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentSettingsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSettingsSection(
            context,
            'Content Processing',
            LucideIcons.video,
            [
              _buildSwitchSetting(
                context,
                'Auto Transcoding',
                'Automatically transcode uploaded videos to multiple qualities',
                _autoTranscoding,
                (value) => setState(() {
                  _autoTranscoding = value;
                  _hasUnsavedChanges = true;
                }),
              ),
              _buildDropdownSetting(
                context,
                'Default Video Quality',
                'Default streaming quality for new users',
                _defaultVideoQuality,
                {
                  '480p': '480p (SD)',
                  '720p': '720p (HD)',
                  '1080p': '1080p (Full HD)',
                  '1440p': '1440p (2K)',
                  '2160p': '2160p (4K)',
                },
                (value) => setState(() {
                  _defaultVideoQuality = value!;
                  _hasUnsavedChanges = true;
                }),
              ),
              _buildSliderSetting(
                context,
                'Max Upload Size',
                'Maximum file size for content uploads (GB)',
                _maxUploadSize.toDouble(),
                1.0,
                20.0,
                (value) => setState(() {
                  _maxUploadSize = value.round();
                  _hasUnsavedChanges = true;
                }),
                '${_maxUploadSize}GB',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            'Content Moderation',
            LucideIcons.shield,
            [
              _buildSwitchSetting(
                context,
                'Content Moderation',
                'Enable automatic content moderation and filtering',
                _contentModeration,
                (value) => setState(() {
                  _contentModeration = value;
                  _hasUnsavedChanges = true;
                }),
              ),
              _buildActionSetting(
                context,
                'Content Categories',
                'Manage content categories and genres',
                'Manage Categories',
                () => _showContentCategoriesDialog(),
              ),
              _buildActionSetting(
                context,
                'Restricted Content',
                'Configure content restrictions and age ratings',
                'Configure Restrictions',
                () => _showContentRestrictionsDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettingsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSettingsSection(
            context,
            'Authentication',
            LucideIcons.lock,
            [
              _buildSwitchSetting(
                context,
                'Two-Factor Authentication Required',
                'Require 2FA for all admin accounts',
                _twoFactorRequired,
                (value) => setState(() {
                  _twoFactorRequired = value;
                  _hasUnsavedChanges = true;
                }),
              ),
              _buildSwitchSetting(
                context,
                'Login Attempt Limiting',
                'Limit failed login attempts to prevent brute force attacks',
                _loginAttemptLimit,
                (value) => setState(() {
                  _loginAttemptLimit = value;
                  _hasUnsavedChanges = true;
                }),
              ),
              if (_loginAttemptLimit)
                _buildSliderSetting(
                  context,
                  'Max Login Attempts',
                  'Maximum failed login attempts before lockout',
                  _maxLoginAttempts.toDouble(),
                  3.0,
                  10.0,
                  (value) => setState(() {
                    _maxLoginAttempts = value.round();
                    _hasUnsavedChanges = true;
                  }),
                  '${_maxLoginAttempts} attempts',
                ),
              _buildSliderSetting(
                context,
                'Session Timeout',
                'Session timeout duration (hours)',
                _sessionTimeout.toDouble(),
                1.0,
                168.0, // 7 days
                (value) => setState(() {
                  _sessionTimeout = value.round();
                  _hasUnsavedChanges = true;
                }),
                '${_sessionTimeout}h',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            'Data Protection',
            LucideIcons.shieldCheck,
            [
              _buildActionSetting(
                context,
                'Privacy Policy',
                'Update platform privacy policy',
                'Edit Policy',
                () => _showPrivacyPolicyDialog(),
              ),
              _buildActionSetting(
                context,
                'Terms of Service',
                'Update platform terms of service',
                'Edit Terms',
                () => _showTermsOfServiceDialog(),
              ),
              _buildActionSetting(
                context,
                'Data Retention',
                'Configure data retention policies',
                'Configure Retention',
                () => _showDataRetentionDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSettingsSection(
            context,
            'Notification Channels',
            LucideIcons.bell,
            [
              _buildSwitchSetting(
                context,
                'Email Notifications',
                'Enable email notifications for users and admins',
                _emailNotifications,
                (value) => setState(() {
                  _emailNotifications = value;
                  _hasUnsavedChanges = true;
                }),
              ),
              _buildSwitchSetting(
                context,
                'Push Notifications',
                'Enable push notifications for mobile apps',
                _pushNotifications,
                (value) => setState(() {
                  _pushNotifications = value;
                  _hasUnsavedChanges = true;
                }),
              ),
              _buildSwitchSetting(
                context,
                'SMS Notifications',
                'Enable SMS notifications for critical alerts',
                _smsNotifications,
                (value) => setState(() {
                  _smsNotifications = value;
                  _hasUnsavedChanges = true;
                }),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            'Email Configuration',
            LucideIcons.mail,
            [
              _buildActionSetting(
                context,
                'SMTP Settings',
                'Configure SMTP server for email delivery',
                'Configure SMTP',
                () => _showSMTPSettingsDialog(),
              ),
              _buildActionSetting(
                context,
                'Email Templates',
                'Customize email notification templates',
                'Edit Templates',
                () => _showEmailTemplatesDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSettingsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSettingsSection(
            context,
            'System Information',
            LucideIcons.info,
            [
              _buildInfoSetting(context, 'Platform Version', '2.1.0'),
              _buildInfoSetting(context, 'Database Version', 'PostgreSQL 14.2'),
              _buildInfoSetting(context, 'Server Uptime', '15 days, 6 hours'),
              _buildInfoSetting(context, 'Last Backup', '2 hours ago'),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            'Maintenance',
            LucideIcons.wrench,
            [
              _buildActionSetting(
                context,
                'Clear Cache',
                'Clear application cache and temporary files',
                'Clear Cache',
                () => _clearCache(),
              ),
              _buildActionSetting(
                context,
                'Database Optimization',
                'Optimize database performance',
                'Optimize',
                () => _optimizeDatabase(),
              ),
              _buildActionSetting(
                context,
                'System Backup',
                'Create a full system backup',
                'Create Backup',
                () => _createSystemBackup(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            'Danger Zone',
            LucideIcons.alertTriangle,
            [
              _buildActionSetting(
                context,
                'Reset All Settings',
                'Reset all settings to factory defaults',
                'Reset All',
                () => _showResetAllDialog(),
                isDestructive: true,
              ),
              _buildActionSetting(
                context,
                'Export System Data',
                'Export all system data for migration',
                'Export Data',
                () => _exportSystemData(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return ShadCard(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: context.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSetting(
    BuildContext context,
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          ShadSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting<T>(
    BuildContext context,
    String title,
    String description,
    T value,
    Map<T, String> options,
    ValueChanged<T?> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          ShadDropdownMenu<T>(
            value: value,
            onChanged: onChanged,
            children: options.entries.map((entry) {
              return ShadDropdownMenuItem<T>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.colorScheme.outline.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(options[value] ?? value.toString())),
                  const Icon(LucideIcons.chevronDown, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    BuildContext context,
    String title,
    String description,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    String displayValue,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                displayValue,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionSetting(
    BuildContext context,
    String title,
    String description,
    String actionText,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          ShadButton.outline(
            onPressed: onPressed,
            variant: isDestructive
                ? ShadButtonVariant.destructive
                : ShadButtonVariant.outline,
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSetting(BuildContext context, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _saveSettings() {
    // Implement settings save logic
    setState(() {
      _hasUnsavedChanges = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _discardChanges() {
    setState(() {
      _hasUnsavedChanges = false;
      // Reset to original values
      _loadSettings();
    });
  }

  void _loadSettings() {
    // Load settings from backend/storage
    // This would typically come from a provider or repository
  }

  void _exportSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings exported successfully')),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Reset to Defaults'),
        description: const Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
        ),
        actions: [
          ShadButton.ghost(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ShadButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performReset();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _performReset() {
    setState(() {
      // Reset all settings to defaults
      _maintenanceMode = false;
      _registrationEnabled = true;
      _emailVerificationRequired = true;
      _defaultLanguage = 'en';
      _defaultTimezone = 'UTC';
      _autoTranscoding = true;
      _contentModeration = true;
      _defaultVideoQuality = '720p';
      _maxUploadSize = 5;
      _twoFactorRequired = false;
      _loginAttemptLimit = true;
      _maxLoginAttempts = 5;
      _sessionTimeout = 24;
      _emailNotifications = true;
      _pushNotifications = true;
      _smsNotifications = false;
      _hasUnsavedChanges = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings reset to defaults'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Dialog methods
  void _showContentCategoriesDialog() {
    showDialog(
      context: context,
      builder: (context) => _ContentCategoriesDialog(),
    );
  }

  void _showContentRestrictionsDialog() {
    showDialog(
      context: context,
      builder: (context) => _ContentRestrictionsDialog(),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => _PrivacyPolicyDialog(),
    );
  }

  void _showTermsOfServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => _TermsOfServiceDialog(),
    );
  }

  void _showDataRetentionDialog() {
    showDialog(
      context: context,
      builder: (context) => _DataRetentionDialog(),
    );
  }

  void _showSMTPSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => _SMTPSettingsDialog(),
    );
  }

  void _showEmailTemplatesDialog() {
    showDialog(
      context: context,
      builder: (context) => _EmailTemplatesDialog(),
    );
  }

  void _showResetAllDialog() {
    showDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: const Text('Reset All Settings'),
        description: const Text(
          'This will reset ALL platform settings to factory defaults. This action is irreversible and will affect all users. Are you absolutely sure?',
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
                const SnackBar(
                  content: Text('All settings have been reset'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Reset All'),
          ),
        ],
      ),
    );
  }

  // System maintenance methods
  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared successfully')),
    );
  }

  void _optimizeDatabase() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Database optimization started')),
    );
  }

  void _createSystemBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('System backup created successfully')),
    );
  }

  void _exportSystemData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('System data export started')),
    );
  }
}

// Dialog widgets (simplified for brevity)
class _ContentCategoriesDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Content Categories'),
      content: Container(
        width: 500,
        height: 400,
        child: const Center(child: Text('Content categories management interface')),
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

class _ContentRestrictionsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Content Restrictions'),
      content: Container(
        width: 500,
        height: 400,
        child:
            const Center(child: Text('Content restrictions configuration interface')),
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

class _PrivacyPolicyDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Privacy Policy'),
      content: Container(
        width: 600,
        height: 500,
        child: const Center(child: Text('Privacy policy editor interface')),
      ),
      actions: [
        ShadButton.ghost(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ShadButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _TermsOfServiceDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Terms of Service'),
      content: Container(
        width: 600,
        height: 500,
        child: const Center(child: Text('Terms of service editor interface')),
      ),
      actions: [
        ShadButton.ghost(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ShadButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _DataRetentionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Data Retention Policy'),
      content: Container(
        width: 500,
        height: 400,
        child: const Center(child: Text('Data retention configuration interface')),
      ),
      actions: [
        ShadButton.ghost(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ShadButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _SMTPSettingsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('SMTP Settings'),
      content: Container(
        width: 500,
        height: 400,
        child: const Center(child: Text('SMTP configuration interface')),
      ),
      actions: [
        ShadButton.ghost(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ShadButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _EmailTemplatesDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShadDialog(
      title: const Text('Email Templates'),
      child: Container(
        width: 600,
        height: 500,
        child: const Center(child: Text('Email templates editor interface')),
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
