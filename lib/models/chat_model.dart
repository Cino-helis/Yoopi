import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final String type; // 'private' ou 'group'
  final List<String> participants; // Liste des UIDs
  final Map<String, dynamic> participantsData; // Cache des infos (nom, photo)
  final String lastMessage;
  final String lastMessageType; // 'text' ou 'image'
  final String lastMessageSenderId;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCount; // {userId: nombre de non-lus}
  final DateTime createdAt;
  final String createdBy;
  
  // Pour les groupes uniquement
  final String? groupName;
  final String? groupPhotoUrl;
  final String? groupDescription;
  final List<String>? adminIds;

  ChatModel({
    required this.chatId,
    required this.type,
    required this.participants,
    this.participantsData = const {},
    this.lastMessage = '',
    this.lastMessageType = 'text',
    this.lastMessageSenderId = '',
    this.lastMessageTime,
    this.unreadCount = const {},
    required this.createdAt,
    required this.createdBy,
    this.groupName,
    this.groupPhotoUrl,
    this.groupDescription,
    this.adminIds,
  });

  // Vérifier si c'est un groupe
  bool get isGroup => type == 'group';

  // Obtenir le nombre de non-lus pour un utilisateur
  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'participants': participants,
      'participantsData': participantsData,
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': lastMessageTime != null 
          ? Timestamp.fromDate(lastMessageTime!) 
          : null,
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      if (isGroup) ...{
        'groupName': groupName ?? '',
        'groupPhotoUrl': groupPhotoUrl ?? '',
        'groupDescription': groupDescription ?? '',
        'adminIds': adminIds ?? [],
      },
    };
  }

  // Créer depuis Map Firestore
  factory ChatModel.fromMap(String chatId, Map<String, dynamic> map) {
    return ChatModel(
      chatId: chatId,
      type: map['type'] ?? 'private',
      participants: List<String>.from(map['participants'] ?? []),
      participantsData: Map<String, dynamic>.from(map['participantsData'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageType: map['lastMessageType'] ?? 'text',
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null
          ? (map['lastMessageTime'] as Timestamp).toDate()
          : null,
      unreadCount: Map<String, int>.from(
        (map['unreadCount'] as Map?)?.map((k, v) => MapEntry(k.toString(), v as int)) ?? {}
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
      groupName: map['groupName'],
      groupPhotoUrl: map['groupPhotoUrl'],
      groupDescription: map['groupDescription'],
      adminIds: map['adminIds'] != null ? List<String>.from(map['adminIds']) : null,
    );
  }

  // Créer depuis DocumentSnapshot
  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel.fromMap(doc.id, data);
  }

  // Copier avec modifications
  ChatModel copyWith({
    String? chatId,
    String? type,
    List<String>? participants,
    Map<String, dynamic>? participantsData,
    String? lastMessage,
    String? lastMessageType,
    String? lastMessageSenderId,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    String? createdBy,
    String? groupName,
    String? groupPhotoUrl,
    String? groupDescription,
    List<String>? adminIds,
  }) {
    return ChatModel(
      chatId: chatId ?? this.chatId,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      participantsData: participantsData ?? this.participantsData,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      groupName: groupName ?? this.groupName,
      groupPhotoUrl: groupPhotoUrl ?? this.groupPhotoUrl,
      groupDescription: groupDescription ?? this.groupDescription,
      adminIds: adminIds ?? this.adminIds,
    );
  }

  @override
  String toString() {
    return 'ChatModel(chatId: $chatId, type: $type, participants: $participants, lastMessage: $lastMessage)';
  }
}