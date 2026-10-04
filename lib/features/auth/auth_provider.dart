// lib/features/auth/auth_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits the signed-in User, or null when signed out.
final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

/// UID used by every data provider to build /users/{uid}/... paths.
final currentUserIdProvider = Provider<String>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid ?? '';
});

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyError(e.code));
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // NEW: save a profile document so the admin can see this account.
      // Wrapped separately: if this write fails, sign-up still succeeds
      // and AuthGate will create the profile on first login anyway.
      try {
        await FirebaseFirestore.instance
            .collection('userProfiles')
            .doc(credential.user!.uid)
            .set({
          'email': email.trim(),
          'businessName': 'My Business', // changed later in Settings
          'createdAt': FieldValue.serverTimestamp(),
          'isDisabled': false,
        });
      } catch (_) {}
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyError(e.code));
    }
  }

  Future<void> signOut() => FirebaseAuth.instance.signOut();

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password';
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'network-request-failed':
        return 'No internet connection';
      default:
        return 'Something went wrong. Please try again';
    }
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);
