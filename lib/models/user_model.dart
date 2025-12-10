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

  /// Nueva firma: recibe DocumentSnapshot tipado correctamente
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data(); // ahora guaranteed Map<String, dynamic> | null

    if (data == null) {
      throw Exception('Documento inválido o vacío: ${doc.id}');
    }

    return UserModel(
      id: doc.id,
      email: (data['email'] ?? '') as String,
      fullName: (data['fullName'] ?? '') as String,
      role: _parseRole(data['role']),
      photoUrl: data['photoUrl'] as String?,
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      lastLogin: _parseTimestamp(data['lastLogin']),
      isActive: (data['isActive'] ?? true) as bool,
    );
  }

  /// Alternativa: construir desde un Map (útil para withConverter)
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      email: (data['email'] ?? '') as String,
      fullName: (data['fullName'] ?? '') as String,
      role: _parseRole(data['role']),
      photoUrl: data['photoUrl'] as String?,
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      lastLogin: _parseTimestamp(data['lastLogin']),
      isActive: (data['isActive'] ?? true) as bool,
    );
  }

  static UserRole _parseRole(dynamic roleData) {
  if (roleData == null) return UserRole.parent;

  // Si viene como lista: ["parent"]
  if (roleData is List && roleData.isNotEmpty) {
    final first = roleData.first.toString().toLowerCase();
    if (first.contains('nanny')) return UserRole.nanny;
    if (first.contains('parent')) return UserRole.parent;
    if (first.contains('admin')) return UserRole.admin;
    return UserRole.parent;
  }

      // Si viene como string: "parent"
      final roleString = roleData.toString().toLowerCase();

      if (roleString.contains('nanny')) return UserRole.nanny;
      if (roleString.contains('parent')) return UserRole.parent;
      if (roleString.contains('admin')) return UserRole.admin;

      return UserRole.parent;
  }


  static DateTime? _parseTimestamp(dynamic timestampData) {
    if (timestampData == null) return null;

    try {
      if (timestampData is Timestamp) {
        return timestampData.toDate();
      } else if (timestampData is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestampData);
      } else if (timestampData is String) {
        return DateTime.parse(timestampData);
      } else if (timestampData is DateTime) {
        return timestampData;
      }
    } catch (e) {
      // ignore parse errors, retorna null
    }

    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role.name,
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
