import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:napphy_services/models/nanny_model.dart';
import 'package:napphy_services/models/parent_model.dart';
import 'package:napphy_services/models/booking_model.dart';
import 'package:napphy_services/models/review_model.dart';

class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CRUD para Nanny
  Future<void> createNannyProfile(NannyModel nanny) async {
    try {
      await _firestore.collection('nannies').doc(nanny.userId).set(nanny.toMap());
    } catch (e) {
      throw Exception('Error al crear perfil de niñera: $e');
    }
  }

  Future<NannyModel?> getNannyProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('nannies').doc(userId).get();
      if (doc.exists) {
        return NannyModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener perfil de niñera: $e');
    }
  }

  Future<void> updateNannyProfile(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('nannies').doc(userId).update(updates);
      notifyListeners();
    } catch (e) {
      throw Exception('Error al actualizar perfil de niñera: $e');
    }
  }

  Stream<List<NannyModel>> getNanniesStream({
    bool? isApproved,
    bool? isAvailable,
  }) {
    Query query = _firestore.collection('nannies');

    if (isApproved != null) {
      query = query.where('isApproved', isEqualTo: isApproved);
    }
    if (isAvailable != null) {
      query = query.where('isAvailable', isEqualTo: isAvailable);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => NannyModel.fromFirestore(doc)).toList();
    });
  }

  Future<List<NannyModel>> searchNannies({
    double? maxHourlyRate,
    double? minRating,
    GeoPoint? nearLocation,
    double? radiusKm,
  }) async {
    try {
      Query query = _firestore.collection('nannies').where('isApproved', isEqualTo: true);

      if (maxHourlyRate != null) {
        query = query.where('hourlyRate', isLessThanOrEqualTo: maxHourlyRate);
      }
      if (minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      QuerySnapshot snapshot = await query.get();
      List<NannyModel> nannies = snapshot.docs
          .map((doc) => NannyModel.fromFirestore(doc))
          .toList();

      // Filtrar por ubicación si se proporciona
      if (nearLocation != null && radiusKm != null) {
        nannies = nannies.where((nanny) {
          double distance = _calculateDistance(
            nearLocation.latitude,
            nearLocation.longitude,
            nanny.location.latitude,
            nanny.location.longitude,
          );
          return distance <= radiusKm;
        }).toList();
      }

      return nannies;
    } catch (e) {
      throw Exception('Error al buscar niñeras: $e');
    }
  }

  // CRUD para Parent
  Future<void> createParentProfile(ParentModel parent) async {
    try {
      await _firestore.collection('parents').doc(parent.userId).set(parent.toMap());
    } catch (e) {
      throw Exception('Error al crear perfil de padre: $e');
    }
  }

  Future<ParentModel?> getParentProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('parents').doc(userId).get();
      if (doc.exists) {
        return ParentModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener perfil de padre: $e');
    }
  }

  Future<void> updateParentProfile(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('parents').doc(userId).update(updates);
      notifyListeners();
    } catch (e) {
      throw Exception('Error al actualizar perfil de padre: $e');
    }
  }

  // CRUD para Booking
  Future<String> createBooking(BookingModel booking) async {
    try {
      DocumentReference docRef = await _firestore.collection('bookings').add(booking.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear contratación: $e');
    }
  }

  Future<void> updateBooking(String bookingId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update(updates);
      notifyListeners();
    } catch (e) {
      throw Exception('Error al actualizar contratación: $e');
    }
  }

  Stream<List<BookingModel>> getBookingsForNanny(String nannyId) {
    return _firestore
        .collection('bookings')
        .where('nannyId', isEqualTo: nannyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<BookingModel>> getBookingsForParent(String parentId) {
    return _firestore
        .collection('bookings')
        .where('parentId', isEqualTo: parentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
    });
  }

  // CRUD para Review
  Future<void> createReview(ReviewModel review) async {
    try {
      // Agregar reseña
      await _firestore.collection('reviews').add(review.toMap());

      // Actualizar rating promedio de la niñera
      QuerySnapshot reviews = await _firestore
          .collection('reviews')
          .where('nannyId', isEqualTo: review.nannyId)
          .get();

      double totalRating = 0;
      for (var doc in reviews.docs) {
        totalRating += (doc.data() as Map<String, dynamic>)['rating'];
      }

      double avgRating = totalRating / reviews.docs.length;

      await _firestore.collection('nannies').doc(review.nannyId).update({
        'rating': avgRating,
        'totalReviews': reviews.docs.length,
      });

      notifyListeners();
    } catch (e) {
      throw Exception('Error al crear reseña: $e');
    }
  }

  Stream<List<ReviewModel>> getReviewsForNanny(String nannyId) {
    return _firestore
        .collection('reviews')
        .where('nannyId', isEqualTo: nannyId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
    });
  }

  // Funciones administrativas
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios: $e');
    }
  }

  Future<void> approveNanny(String nannyId) async {
    try {
      await _firestore.collection('nannies').doc(nannyId).update({
        'isApproved': true,
      });
      notifyListeners();
    } catch (e) {
      throw Exception('Error al aprobar niñera: $e');
    }
  }

  Future<void> suspendUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': false,
      });
      notifyListeners();
    } catch (e) {
      throw Exception('Error al suspender usuario: $e');
    }
  }

  // Utilidad: Calcular distancia entre dos puntos (fórmula Haversine simplificada)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = 0.5 -
        (dLat / 2).cos() / 2 +
        lat1.toRadians().cos() * lat2.toRadians().cos() * (1 - (dLon / 2).cos()) / 2;

    return earthRadius * 2 * a.asin();
  }

  double _toRadians(double degree) {
    return degree * 3.141592653589793 / 180;
  }
}

extension on double {
  double toRadians() => this * 3.141592653589793 / 180;
  double cos() => this.toRadians();
  double asin() => this;
}
