import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/admin/presentation/providers/admin_auth_provider.dart';
import '../../features/common/widgets/loading/loading_spinner.dart';
import '../route_names.dart';

class AdminGuard extends ConsumerWidget {
  final Widget child;

  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminAuthState = ref.watch(adminAuthStateProvider);

    return adminAuthState.when(
      data: (admin) {
        if (admin == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(RouteNames.adminLogin);
          });
          return const LoadingSpinner();
        }
        return child;
      },
      loading: () => const LoadingSpinner(),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(RouteNames.adminLogin);
        });
        return const LoadingSpinner();
      },
    );
  }
}
