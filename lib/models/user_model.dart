import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { nanny, parent, admin }

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.photoUrl,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  // Convertir de Firebase Document a UserModel
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data();
    
    // Validar que data no sea null y sea un Map
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception('Documento inválido o vacío');
    }

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      role: _parseRole(data['role']),
      photoUrl: data['photoUrl'],
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      lastLogin: _parseTimestamp(data['lastLogin']),
      isActive: data['isActive'] ?? true,
    );
  }

  // Helper para parsear roles de forma segura
  static UserRole _parseRole(dynamic roleData) {
    if (roleData == null) return UserRole.parent;
    
    final roleString = roleData.toString().toLowerCase();
    
    if (roleString.contains('nanny')) return UserRole.nanny;
    if (roleString.contains('parent')) return UserRole.parent;
    if (roleString.contains('admin')) return UserRole.admin;
    
    return UserRole.parent; // default
  }

  // Helper para parsear timestamps de forma segura
  static DateTime? _parseTimestamp(dynamic timestampData) {
    if (timestampData == null) return null;
    
    try {
      if (timestampData is Timestamp) {
        return timestampData.toDate();
      } else if (timestampData is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestampData);
      } else if (timestampData is String) {
        return DateTime.parse(timestampData);
      }
    } catch (e) {
      print('Error parseando timestamp: $e');
    }
    
    return null;
  }

  // Convertir UserModel a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role.name, // Usa .name en lugar de split
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? email,
    String? fullName,
    UserRole? role,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, role: ${role.name})';
  }
}