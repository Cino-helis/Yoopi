import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String avatarUrl; // Pour les avatars futurs
  final bool isGroup; // Pour distinguer les icônes

  const ChatTile({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.avatarUrl = '',
    this.isGroup = false,
  });

  @override
  Widget build(BuildContext context) {
    // La couleur primaire est utilisée pour les indicateurs actifs
    final primaryColor = Theme.of(context).primaryColor; 

    return InkWell(
      // TODO: Naviguer vers ChatDetailScreen (Phase 1)
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ouverture du chat avec $name')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          children: [
            // 1. Avatar (avec icône de groupe si nécessaire)
            CircleAvatar(
              radius: 30,
              backgroundColor: isGroup ? primaryColor.withOpacity(0.5) : Colors.white.withOpacity(0.2),
              child: isGroup
                  ? Icon(Icons.groups_rounded, color: Colors.white, size: 30)
                  : Text(
                      name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
              // TODO: Utiliser NetworkImage si avatarUrl n'est pas vide
            ),
            
            const SizedBox(width: 15),
            
            // 2. Infos du Chat (Nom et dernier message)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
                      fontSize: 17,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      color: unreadCount > 0 ? Colors.white : Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontStyle: unreadCount > 0 ? FontStyle.italic : FontStyle.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // 3. Heure et Compteur de non-lus
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: unreadCount > 0 ? primaryColor : Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: primaryColor, // Utilise la couleur primaire
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}