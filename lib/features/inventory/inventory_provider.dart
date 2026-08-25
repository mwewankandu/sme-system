import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../auth/auth_provider.dart';

// Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// User's products collection reference
final productsCollectionProvider = Provider<CollectionReference>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final userId = ref.watch(currentUserIdProvider);
  return firestore
      .collection('users')
      .doc(userId)
      .collection('products');
});

// Real-time stream of current user's products
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final collection = ref.watch(productsCollectionProvider);
  return collection
      .orderBy('name')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
});

// Inventory operations
class InventoryNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addProduct(Product product) async {
    final collection = ref.read(productsCollectionProvider);
    await collection.add(product.toFirestore());
  }

  Future<void> updateProduct(Product product) async {
    final collection = ref.read(productsCollectionProvider);
    await collection.doc(product.id).update(product.toFirestore());
  }

  Future<void> deleteProduct(String productId) async {
    final collection = ref.read(productsCollectionProvider);
    await collection.doc(productId).delete();
  }

  Future<void> restockProduct(
      String productId, int quantityToAdd) async {
    final collection = ref.read(productsCollectionProvider);
    await collection.doc(productId).update({
      'stockQuantity': FieldValue.increment(quantityToAdd),
    });
  }
}

final inventoryNotifierProvider =
    AsyncNotifierProvider<InventoryNotifier, void>(InventoryNotifier.new);