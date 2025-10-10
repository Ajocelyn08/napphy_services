import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // Subir imagen de perfil
  Future<String> uploadProfileImage(File file, String userId) async {
    try {
      String fileName = '${userId}_${_uuid.v4()}.jpg';
      Reference ref = _storage.ref().child('profiles/$fileName');

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir imagen de perfil: $e');
    }
  }

  // Subir imagen para chat
  Future<String> uploadChatImage(File file, String chatId) async {
    try {
      String fileName = '${chatId}_${_uuid.v4()}.jpg';
      Reference ref = _storage.ref().child('chats/$fileName');

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir imagen de chat: $e');
    }
  }

  // Subir certificaciones
  Future<String> uploadCertification(File file, String nannyId) async {
    try {
      String fileName = '${nannyId}_cert_${_uuid.v4()}.pdf';
      Reference ref = _storage.ref().child('certifications/$fileName');

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir certificación: $e');
    }
  }

  // Eliminar archivo
  Future<void> deleteFile(String fileUrl) async {
    try {
      Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Error al eliminar archivo: $e');
    }
  }
}
