import 'package:cloud_firestore/cloud_firestore.dart';

class ParentModel {
  final String id;
  final String userId;
  final String? phoneNumber;
  final String? address;
  final int numberOfChildren;
  final List<int> childrenAges;
  final String? specialRequirements;
  final DateTime createdAt;

  ParentModel({
    required this.id,
    required this.userId,
    this.phoneNumber,
    this.address,
    this.numberOfChildren = 0,
    this.childrenAges = const [],
    this.specialRequirements,
    required this.createdAt,
  });

  factory ParentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ParentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      numberOfChildren: data['numberOfChildren'] ?? 0,
      childrenAges: List<int>.from(data['childrenAges'] ?? []),
      specialRequirements: data['specialRequirements'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'phoneNumber': phoneNumber,
      'address': address,
      'numberOfChildren': numberOfChildren,
      'childrenAges': childrenAges,
      'specialRequirements': specialRequirements,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ParentModel copyWith({
    String? userId,
    String? phoneNumber,
    String? address,
    int? numberOfChildren,
    List<int>? childrenAges,
    String? specialRequirements,
  }) {
    return ParentModel(
      id: id,
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      numberOfChildren: numberOfChildren ?? this.numberOfChildren,
      childrenAges: childrenAges ?? this.childrenAges,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      createdAt: createdAt,
    );
  }
}
