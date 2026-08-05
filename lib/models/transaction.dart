import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentMethod { cash, credit, mobileMoney }

class SaleTransaction {
  final String id;
  final List<TransactionItem> items;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final String? customerId;
  final DateTime createdAt;

  SaleTransaction({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    this.customerId,
    required this.createdAt,
  });

  factory SaleTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SaleTransaction(
      id: doc.id,
      items: (data['items'] as List)
          .map((i) => TransactionItem.fromMap(i))
          .toList(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == data['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      customerId: data['customerId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod.name,
      'customerId': customerId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class TransactionItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  TransactionItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => quantity * unitPrice;

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}