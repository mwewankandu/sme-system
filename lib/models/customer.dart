import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final double creditBalance;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.creditBalance = 0.0,
    required this.createdAt,
  });

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Customer(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      creditBalance: (data['creditBalance'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'creditBalance': creditBalance,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Customer copyWith({
    String? name,
    String? phone,
    double? creditBalance,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      creditBalance: creditBalance ?? this.creditBalance,
      createdAt: createdAt,
    );
  }
}