import 'package:flutter/material.dart';
import 'package:yoopi/screens/chats/widgets/chat_tile.dart'; // Pour le FAB
import 'package:yoopi/screens/groups/create_group_screen.dart';
import 'package:yoopi/screens/chats/chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  // Données de simulation pour la Phase 1
  final List<Map<String, dynamic>> dummyChats = const [
    {
      'name': 'Équipe Projet Yoopi',
      'message': 'OK, on se retrouve demain à 10h.',
      'time': '14:30',
      'unread': 3,
      'isGroup': true,
      'status': 'online', // Ajout du statut
    },
    {
      'name': 'Amélie Dubois',
      'message': 'Tu as vu la nouvelle fonctionnalité ?',
      'time': '12:00',
      'unread': 12,
      'isGroup': false,
      'status': 'online', // Ajout du statut
    },
    {
      'name': 'Idées Vidéos TikTok',
      'message': 'J\'ai une idée de script de reel !',
      'time': 'Hier',
      'unread': 0,
      'isGroup': true,
      'status': 'offline', // Ajout du statut
    },
    {
      'name': 'Jean Dupont',
      'message': 'Super, je te tiens au courant.',
      'time': '10/04/25',
      'unread': 0,
      'isGroup': false,
      'status': 'online', // Ajout du statut
    },
    {
      'name': 'Groupe de Test Général',
      'message': 'Message trop long pour être affiché en entier...',
      'time': '09/04/25',
      'unread': 99,
      'isGroup': true,
      'status': 'online', // Ajout du statut
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Nous utilisons un Scaffold ici uniquement pour le FloatingActionButton, 
    // car l'AppBar est gérée par le HomeScreen.
    return Scaffold(
      body: ListView.builder(
        itemCount: dummyChats.length,
        itemBuilder: (context, index) {
          final chat = dummyChats[index];
          
          return InkWell(
            // Navigation vers l'écran de discussion détaillée
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    chatName: chat['name']!,
                    status: chat['status']!,
                  ),
                ),
              );
            },
            child: ChatTile(
              name: chat['name']!,
              lastMessage: chat['message']!,
              time: chat['time']!,
              unreadCount: chat['unread']!,
              isGroup: chat['isGroup']!,
            ),
          );
        },
      ),
      
      // Floating Action Button pour créer un nouveau chat/groupe
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigation vers l'écran de création de groupe/chat
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
}