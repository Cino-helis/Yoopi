import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String avatarUrl;
  final bool isGroup;
  final bool isOnline; // AJOUTÉ

  const ChatTile({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.avatarUrl = '',
    this.isGroup = false,
    this.isOnline = false, // AJOUTÉ
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          // Avatar avec indicateur de statut
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: isGroup ? primaryColor.withOpacity(0.5) : Colors.white.withOpacity(0.2),
                child: isGroup
                    ? const Icon(Icons.groups_rounded, color: Colors.white, size: 30)
                    : Text(
                        name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
              ),
              // AJOUTÉ : Indicateur de statut (seulement pour les chats privés)
              if (!isGroup)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 15),
          
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
                    fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: unreadCount > 0 ? primaryColor : Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  constraints: const BoxConstraints(minWidth: 20),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}