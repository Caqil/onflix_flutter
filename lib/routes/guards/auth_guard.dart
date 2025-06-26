import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/common/widgets/loading/loading_spinner.dart';
import '../route_names.dart';

class AuthGuard extends ConsumerWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(RouteNames.login);
          });
          return const LoadingSpinner();
        }
        return child;
      },
      loading: () => const LoadingSpinner(),
      error: (error, stack) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(RouteNames.login);
        });
        return const LoadingSpinner();
      },
    );
  }
}
