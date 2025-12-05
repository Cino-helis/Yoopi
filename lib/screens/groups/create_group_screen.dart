import 'package:flutter/material.dart';

class CreateGroupScreen extends StatelessWidget {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // L'AppBar pour l'écran de création
      appBar: AppBar(
        title: const Text(
          'Nouveau Chat/Groupe',
          style: TextStyle(color: Colors.white),
        ),
        // Assurez-vous que l'AppBar est bien dans le thème sombre
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: const IconThemeData(color: Colors.white), // Flèche de retour blanche
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_alt_1_rounded, color: Colors.white54, size: 60),
              SizedBox(height: 16),
              Text(
                'Écran de sélection des contacts (Phase 1)',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}