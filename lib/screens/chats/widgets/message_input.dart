import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendMessage;
  final VoidCallback onAttachFile;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSendMessage,
    required this.onAttachFile,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final accentColor = const Color(0xFFA855F7); // Violet clair du logo

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95), // Fond légèrement transparent
        // Vous pouvez ajouter une bordure supérieure ou un léger shadow
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5)),
      ),
      child: SafeArea( // S'assure de ne pas chevaucher la barre système inférieure
        child: Row(
          children: [
            // Bouton d'attachement de fichier
            IconButton(
              icon: Icon(Icons.attach_file_rounded, color: primaryColor, size: 28),
              onPressed: onAttachFile,
              tooltip: 'Attacher un fichier',
            ),
            
            // Champ de saisie de texte
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Écrire un message...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
                ),
                maxLines: null, // Permet plusieurs lignes
                keyboardType: TextInputType.multiline,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Bouton d'envoi
            FloatingActionButton.small( // Utilise un FAB plus petit
              onPressed: onSendMessage,
              backgroundColor: accentColor, // Couleur violette claire pour l'envoi
              child: const Icon(Icons.send_rounded, color: Colors.white),
              elevation: 0, // Pour un look plus plat
            ),
          ],
        ),
      ),
    );
  }
}