import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String bookingId;
  final String parentId;
  final String nannyId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String> tags;

  ReviewModel({
    required this.id,
    required this.bookingId,
    required this.parentId,
    required this.nannyId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.tags = const [],
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      bookingId: data['bookingId'] ?? '',
      parentId: data['parentId'] ?? '',
      nannyId: data['nannyId'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'parentId': parentId,
      'nannyId': nannyId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
    };
  }
}
