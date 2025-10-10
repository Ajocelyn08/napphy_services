import 'package:cloud_firestore/cloud_firestore.dart';

class NannyModel {
  final String id;
  final String userId;
  final int age;
  final List<String> certifications;
  final Map<String, dynamic> availability; // {day: [hours]}
  final GeoPoint location;
  final String address;
  final double hourlyRate;
  final String? photoUrl;
  final String bio;
  final int yearsOfExperience;
  final List<String> languages;
  final bool isAvailable;
  final bool isApproved;
  final double rating;
  final int totalReviews;
  final DateTime createdAt;

  NannyModel({
    required this.id,
    required this.userId,
    required this.age,
    this.certifications = const [],
    required this.availability,
    required this.location,
    required this.address,
    required this.hourlyRate,
    this.photoUrl,
    this.bio = '',
    this.yearsOfExperience = 0,
    this.languages = const ['Español'],
    this.isAvailable = true,
    this.isApproved = false,
    this.rating = 0.0,
    this.totalReviews = 0,
    required this.createdAt,
  });

  factory NannyModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NannyModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      age: data['age'] ?? 18,
      certifications: List<String>.from(data['certifications'] ?? []),
      availability: Map<String, dynamic>.from(data['availability'] ?? {}),
      location: data['location'] ?? const GeoPoint(0, 0),
      address: data['address'] ?? '',
      hourlyRate: (data['hourlyRate'] ?? 0).toDouble(),
      photoUrl: data['photoUrl'],
      bio: data['bio'] ?? '',
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
      languages: List<String>.from(data['languages'] ?? ['Español']),
      isAvailable: data['isAvailable'] ?? true,
      isApproved: data['isApproved'] ?? false,
      rating: (data['rating'] ?? 0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'age': age,
      'certifications': certifications,
      'availability': availability,
      'location': location,
      'address': address,
      'hourlyRate': hourlyRate,
      'photoUrl': photoUrl,
      'bio': bio,
      'yearsOfExperience': yearsOfExperience,
      'languages': languages,
      'isAvailable': isAvailable,
      'isApproved': isApproved,
      'rating': rating,
      'totalReviews': totalReviews,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  NannyModel copyWith({
    String? userId,
    int? age,
    List<String>? certifications,
    Map<String, dynamic>? availability,
    GeoPoint? location,
    String? address,
    double? hourlyRate,
    String? photoUrl,
    String? bio,
    int? yearsOfExperience,
    List<String>? languages,
    bool? isAvailable,
    bool? isApproved,
    double? rating,
    int? totalReviews,
  }) {
    return NannyModel(
      id: id,
      userId: userId ?? this.userId,
      age: age ?? this.age,
      certifications: certifications ?? this.certifications,
      availability: availability ?? this.availability,
      location: location ?? this.location,
      address: address ?? this.address,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      languages: languages ?? this.languages,
      isAvailable: isAvailable ?? this.isAvailable,
      isApproved: isApproved ?? this.isApproved,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdAt: createdAt,
    );
  }
}
