import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe; // True si le message est envoyé par l'utilisateur courant
  final bool isRead; // True si le message a été lu (pour les messages envoyés)

  const MessageBubble({
    super.key,
    required this.message,
    required this.time,
    required this.isMe,
    this.isRead = false, // Par défaut non lu
  });

  @override
  Widget build(BuildContext context) {
    // Couleurs du thème Yoopi
    final primaryColor = Theme.of(context).primaryColor; // deepPurple
    final accentColor = const Color(0xFFA855F7); // Violet clair du logo

    // Alignement du message (droite pour moi, gauche pour l'autre)
    final AlignmentGeometry alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    // Couleur de fond de la bulle
    final Color bubbleColor = isMe ? accentColor : Colors.white.withOpacity(0.15); // Violet clair ou gris foncé
    // Couleur du texte du message
    final Color textColor = isMe ? Colors.white : Colors.white;
    // Couleur du temps et de la coche
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
                maxWidth: MediaQuery.of(context).size.width * 0.75, // Limite la largeur de la bulle
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
              ),
              child: Text(
                message,
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min, // Occupe l'espace minimal
              children: [
                Text(
                  time,
                  style: TextStyle(color: timeColor, fontSize: 12),
                ),
                if (isMe) ...[ // Afficher la coche seulement pour les messages envoyés
                  const SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 16,
                    color: isRead ? primaryColor : timeColor, // La double coche lue peut être colorée différemment
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