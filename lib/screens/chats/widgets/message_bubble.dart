import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageBubble extends StatelessWidget {
  final String chatId;
  final String messageId;
  final String message;
  final String time;
  final bool isMe;
  final bool isRead;

  const MessageBubble({
    super.key,
    required this.chatId,
    required this.messageId,
    required this.message,
    required this.time,
    required this.isMe,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final accentColor = const Color(0xFFA855F7);

    final AlignmentGeometry alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final Color bubbleColor = isMe ? accentColor : Colors.white.withOpacity(0.15);
    final Color textColor = Colors.white;
    final Color timeColor = isMe ? Colors.white70 : Colors.white70;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16.0),
                  topRight: const Radius.circular(16.0),
                  bottomLeft: isMe ? const Radius.circular(16.0) : const Radius.circular(4.0),
                  bottomRight: isMe ? const Radius.circular(4.0) : const Radius.circular(16.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message,
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(color: timeColor, fontSize: 12),
                ),
                if (isMe) ...[ 
                  const SizedBox(width: 4),
                  // StreamBuilder pour mettre à jour l'état de lecture en temps réel
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatId)
                        .collection('messages')
                        .doc(messageId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      bool messageIsRead = isRead;
                      
                      if (snapshot.hasData && snapshot.data != null) {
                        final data = snapshot.data!.data() as Map<String, dynamic>?;
                        messageIsRead = data?['isRead'] ?? false;
                      }
                      
                      return Icon(
                        messageIsRead ? Icons.done_all_rounded : Icons.done_rounded,
                        size: 16,
                        color: messageIsRead 
                            ? const Color(0xFF10B981) // Vert pour "lu"
                            : timeColor, // Gris pour "envoyé"
                      );
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}