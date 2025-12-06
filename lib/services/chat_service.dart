import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Référence à la collection des chats
  CollectionReference get _chatsCollection => _firestore.collection('chats');

  /// CRÉER UN CHAT PRIVÉ (1:1)
  /// Vérifie d'abord si un chat existe déjà entre ces deux utilisateurs
  Future<String?> createPrivateChat({
    required String otherUserId,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return null;

      // Vérifier si un chat existe déjà
      final existingChat = await _chatsCollection
          .where('type', isEqualTo: 'private')
          .where('participants', arrayContains: currentUserId)
          .get();

      // Chercher un chat qui contient les deux utilisateurs
      for (var doc in existingChat.docs) {
        final participants = List<String>.from(doc['participants']);
        if (participants.contains(otherUserId) && participants.length == 2) {
          return doc.id; // Chat existant trouvé
        }
      }

      // Récupérer les infos des participants
      final currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
      final otherUserDoc = await _firestore.collection('users').doc(otherUserId).get();

      final currentUserData = currentUserDoc.data() ?? {};
      final otherUserData = otherUserDoc.data() ?? {};

      // Créer un nouveau chat
      final chatDoc = await _chatsCollection.add({
        'type': 'private',
        'participants': [currentUserId, otherUserId],
        'participantsData': {
          currentUserId: {
            'name': currentUserData['displayName'] ?? currentUserData['username'] ?? 'Utilisateur',
            'photoUrl': currentUserData['photoUrl'] ?? '',
          },
          otherUserId: {
            'name': otherUserData['displayName'] ?? otherUserData['username'] ?? 'Utilisateur',
            'photoUrl': otherUserData['photoUrl'] ?? '',
          },
        },
        'lastMessage': '',
        'lastMessageType': 'text',
        'lastMessageSenderId': '',
        'lastMessageTime': null,
        'unreadCount': {
          currentUserId: 0,
          otherUserId: 0,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUserId,
      });

      return chatDoc.id;
    } catch (e) {
      print('Erreur lors de la création du chat privé: $e');
      return null;
    }
  }

  /// CRÉER UN GROUPE
  Future<String?> createGroup({
    required String groupName,
    required List<String> memberIds,
    String? groupDescription,
    String? groupPhotoUrl,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return null;

      // Ajouter le créateur aux membres
      final allMembers = {...memberIds, currentUserId}.toList();

      // Récupérer les infos de tous les membres
      final Map<String, dynamic> participantsData = {};
      for (String memberId in allMembers) {
        final userDoc = await _firestore.collection('users').doc(memberId).get();
        final userData = userDoc.data() ?? {};
        participantsData[memberId] = {
          'name': userData['displayName'] ?? userData['username'] ?? 'Utilisateur',
          'photoUrl': userData['photoUrl'] ?? '',
        };
      }

      // Initialiser les compteurs de non-lus
      final Map<String, int> unreadCount = {};
      for (String memberId in allMembers) {
        unreadCount[memberId] = 0;
      }

      // Créer le groupe
      final groupDoc = await _chatsCollection.add({
        'type': 'group',
        'participants': allMembers,
        'participantsData': participantsData,
        'groupName': groupName,
        'groupPhotoUrl': groupPhotoUrl ?? '',
        'groupDescription': groupDescription ?? '',
        'adminIds': [currentUserId], // Le créateur est admin
        'lastMessage': '',
        'lastMessageType': 'text',
        'lastMessageSenderId': '',
        'lastMessageTime': null,
        'unreadCount': unreadCount,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUserId,
      });

      return groupDoc.id;
    } catch (e) {
      print('Erreur lors de la création du groupe: $e');
      return null;
    }
  }

  /// OBTENIR LES CHATS DE L'UTILISATEUR COURANT (Stream en temps réel)
  Stream<List<Map<String, dynamic>>> getUserChats() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _chatsCollection
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'chatId': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  /// OBTENIR UN CHAT SPÉCIFIQUE
  Future<Map<String, dynamic>?> getChat(String chatId) async {
    try {
      final doc = await _chatsCollection.doc(chatId).get();
      if (doc.exists) {
        return {
          'chatId': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du chat: $e');
      return null;
    }
  }

  /// METTRE À JOUR LE DERNIER MESSAGE
  Future<void> updateLastMessage({
    required String chatId,
    required String message,
    required String messageType,
    required String senderId,
  }) async {
    try {
      await _chatsCollection.doc(chatId).update({
        'lastMessage': message,
        'lastMessageType': messageType,
        'lastMessageSenderId': senderId,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du dernier message: $e');
    }
  }

  /// INCRÉMENTER LE COMPTEUR DE NON-LUS
  Future<void> incrementUnreadCount({
    required String chatId,
    required String userId,
  }) async {
    try {
      await _chatsCollection.doc(chatId).update({
        'unreadCount.$userId': FieldValue.increment(1),
      });
    } catch (e) {
      print('Erreur lors de l\'incrémentation du compteur: $e');
    }
  }

  /// RÉINITIALISER LE COMPTEUR DE NON-LUS
  Future<void> resetUnreadCount({
    required String chatId,
    required String userId,
  }) async {
    try {
      await _chatsCollection.doc(chatId).update({
        'unreadCount.$userId': 0,
      });
    } catch (e) {
      print('Erreur lors de la réinitialisation du compteur: $e');
    }
  }

  /// AJOUTER UN MEMBRE À UN GROUPE
  Future<bool> addMemberToGroup({
    required String chatId,
    required String userId,
  }) async {
    try {
      // Récupérer les infos de l'utilisateur
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? {};

      await _chatsCollection.doc(chatId).update({
        'participants': FieldValue.arrayUnion([userId]),
        'participantsData.$userId': {
          'name': userData['displayName'] ?? userData['username'] ?? 'Utilisateur',
          'photoUrl': userData['photoUrl'] ?? '',
        },
        'unreadCount.$userId': 0,
      });

      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout du membre: $e');
      return false;
    }
  }

  /// RETIRER UN MEMBRE D'UN GROUPE
  Future<bool> removeMemberFromGroup({
    required String chatId,
    required String userId,
  }) async {
    try {
      await _chatsCollection.doc(chatId).update({
        'participants': FieldValue.arrayRemove([userId]),
      });

      return true;
    } catch (e) {
      print('Erreur lors du retrait du membre: $e');
      return false;
    }
  }

  /// SUPPRIMER UN CHAT
  Future<bool> deleteChat(String chatId) async {
    try {
      // Supprimer tous les messages du chat
      final messagesSnapshot = await _chatsCollection
          .doc(chatId)
          .collection('messages')
          .get();

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Supprimer le chat
      await _chatsCollection.doc(chatId).delete();

      return true;
    } catch (e) {
      print('Erreur lors de la suppression du chat: $e');
      return false;
    }
  }
}