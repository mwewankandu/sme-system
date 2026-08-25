import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/customer.dart';
import '../auth/auth_provider.dart';
import '../inventory/inventory_provider.dart';

// User's customers collection reference
final customersCollectionProvider = Provider<CollectionReference>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider);
  return firestore
      .collection('users')
      .doc(userId)
      .collection('customers');
});

final customersStreamProvider = StreamProvider<List<Customer>>((ref) {
  final collection = ref.watch(customersCollectionProvider);
  return collection
      .orderBy('name')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList());
});

class CustomerNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addCustomer(Customer customer) async {
    final collection = ref.read(customersCollectionProvider);
    await collection.add(customer.toFirestore());
  }

  Future<void> updateCustomer(Customer customer) async {
    final collection = ref.read(customersCollectionProvider);
    await collection.doc(customer.id).update(customer.toFirestore());
  }

  Future<void> deleteCustomer(String customerId) async {
    final collection = ref.read(customersCollectionProvider);
    await collection.doc(customerId).delete();
  }

  Future<void> recordPayment(
      String customerId, double amount) async {
    final collection = ref.read(customersCollectionProvider);
    final doc = await collection.doc(customerId).get();
    final customer = Customer.fromFirestore(doc);
    final newBalance =
        (customer.creditBalance - amount).clamp(0.0, double.infinity);
    await collection
        .doc(customerId)
        .update({'creditBalance': newBalance});
  }
}

final customerNotifierProvider =
    AsyncNotifierProvider<CustomerNotifier, void>(CustomerNotifier.new);