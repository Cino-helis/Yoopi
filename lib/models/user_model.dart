import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String displayName;
  final String photoUrl;
  final String bio;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final List<String> fcmTokens;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.displayName = '',
    this.photoUrl = '',
    this.bio = '',
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
    this.fcmTokens = const [],
  });

  // Convertir un UserModel en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'fcmTokens': fcmTokens,
    };
  }

  // Créer un UserModel à partir d'un Map Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      bio: map['bio'] ?? '',
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null 
          ? (map['lastSeen'] as Timestamp).toDate() 
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      fcmTokens: List<String>.from(map['fcmTokens'] ?? []),
    );
  }

  // Créer un UserModel à partir d'un DocumentSnapshot Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  // Copier avec modifications
  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? displayName,
    String? photoUrl,
    String? bio,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    List<String>? fcmTokens,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, username: $username, displayName: $displayName)';
  }
}