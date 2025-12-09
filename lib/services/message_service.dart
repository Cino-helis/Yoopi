import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Créer ou récupérer un chat entre deux utilisateurs
  Future<String> getOrCreateChat(String otherUserId) async {
    final currentUserId = _auth.currentUser!.uid;
    final participants = [currentUserId, otherUserId]..sort();
    
    // Vérifier si un chat existe déjà
    final existingChat = await _firestore
        .collection('chats')
        .where('participants', isEqualTo: participants)
        .where('isGroup', isEqualTo: false)
        .limit(1)
        .get();

    if (existingChat.docs.isNotEmpty) {
      return existingChat.docs.first.id;
    }

    // Créer un nouveau chat
    final chatDoc = await _firestore.collection('chats').add({
      'participants': participants,
      'isGroup': false,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    return chatDoc.id;
  }

  // Envoyer un message
  Future<void> sendMessage(String chatId, String message) async {
    final currentUser = _auth.currentUser!;
    
    // Ajouter le message dans la sous-collection
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': currentUser.uid,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Mettre à jour le dernier message du chat
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  // Stream des messages d'un chat (ordre décroissant pour affichage inversé)
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Stream de tous les chats de l'utilisateur
  Stream<QuerySnapshot> getUserChats() {
    final currentUserId = _auth.currentUser!.uid;
    
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // Marquer un message comme lu
  Future<void> markMessageAsRead(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }

  // Compter les messages non lus dans un chat
  Future<int> getUnreadCount(String chatId) async {
    final currentUserId = _auth.currentUser!.uid;
    
    final unreadMessages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    return unreadMessages.docs.length;
  }

  // Marquer tous les messages d'un chat comme lus
  Future<void> markChatAsRead(String chatId) async {
    final currentUserId = _auth.currentUser!.uid;
    
    final unreadMessages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // Stream du compteur de messages non lus en temps réel
  Stream<int> getUnreadCountStream(String chatId) {
    final currentUserId = _auth.currentUser!.uid;
    
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Supprimer un chat
  Future<void> deleteChat(String chatId) async {
    // Supprimer tous les messages
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }
    
    // Supprimer le chat
    batch.delete(_firestore.collection('chats').doc(chatId));
    
    await batch.commit();
  }
}