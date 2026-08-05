import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';

// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Real-time stream of all products
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('products')
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
    final firestore = ref.read(firestoreProvider);
    await firestore.collection('products').add(product.toFirestore());
  }

  Future<void> updateProduct(Product product) async {
    final firestore = ref.read(firestoreProvider);
    await firestore
        .collection('products')
        .doc(product.id)
        .update(product.toFirestore());
  }

  Future<void> deleteProduct(String productId) async {
    final firestore = ref.read(firestoreProvider);
    await firestore.collection('products').doc(productId).delete();
  }
  
  Future<void> restockProduct(String productId, int quantityToAdd) async {
  final firestore = ref.read(firestoreProvider);
  await firestore.collection('products').doc(productId).update({
    'stockQuantity': FieldValue.increment(quantityToAdd),
  });
}
}

final inventoryNotifierProvider =
    AsyncNotifierProvider<InventoryNotifier, void>(InventoryNotifier.new);