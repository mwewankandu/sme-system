import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stockQuantity;
  final int lowStockThreshold;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stockQuantity,
    this.lowStockThreshold = 5,
    required this.createdAt,
  });

  // Convert Firestore document → Product object
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      stockQuantity: data['stockQuantity'] ?? 0,
      lowStockThreshold: data['lowStockThreshold'] ?? 5,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert Product object → Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'stockQuantity': stockQuantity,
      'lowStockThreshold': lowStockThreshold,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create a copy with updated fields
  Product copyWith({
    String? name,
    String? category,
    double? price,
    int? stockQuantity,
    int? lowStockThreshold,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt,
    );
  }

  bool get isLowStock => stockQuantity <= lowStockThreshold;
}