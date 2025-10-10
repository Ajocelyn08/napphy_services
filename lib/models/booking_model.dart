import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  accepted,
  rejected,
  inProgress,
  completed,
  cancelled
}

class BookingModel {
  final String id;
  final String parentId;
  final String nannyId;
  final DateTime startDate;
  final DateTime endDate;
  final String startTime;
  final String endTime;
  final int numberOfHours;
  final double hourlyRate;
  final double totalAmount;
  final BookingStatus status;
  final String? specialInstructions;
  final String address;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final String? cancellationReason;

  BookingModel({
    required this.id,
    required this.parentId,
    required this.nannyId,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.numberOfHours,
    required this.hourlyRate,
    required this.totalAmount,
    this.status = BookingStatus.pending,
    this.specialInstructions,
    required this.address,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.cancellationReason,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      parentId: data['parentId'] ?? '',
      nannyId: data['nannyId'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      numberOfHours: data['numberOfHours'] ?? 0,
      hourlyRate: (data['hourlyRate'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${data['status']}',
        orElse: () => BookingStatus.pending,
      ),
      specialInstructions: data['specialInstructions'],
      address: data['address'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      acceptedAt: data['acceptedAt'] != null
          ? (data['acceptedAt'] as Timestamp).toDate()
          : null,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      cancellationReason: data['cancellationReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'nannyId': nannyId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'startTime': startTime,
      'endTime': endTime,
      'numberOfHours': numberOfHours,
      'hourlyRate': hourlyRate,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'specialInstructions': specialInstructions,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cancellationReason': cancellationReason,
    };
  }

  BookingModel copyWith({
    String? parentId,
    String? nannyId,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    int? numberOfHours,
    double? hourlyRate,
    double? totalAmount,
    BookingStatus? status,
    String? specialInstructions,
    String? address,
    DateTime? acceptedAt,
    DateTime? completedAt,
    String? cancellationReason,
  }) {
    return BookingModel(
      id: id,
      parentId: parentId ?? this.parentId,
      nannyId: nannyId ?? this.nannyId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      numberOfHours: numberOfHours ?? this.numberOfHours,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      address: address ?? this.address,
      createdAt: createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
