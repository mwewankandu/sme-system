// lib/features/auth/auth_gate.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'login_screen.dart';                 // adjust path if different
import '../shell/main_shell.dart';          // adjust path if different
import '../admin/admin_shell.dart';         // adjust path if different

enum AccessStatus { admin, suspended, active }

/// Decides what this user is allowed to see. Runs once per login.
final accessStatusProvider =
    FutureProvider.autoDispose.family<AccessStatus, String>((ref, uid) async {
  final db = FirebaseFirestore.instance;

  // 1. Admin?
  final adminDoc = await db.collection('admins').doc(uid).get();
  if (adminDoc.exists) return AccessStatus.admin;

  // 2. Regular user: make sure a profile exists (covers accounts that
  //    were created before the admin module existed).
  final profileRef = db.collection('userProfiles').doc(uid);
  final profile = await profileRef.get();

  if (!profile.exists) {
    await profileRef.set({
      'email': FirebaseAuth.instance.currentUser?.email ?? '',
      'businessName': 'My Business',
      'createdAt': FieldValue.serverTimestamp(),
      'isDisabled': false,
    });
    return AccessStatus.active;
  }

  // 3. Suspended?
  final disabled = profile.data()?['isDisabled'] == true;
  return disabled ? AccessStatus.suspended : AccessStatus.active;
});

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      loading: _loading,
      error: (e, _) => Scaffold(body: Center(child: Text('Auth error: $e'))),
      data: (user) {
        if (user == null) return const LoginScreen();

        final statusAsync = ref.watch(accessStatusProvider(user.uid));

        return statusAsync.when(
          loading: _loading,
          error: (e, _) => Scaffold(
            body: Center(child: Text('Could not load your account: $e')),
          ),
          data: (status) {
            switch (status) {
              case AccessStatus.admin:
                return const AdminShell();
              case AccessStatus.suspended:
                return _SuspendedScreen(email: user.email ?? '');
              case AccessStatus.active:
                // ValueKey resets all providers when the user changes
                return ProviderScope(
                  key: ValueKey(user.uid),
                  child: const MainShell(),
                );
            }
          },
        );
      },
    );
  }

  Widget _loading() =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _SuspendedScreen extends StatelessWidget {
  final String email;
  const _SuspendedScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 72, color: Colors.red),
              const SizedBox(height: 24),
              const Text('Account Suspended',
                  style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'Your account ($email) has been suspended. '
                'Please contact the system administrator.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
