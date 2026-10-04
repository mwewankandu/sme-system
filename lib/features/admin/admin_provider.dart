import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CORE PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

/// Checks if the currently logged-in user is an admin.
/// Returns true/false — used by AuthGate to route to AdminShell or MainShell.
final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final doc = await FirebaseFirestore.instance
      .collection('admins')
      .doc(user.uid)
      .get();

  return doc.exists;
});

/// Stream of all business user profiles — admin only.
final allUserProfilesProvider =
    StreamProvider<List<BusinessUserProfile>>((ref) {
  return FirebaseFirestore.instance
      .collection('userProfiles')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map(BusinessUserProfile.fromFirestore).toList());
});

/// System-wide stats computed from all user data — admin only.
final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final firestore = FirebaseFirestore.instance;

  // Get all user profiles
  final profilesSnap = await firestore.collection('userProfiles').get();
  final totalBusinesses = profilesSnap.docs.length;
  final disabledCount =
      profilesSnap.docs.where((d) => d['isDisabled'] == true).length;

  // Count total transactions across all users
  int totalTransactions = 0;
  double totalRevenue = 0.0;

  for (final profile in profilesSnap.docs) {
    final txSnap = await firestore
        .collection('users')
        .doc(profile.id)
        .collection('transactions')
        .get();
    totalTransactions += txSnap.docs.length;
    for (final tx in txSnap.docs) {
      totalRevenue += (tx['totalAmount'] ?? 0.0).toDouble();
    }
  }

  return AdminStats(
    totalBusinesses: totalBusinesses,
    activeBusinesses: totalBusinesses - disabledCount,
    disabledBusinesses: disabledCount,
    totalTransactions: totalTransactions,
    totalRevenue: totalRevenue,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// ADMIN STATS MODEL
// ─────────────────────────────────────────────────────────────────────────────

class AdminStats {
  final int totalBusinesses;
  final int activeBusinesses;
  final int disabledBusinesses;
  final int totalTransactions;
  final double totalRevenue;

  const AdminStats({
    required this.totalBusinesses,
    required this.activeBusinesses,
    required this.disabledBusinesses,
    required this.totalTransactions,
    required this.totalRevenue,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// ADMIN NOTIFIER — all admin actions
// ─────────────────────────────────────────────────────────────────────────────

class AdminNotifier extends AsyncNotifier<void> {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  @override
  Future<void> build() async {}

  // ── Disable a business account ────────────────────────────────────
  // Sets isDisabled: true in /userProfiles/{uid}
  // The user can still log in but all their Firestore reads will be
  // blocked by a Cloud Function (or you show a "suspended" screen
  // by checking this flag in AuthGate).
  Future<void> disableUser(String uid) async {
    await _db.collection('userProfiles').doc(uid).update({
      'isDisabled': true,
    });
  }

  // ── Re-enable a business account ─────────────────────────────────
  Future<void> enableUser(String uid) async {
    await _db.collection('userProfiles').doc(uid).update({
      'isDisabled': false,
    });
  }

  // ── Delete a business account and ALL their data ──────────────────
  // Deletes: userProfile + all products, customers, transactions
  Future<void> deleteUserAndData(String uid) async {
    final batch = _db.batch();

    // Delete userProfile
    batch.delete(_db.collection('userProfiles').doc(uid));

    // Delete all their products
    final products =
        await _db.collection('users').doc(uid).collection('products').get();
    for (final doc in products.docs) batch.delete(doc.reference);

    // Delete all their customers
    final customers =
        await _db.collection('users').doc(uid).collection('customers').get();
    for (final doc in customers.docs) batch.delete(doc.reference);

    // Delete all their transactions
    final transactions = await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .get();
    for (final doc in transactions.docs) batch.delete(doc.reference);

    // Delete the user document itself
    batch.delete(_db.collection('users').doc(uid));

    await batch.commit();

    // Note: Deleting the Firebase Auth account requires Admin SDK
    // (Cloud Function) — for now we disable it and show suspended screen
  }

  // ── Send password reset email ─────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ── View a specific business's data ───────────────────────────────
  // Returns all products for a given user uid
  Future<List<Map<String, dynamic>>> getUserProducts(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('products')
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  // Returns all transactions for a given user uid
  Future<List<Map<String, dynamic>>> getUserTransactions(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}

final adminNotifierProvider =
    AsyncNotifierProvider<AdminNotifier, void>(AdminNotifier.new);
