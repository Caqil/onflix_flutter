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

/// Admin login page with secure authentication for administrative access
class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    // Check if already authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isAuthenticated = ref.read(isAdminAuthenticatedProvider);
      if (isAuthenticated) {
        context.go(RouteNames.admin);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(adminAuthProvider);
    
    return Scaffold(
      body: ResponsiveHelper.buildResponsive(
        context,
        mobile: _buildMobileLayout(context, authState),
        tablet: _buildTabletLayout(context, authState),
        desktop: _buildDesktopLayout(context, authState),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AsyncValue authState) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildLogo(context),
            const SizedBox(height: 40),
            _buildLoginForm(context, authState),
            const SizedBox(height: 24),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, AsyncValue authState) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                _buildLogo(context),
                const SizedBox(height: 48),
                _buildLoginForm(context, authState),
                const SizedBox(height: 32),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AsyncValue authState) {
    return Row(
      children: [
        // Left side - Branding
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.colorScheme.primary,
                  context.colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    LucideIcons.shield,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Admin Portal',
                  style: context.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Secure access to manage your Onflix platform',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                _buildFeatureList(context),
              ],
            ),
          ),
        ),
        
        // Right side - Login form
        Expanded(
          flex: 2,
          child: Container(
            color: context.colorScheme.surface,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLoginHeader(context),
                      const SizedBox(height: 32),
                      _buildLoginForm(context, authState),
                      const SizedBox(height: 32),
                      _buildFooter(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: context.colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            LucideIcons.shield,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Onflix Admin',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Administrative Access Portal',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back',
          style: context.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to your admin account to continue',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, AsyncValue authState) {
    final isLoading = authState.isLoading;

    return ShadCard(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!ResponsiveHelper.isDesktop(context)) ...[
                Text(
                  'Sign In',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your credentials to access the admin panel',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],

              // Email field
              _buildEmailField(context, isLoading),
              const SizedBox(height: 20),

              // Password field
              _buildPasswordField(context, isLoading),
              const SizedBox(height: 20),

              // Remember me checkbox
              _buildRememberMeCheckbox(context, isLoading),
              const SizedBox(height: 32),

              // Login button
              _buildLoginButton(context, isLoading),
              
              // Error message
              if (authState.hasError) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(context, authState.error.toString()),
              ],

              const SizedBox(height: 24),
              _buildDivider(context),
              const SizedBox(height: 24),

              // Security notice
              _buildSecurityNotice(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField(BuildContext context, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ShadInput(
          controller: _emailController,
          placeholder: 'admin@onflix.com',
          keyboardType: TextInputType.emailAddress,
          enabled: !isLoading,
          prefix: Icon(
            LucideIcons.mail,
            size: 18,
            color: context.colorScheme.onSurface.withOpacity(0.5),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ShadInput(
          controller: _passwordController,
          placeholder: 'Enter your password',
          obscureText: !_isPasswordVisible,
          enabled: !isLoading,
          prefix: Icon(
            LucideIcons.lock,
            size: 18,
            color: context.colorScheme.onSurface.withOpacity(0.5),
          ),
          suffix: ShadButton.ghost(
            onPressed: isLoading ? null : () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            child: Icon(
              _isPasswordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
              size: 18,
              color: context.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
          onSubmitted: (_) => _handleLogin(),
        ),
      ],
    );
  }

  Widget _buildRememberMeCheckbox(BuildContext context, bool isLoading) {
    return Row(
      children: [
        ShadCheckbox(
          value: _rememberMe,
          onChanged: isLoading ? null : (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Remember me for 30 days',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        ShadButton.ghost(
          onPressed: isLoading ? null : _showForgotPasswordDialog,
          child: Text(
            'Forgot password?',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context, bool isLoading) {
    return ShadButton(
      onPressed: isLoading ? null : _handleLogin,
      width: double.infinity,
      size: ShadButtonSize.lg,
      child: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Signing in...'),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.shield, size: 18),
                const SizedBox(width: 8),
                Text('Sign In to Admin Panel'),
              ],
            ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 20,
            color: context.colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: context.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Secure Access',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: context.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.shieldCheck,
            size: 18,
            color: context.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This is a secure admin area. All activities are logged and monitored.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: LucideIcons.users,
        title: 'User Management',
        description: 'Manage user accounts and permissions',
      ),
      _FeatureItem(
        icon: LucideIcons.barChart3,
        title: 'Analytics Dashboard',
        description: 'Monitor platform performance and metrics',
      ),
      _FeatureItem(
        icon: LucideIcons.fileText,
        title: 'Content Control',
        description: 'Upload and manage video content',
      ),
      _FeatureItem(
        icon: LucideIcons.shield,
        title: 'Security Controls',
        description: 'Configure security and access policies',
      ),
    ];

    return Column(
      children: features
          .map((feature) => _buildFeatureItem(context, feature))
          .toList(),
    );
  }

  Widget _buildFeatureItem(BuildContext context, _FeatureItem feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature.icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Need help? ',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            ShadButton.ghost(
              onPressed: _showSupportDialog,
              child: Text(
                'Contact Support',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '© 2024 Onflix. All rights reserved.',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurface.withOpacity(0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(adminAuthProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (mounted) {
        context.go(RouteNames.admin);
      }
    } catch (e) {
      // Error is handled by the provider and displayed in the UI
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: Text('Password Reset'),
        description: Text(
          'For security reasons, password reset must be requested through your system administrator.',
        ),
        actions: [
          ShadButton.ghost(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ShadButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSupportDialog();
            },
            child: Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => ShadDialog(
        title: Text('Admin Support'),
        description: Text(
          'For admin account issues, please contact your system administrator or technical support team.',
        ),
        actions: [
          ShadButton.ghost(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          ShadButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Could open email client or support portal
            },
            child: Text('Send Email'),
          ),
        ],
      ),
    );
  }
}

// Helper class for feature items
class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}