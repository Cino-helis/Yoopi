import 'package:flutter/material.dart';
import 'package:yoopi/screens/chats/widgets/message_bubble.dart';
import 'package:yoopi/screens/chats/widgets/message_input.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatName; // Nom de l'interlocuteur ou du groupe
  final String status; // Statut (online, last seen, etc.)

  const ChatDetailScreen({
    super.key,
    required this.chatName,
    this.status = 'offline', // Par défaut
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // Liste des messages pour l'affichage

  @override
  void initState() {
    super.initState();
    // Messages de démonstration pour l'interface utilisateur
    _messages.addAll([
      {'message': 'Tu excutus', 'time': '12:00', 'isMe': false, 'isRead': true},
      {'message': 'Tu as vu la nouvelle fonctionllaanité ?', 'time': '12:30', 'isMe': true, 'isRead': true},
      {'message': 'Fonctionloanité ?', 'time': '13:00', 'isMe': false, 'isRead': false},
      {'message': 'Tu idce ae script', 'time': '13:30', 'isMe': true, 'isRead': true},
      {'message': 'Tu actionlanite', 'time': '19:30', 'isMe': true, 'isRead': false},
      {'message': 'Fonctionloanité ?', 'time': '19:30', 'isMe': false, 'isRead': false},
      {'message': '5inß', 'time': '20:00', 'isMe': true, 'isRead': false},
    ]);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'message': _messageController.text,
        'time': 'Maintenant', // Pour l'instant, juste un placeholder
        'isMe': true,
        'isRead': false, // Par défaut non lu
      });
      _messageController.clear();
      // TODO: Faire défiler la liste vers le bas automatiquement
    });
    // TODO: Envoyer le message via MessageService
  }

  void _attachFile() {
    // TODO: Implémenter la logique d'attachement de fichier (image_picker_helper.dart)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attacher un fichier (À implémenter)')),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Couleurs du thème
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color primaryColor = Theme.of(context).primaryColor; // deepPurple
    final Color accentColor = const Color(0xFFA855F7); // Violet clair du logo

    return Scaffold(
      // 1. AppBar Personnalisée
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Avatar de l'interlocuteur/groupe
            CircleAvatar(
              radius: 20,
              backgroundColor: primaryColor.withOpacity(0.5),
              child: Text(
                widget.chatName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              // TODO: Afficher l'image réelle
            ),
            const SizedBox(width: 10),
            // Nom et Statut
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.status == 'online' ? 'En ligne' : widget.status, // Ex: "En ligne"
                  style: TextStyle(
                    color: widget.status == 'online' ? accentColor : Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Icône d'appel vidéo
          IconButton(
            icon: Icon(Icons.videocam_rounded, color: accentColor, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appel vidéo (À implémenter)')),
              );
            },
          ),
          // Icône de menu/options
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
      
      // 2. Corps de la conversation
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Pour que les nouveaux messages apparaissent en bas
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final messageData = _messages[_messages.length - 1 - index]; // Afficher du plus récent au plus ancien
                return MessageBubble(
                  message: messageData['message']!,
                  time: messageData['time']!,
                  isMe: messageData['isMe']!,
                  isRead: messageData['isRead']!,
                );
              },
            ),
          ),
          
          // 3. Barre de saisie de message
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