import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transaction.dart';
import '../auth/auth_provider.dart';
import '../inventory/inventory_provider.dart';
import '../customers/customer_provider.dart';

// User's transactions collection reference
final transactionsCollectionProvider =
    Provider<CollectionReference>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider);
  return firestore
      .collection('users')
      .doc(userId)
      .collection('transactions');
});

// Real-time stream of current user's transactions
final transactionsStreamProvider =
    StreamProvider<List<SaleTransaction>>((ref) {
  final collection = ref.watch(transactionsCollectionProvider);
  return collection
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => SaleTransaction.fromFirestore(doc))
          .toList());
});

// Transactions for a specific customer
final customerTransactionsProvider =
    StreamProvider.family<List<SaleTransaction>, String>(
        (ref, customerId) {
  final collection = ref.watch(transactionsCollectionProvider);
  return collection
      .where('customerId', isEqualTo: customerId)
      .where('paymentMethod', isEqualTo: 'credit')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => SaleTransaction.fromFirestore(doc))
          .toList());
});

// Cart
final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartItem {
  final String productId;
  final String productName;
  final double unitPrice;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    this.quantity = 1,
  });

  double get subtotal => unitPrice * quantity;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(CartItem item) {
    final existing =
        state.indexWhere((i) => i.productId == item.productId);
    if (existing >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existing)
            CartItem(
              productId: state[i].productId,
              productName: state[i].productName,
              unitPrice: state[i].unitPrice,
              quantity: state[i].quantity + 1,
            )
          else
            state[i]
      ];
    } else {
      state = [...state, item];
    }
  }

  void removeItem(String productId) {
    state = state.where((i) => i.productId != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.productId == productId)
          CartItem(
            productId: item.productId,
            productName: item.productName,
            unitPrice: item.unitPrice,
            quantity: quantity,
          )
        else
          item
    ];
  }

  void clear() => state = [];

  double get total =>
      state.fold(0.0, (sum, item) => sum + item.subtotal);
}

// Sales operations
class SalesNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> recordSale({
    required List<CartItem> items,
    required PaymentMethod paymentMethod,
    String? customerId,
  }) async {
    final firestore = ref.read(firestoreProvider);
    final userId = ref.read(currentUserIdProvider);
    final batch = firestore.batch();

    final userRef = firestore.collection('users').doc(userId);

    // 1. Create transaction
    final transactionRef =
        userRef.collection('transactions').doc();
    final transaction = SaleTransaction(
      id: transactionRef.id,
      items: items
          .map((i) => TransactionItem(
                productId: i.productId,
                productName: i.productName,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
              ))
          .toList(),
      totalAmount:
          items.fold(0.0, (sum, i) => sum + i.subtotal),
      paymentMethod: paymentMethod,
      customerId: customerId,
      createdAt: DateTime.now(),
    );
    batch.set(transactionRef, transaction.toFirestore());

    // 2. Deduct stock
    for (final item in items) {
      final productRef =
          userRef.collection('products').doc(item.productId);
      batch.update(productRef, {
        'stockQuantity': FieldValue.increment(-item.quantity),
      });
    }

    // 3. Update customer credit balance
    if (paymentMethod == PaymentMethod.credit &&
        customerId != null) {
      final customerRef =
          userRef.collection('customers').doc(customerId);
      batch.update(customerRef, {
        'creditBalance':
            FieldValue.increment(transaction.totalAmount),
      });
    }

    await batch.commit();
    ref.read(cartProvider.notifier).clear();
  }
}

final salesNotifierProvider =
    AsyncNotifierProvider<SalesNotifier, void>(SalesNotifier.new);