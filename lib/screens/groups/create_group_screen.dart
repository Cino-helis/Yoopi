import 'package:flutter/material.dart';
import 'package:yoopi/screens/chats/user_search_screen.dart';

class CreateGroupScreen extends StatelessWidget {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final accentColor = const Color(0xFFA855F7);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nouveau',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          
          // Option 1 : Nouveau chat individuel
          _buildOption(
            context: context,
            icon: Icons.person_add_rounded,
            title: 'Nouveau chat',
            subtitle: 'Démarrer une conversation privée',
            color: accentColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserSearchScreen(),
                ),
              );
            },
          ),
          
          const Divider(
            color: Colors.white24,
            height: 1,
            indent: 72,
          ),
          
          // Option 2 : Nouveau groupe (à implémenter)
          _buildOption(
            context: context,
            icon: Icons.group_add_rounded,
            title: 'Nouveau groupe',
            subtitle: 'Créer un groupe avec plusieurs personnes',
            color: primaryColor,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Création de groupe (À implémenter)'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          
          const Divider(
            color: Colors.white24,
            height: 1,
            indent: 72,
          ),
          
          // Option 3 : Nouveau canal (à implémenter)
          _buildOption(
            context: context,
            icon: Icons.campaign_rounded,
            title: 'Nouveau canal',
            subtitle: 'Créer un canal public',
            color: const Color(0xFF10B981), // Vert
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Création de canal (À implémenter)'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            // Icône
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Flèche
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.4),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}