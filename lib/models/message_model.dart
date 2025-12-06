import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String senderName;
  final String senderPhotoUrl;
  final String text;
  final String? imageUrl;
  final String type; // 'text' ou 'image'
  final DateTime timestamp;
  final bool isEdited;
  final DateTime? editedAt;
  final List<String> readBy; // Liste des UIDs qui ont lu
  final List<String> deliveredTo; // Liste des UIDs qui ont reçu
  final String? replyToMessageId; // Pour les réponses (Phase 2)

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl = '',
    required this.text,
    this.imageUrl,
    this.type = 'text',
    required this.timestamp,
    this.isEdited = false,
    this.editedAt,
    this.readBy = const [],
    this.deliveredTo = const [],
    this.replyToMessageId,
  });

  // Vérifier si le message est lu par un utilisateur
  bool isReadBy(String userId) {
    return readBy.contains(userId);
  }

  // Vérifier si le message est délivré à un utilisateur
  bool isDeliveredTo(String userId) {
    return deliveredTo.contains(userId);
  }

  // Vérifier si c'est un message texte
  bool get isTextMessage => type == 'text';

  // Vérifier si c'est un message image
  bool get isImageMessage => type == 'image';

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'text': text,
      'imageUrl': imageUrl,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'readBy': readBy,
      'deliveredTo': deliveredTo,
      'replyToMessageId': replyToMessageId,
    };
  }

  // Créer depuis Map Firestore
  factory MessageModel.fromMap(String messageId, Map<String, dynamic> map) {
    return MessageModel(
      messageId: messageId,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? 'Utilisateur',
      senderPhotoUrl: map['senderPhotoUrl'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      type: map['type'] ?? 'text',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isEdited: map['isEdited'] ?? false,
      editedAt: map['editedAt'] != null
          ? (map['editedAt'] as Timestamp).toDate()
          : null,
      readBy: List<String>.from(map['readBy'] ?? []),
      deliveredTo: List<String>.from(map['deliveredTo'] ?? []),
      replyToMessageId: map['replyToMessageId'],
    );
  }

  // Créer depuis DocumentSnapshot
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromMap(doc.id, data);
  }

  // Copier avec modifications
  MessageModel copyWith({
    String? messageId,
    String? senderId,
    String? senderName,
    String? senderPhotoUrl,
    String? text,
    String? imageUrl,
    String? type,
    DateTime? timestamp,
    bool? isEdited,
    DateTime? editedAt,
    List<String>? readBy,
    List<String>? deliveredTo,
    String? replyToMessageId,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      readBy: readBy ?? this.readBy,
      deliveredTo: deliveredTo ?? this.deliveredTo,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    );
  }

  @override
  String toString() {
    return 'MessageModel(messageId: $messageId, senderId: $senderId, text: $text, type: $type)';
  }
}