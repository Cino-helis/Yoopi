import 'package:flutter/material.dart';
import 'package:yoopi/screens/chats/widgets/message_bubble.dart';
import 'package:yoopi/screens/chats/widgets/message_input.dart';
import 'package:yoopi/services/message_service.dart';
import 'package:yoopi/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String status;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.chatName,
    this.status = 'offline',
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final MessageService _messageService = MessageService();
  final UserService _userService = UserService();
  final ScrollController _scrollController = ScrollController();
  
  String _currentStatus = 'offline';
  String? _otherUserId;

  @override
  void initState() {
    super.initState();
    // Marquer tous les messages comme lus dès l'ouverture du chat
    _markMessagesAsRead();
    // Récupérer l'ID de l'autre utilisateur et écouter son statut
    _setupStatusListener();
  }

  // Configuration de l'écoute du statut en temps réel
  void _setupStatusListener() async {
    try {
      // Récupérer les participants du chat
      final chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .get();
      
      if (chatDoc.exists) {
        final chatData = chatDoc.data() as Map<String, dynamic>;
        final participants = List<String>.from(chatData['participants']);
        final currentUserId = _userService.currentUserId;
        
        _otherUserId = participants.firstWhere(
          (id) => id != currentUserId,
          orElse: () => '',
        );
        
        if (_otherUserId != null && _otherUserId!.isNotEmpty) {
          // Écouter le statut en temps réel
          _userService.getUserProfileStream(_otherUserId!).listen((snapshot) {
            if (snapshot.exists && mounted) {
              final userData = snapshot.data() as Map<String, dynamic>?;
              setState(() {
                _currentStatus = userData?['status'] ?? 'offline';
              });
            }
          });
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération du statut: $e');
    }
  }

  // Marquer les messages comme lus
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
      
      // Faire défiler vers le bas après l'envoi
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
    // TODO: Implémenter la logique d'attachement de fichier
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = const Color(0xFFA855F7);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Avatar de l'interlocuteur
            CircleAvatar(
              radius: 20,
              backgroundColor: primaryColor.withOpacity(0.5),
              child: Text(
                widget.chatName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Nom et Statut
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chatName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.status == 'online' ? 'En ligne' : 'Hors ligne',
                    style: TextStyle(
                      color: _currentStatus == 'online'
                          ? accentColor
                          : Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam_rounded, color: accentColor, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appel vidéo (À implémenter)')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Options de chat (À implémenter)')),
              );
            },
          ),
        ],
      ),
      
      body: Column(
        children: [
          // Liste des messages
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messageService.getMessages(widget.chatId),
              builder: (context, snapshot) {
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
                          'Envoyez le premier message !',
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
                    );
                  },
                );
              },
            ),
          ),
          
          // Barre de saisie de message
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