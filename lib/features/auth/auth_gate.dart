import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'login_screen.dart';
import '../shell/main_shell.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Auth error: $e')),
      ),
      data: (user) {
        if (user == null) return const LoginScreen();

        // Key forces Flutter to rebuild the entire shell
        // with fresh providers every time the user changes
        return ProviderScope(
          key: ValueKey(user.uid),
          overrides: [],
          child: const MainShell(),
        );
      },
    );
  }
}