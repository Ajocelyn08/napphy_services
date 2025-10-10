import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:napphy_services/models/message_model.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Crear o obtener un chat entre dos usuarios
  Future<String> getOrCreateChat(
    String userId1,
    String userId2,
    String user1Name,
    String user2Name,
    String? user1Photo,
    String? user2Photo,
  ) async {
    // Buscar si ya existe un chat entre estos usuarios
    QuerySnapshot existingChats = await _firestore
        .collection('chats')
        .where('participants', arrayContains: userId1)
        .get();

    for (var doc in existingChats.docs) {
      List<String> participants =
          List<String>.from((doc.data() as Map<String, dynamic>)['participants']);
      if (participants.contains(userId2)) {
        return doc.id;
      }
    }

    // Si no existe, crear uno nuevo
    ChatModel newChat = ChatModel(
      id: _uuid.v4(),
      participants: [userId1, userId2],
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: {userId1: 0, userId2: 0},
      participantNames: {userId1: user1Name, userId2: user2Name},
      participantPhotos: {userId1: user1Photo, userId2: user2Photo},
    );

    DocumentReference docRef =
        await _firestore.collection('chats').add(newChat.toMap());
    return docRef.id;
  }

  // Enviar mensaje
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
    String? imageUrl,
    Map<String, dynamic>? bookingData,
  }) async {
    try {
      MessageModel message = MessageModel(
        id: _uuid.v4(),
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        type: type,
        timestamp: DateTime.now(),
        isRead: false,
        imageUrl: imageUrl,
        bookingData: bookingData,
      );

      // Agregar mensaje a la subcolección
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());

      // Actualizar información del chat
      DocumentSnapshot chatDoc =
          await _firestore.collection('chats').doc(chatId).get();
      Map<String, dynamic> chatData = chatDoc.data() as Map<String, dynamic>;
      Map<String, int> unreadCount =
          Map<String, int>.from(chatData['unreadCount'] ?? {});

      unreadCount[receiverId] = (unreadCount[receiverId] ?? 0) + 1;

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': content,
        'lastMessageTime': Timestamp.now(),
        'unreadCount': unreadCount,
      });
    } catch (e) {
      throw Exception('Error al enviar mensaje: $e');
    }
  }

  // Obtener mensajes de un chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
    });
  }

  // Marcar mensajes como leídos
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      // Actualizar contador de mensajes no leídos
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$userId': 0,
      });

      // Marcar mensajes individuales como leídos
      QuerySnapshot unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Error al marcar mensajes como leídos: $e');
    }
  }

  // Obtener lista de chats de un usuario
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList();
    });
  }

  // Obtener contador total de mensajes no leídos
  Stream<int> getUnreadMessagesCount(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        Map<String, dynamic> unreadCount = data['unreadCount'] ?? {};
        total += (unreadCount[userId] ?? 0) as int;
      }
      return total;
    });
  }

  // Eliminar un chat
  Future<void> deleteChat(String chatId) async {
    try {
      // Eliminar todos los mensajes
      QuerySnapshot messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Eliminar el chat
      await _firestore.collection('chats').doc(chatId).delete();
    } catch (e) {
      throw Exception('Error al eliminar chat: $e');
    }
  }
}
