import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/customer.dart';
import '../inventory/inventory_provider.dart';

final customersStreamProvider = StreamProvider<List<Customer>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('customers')
      .orderBy('name')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList());
});

class CustomerNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addCustomer(Customer customer) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection('customers').add(customer.toFirestore());
  }

  Future<void> updateCustomer(Customer customer) async {
    final firestore = ref.read(firestoreProvider);
    await firestore
        .collection('customers')
        .doc(customer.id)
        .update(customer.toFirestore());
  }

  Future<void> deleteCustomer(String customerId) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection('customers').doc(customerId).delete();
  }

  Future<void> recordPayment(String customerId, double amount) async {
    final firestore = ref.read(firestoreProvider);
    final doc = await firestore.collection('customers').doc(customerId).get();
    final customer = Customer.fromFirestore(doc);
    final newBalance = (customer.creditBalance - amount).clamp(0.0, double.infinity);
    await firestore
        .collection('customers')
        .doc(customerId)
        .update({'creditBalance': newBalance});
  }
}

final customerNotifierProvider =
    AsyncNotifierProvider<CustomerNotifier, void>(CustomerNotifier.new);