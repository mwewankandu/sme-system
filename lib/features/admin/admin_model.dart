import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an admin account stored in /admins/{uid}
class AdminUser {
  final String uid;
  final String email;
  final String name;
  final DateTime createdAt;

  const AdminUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  factory AdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUser(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

/// Represents a business user account stored in /userProfiles/{uid}
class BusinessUserProfile {
  final String uid;
  final String email;
  final String businessName;
  final DateTime createdAt;
  final bool isDisabled;

  const BusinessUserProfile({
    required this.uid,
    required this.email,
    required this.businessName,
    required this.createdAt,
    this.isDisabled = false,
  });

  factory BusinessUserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BusinessUserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      businessName: data['businessName'] ?? 'Unnamed Business',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isDisabled: data['isDisabled'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'businessName': businessName,
        'createdAt': Timestamp.fromDate(createdAt),
        'isDisabled': isDisabled,
      };

  BusinessUserProfile copyWith({bool? isDisabled}) => BusinessUserProfile(
        uid: uid,
        email: email,
        businessName: businessName,
        createdAt: createdAt,
        isDisabled: isDisabled ?? this.isDisabled,
      );
}
