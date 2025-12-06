import 'package:flutter/material.dart';
import 'package:yoopi/screens/chats/widgets/chat_tile.dart'; // Pour le FAB
import 'package:yoopi/screens/groups/create_group_screen.dart';
import 'package:yoopi/screens/chats/chat_detail_screen.dart';
import 'package:yoopi/services/message_service.dart';
import 'package:yoopi/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final MessageService _messageService = MessageService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    // Mettre à jour le statut à "online" quand on ouvre l'écran
    _userService.updateStatus('online');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _messageService.getUserChats(),
        builder: (context, snapshot) {
          // Gestion des états de chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7C3AED),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Si aucun chat
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Aucune conversation',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Commencez une nouvelle conversation',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // Liste des chats
          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatDoc = chats[index];
              final chatData = chatDoc.data() as Map<String, dynamic>;
              final chatId = chatDoc.id;
              
              // Récupérer l'ID de l'autre participant
              final participants = List<String>.from(chatData['participants']);
              final currentUserId = _userService.currentUserId;
              final otherUserId = participants.firstWhere(
                (id) => id != currentUserId,
                orElse: () => '',
              );

              return FutureBuilder<DocumentSnapshot>(
                future: _userService.getUserProfile(otherUserId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  final username = userData?['username'] ?? 'Utilisateur inconnu';
                  final status = userData?['status'] ?? 'offline';

                  // Compter les messages non lus
                  return FutureBuilder<int>(
                    future: _messageService.getUnreadCount(chatId),
                    builder: (context, unreadSnapshot) {
                      final unreadCount = unreadSnapshot.data ?? 0;

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(
                                chatId: chatId,
                                chatName: username,
                                status: status,
                              ),
                            ),
                          );
                        },
                        child: ChatTile(
                          name: username,
                          lastMessage: chatData['lastMessage'] ?? '',
                          time: _formatTimestamp(chatData['lastMessageTime']),
                          unreadCount: unreadCount,
                          isGroup: chatData['isGroup'] ?? false,
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      
      // Floating Action Button pour créer un nouveau chat/groupe
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  // Formatter le timestamp
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    
    try {
      final DateTime dateTime = (timestamp as Timestamp).toDate();
      final DateTime now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Hier';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}j';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year.toString().substring(2)}';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    // Mettre à jour le statut à "offline" quand on quitte
    _userService.updateStatus('offline');
    super.dispose();
  }
}