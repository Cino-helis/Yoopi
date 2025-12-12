import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yoopi/screens/chats/widgets/message_bubble.dart';
import 'package:yoopi/screens/chats/widgets/message_input.dart';
import 'package:yoopi/services/message_service.dart';
import 'package:yoopi/services/user_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final String chatId;
  final String groupName;

  const GroupDetailScreen({
    super.key,
    required this.chatId,
    required this.groupName,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final MessageService _messageService = MessageService();
  final UserService _userService = UserService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  void _markMessagesAsRead() async {
    try {
      await _messageService.markChatAsRead(widget.chatId);
    } catch (e) {
      print('Erreur lors du marquage comme lu: $e');
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    try {
      await _messageService.sendMessage(widget.chatId, message);
      
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _attachFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attacher un fichier (À implémenter)')),
    );
  }

  String _formatMessageTime(dynamic timestamp) {
    if (timestamp == null) return 'Envoi...';
    
    try {
      final DateTime dateTime = (timestamp as Timestamp).toDate();
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  void _showGroupInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D1B4E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final groupData = snapshot.data!.data() as Map<String, dynamic>;
          final participants = List<String>.from(groupData['participants'] ?? []);
          final adminIds = List<String>.from(groupData['adminIds'] ?? []);

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titre
                Text(
                  widget.groupName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${participants.length} membres',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),

                // Liste des membres
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      final userId = participants[index];
                      final isAdmin = adminIds.contains(userId);

                      return FutureBuilder<DocumentSnapshot>(
                        future: _userService.getUserProfile(userId),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const SizedBox.shrink();
                          }

                          final userData = userSnapshot.data!.data()
                              as Map<String, dynamic>?;
                          final username =
                              userData?['username'] ?? 'Utilisateur';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).primaryColor.withOpacity(0.5),
                              child: Text(
                                username.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              username,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: isAdmin
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFA855F7)
                                          .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Admin',
                                      style: TextStyle(
                                        color: Color(0xFFA855F7),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color accentColor = const Color(0xFFA855F7);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: InkWell(
          onTap: _showGroupInfo,
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.groupName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .doc(widget.chatId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        
                        final groupData = snapshot.data!.data() as Map<String, dynamic>?;
                        final participants = List<String>.from(groupData?['participants'] ?? []);
                        
                        return Text(
                          '${participants.length} membres',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: accentColor, size: 28),
            onPressed: _showGroupInfo,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Options du groupe (À implémenter)')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messageService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
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

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_outlined,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Aucun message',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Soyez le premier à envoyer un message !',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageDoc = messages[index];
                    final messageData = messageDoc.data() as Map<String, dynamic>;
                    final isMe = messageData['senderId'] == _userService.currentUserId;

                    return MessageBubble(
                      chatId: widget.chatId,
                      messageId: messageDoc.id,
                      message: messageData['message'] ?? '',
                      time: _formatMessageTime(messageData['timestamp']),
                      isMe: isMe,
                      isRead: messageData['isRead'] ?? false,
                      otherUserIsOnline: true, // Pour les groupes, on considère toujours "en ligne"
                    );
                  },
                );
              },
            ),
          ),
          MessageInput(
            controller: _messageController,
            onSendMessage: _sendMessage,
            onAttachFile: _attachFile,
          ),
        ],
      ),
    );
  }
}