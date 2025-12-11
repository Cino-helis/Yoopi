import 'package:flutter/material.dart';
import 'package:yoopi/screens/chats/chat_list_screen.dart';
import 'package:yoopi/screens/settings/settings_screen.dart';


// --- Placeholders Temporaires pour la structure ---
// Ces écrans seront remplacés par les vrais fichiers plus tard (Phase 1/2/3)

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Note: Ceci affichera la liste des Groupes et Canaux adhérés.
    return const Center(
      child: Text(
        'Liste des Groupes et Canaux (GroupListScreen)',
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class DiscoveryScreen extends StatelessWidget {
  const DiscoveryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Note: Ceci sera le fil vidéo TikTok-like (Phase 3).
    return const Center(
      child: Text(
        'Fil de Découverte Vidéo (DiscoveryScreen)',
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// --- Écran Principal : HomeScreen ---

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Index de l'onglet actif : 0=Chats, 1=Groupes, 2=Découverte
  int _currentIndex = 0;

  // Liste des écrans correspondant aux onglets
  final List<Widget> _screens = [
    const ChatListScreen(),    // 0: Chats (Discussions 1:1) - Écran réel
    const GroupListScreen(),   // 1: Groupes (Groupes et Canaux) - Placeholder
    const DiscoveryScreen(),   // 2: Découverte Vidéo - Placeholder
  ];

  // Fonction appelée lors du changement d'onglet
  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
  // Fonction pour l'action du Menu Hamburger
  void _openSettings() {
    // TODO: Naviguer vers l'écran des Paramètres/Profil (settings_screen.dart)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color primaryColor = Theme.of(context).primaryColor; 
    
    return Scaffold(
      
      // 1. Structure de l'AppBar étendue (Titre, Menu, Barre de recherche)
      appBar: AppBar(
        // Correction de l'overflow : Hauteur ajustée à 130
        toolbarHeight: 150, 
        backgroundColor: Colors.transparent, 
        elevation: 0,
        automaticallyImplyLeading: false,
        
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: backgroundColor, // Couleur de fond du Scaffold
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Ligne 1 : Titre de l'application et Menu Hamburger
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 10.0, top: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nom de l'application (Gauche)
                    const Text(
                      'Yoopi',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    
                    // Menu Hamburger (Droite)
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 30),
                      onPressed: _openSettings,
                      tooltip: 'Menu/Paramètres',
                    ),
                  ],
                ),
              ),
              
              // Ligne 2 : Barre de Recherche (Juste en dessous)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un chat, un groupe ou un utilisateur...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: primaryColor),
                    ),
                    // TODO: Implémenter la logique de recherche
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // 2. Contenu du Body : Affichage de l'écran sélectionné
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      
      // 3. Barre de navigation inférieure (BottomNavigationBar)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        
        backgroundColor: backgroundColor,
        selectedItemColor: const Color(0xFFA855F7), 
        unselectedItemColor: Colors.white.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        
        items: const <BottomNavigationBarItem>[
          // Onglet 1 : Chats (Discussions 1:1)
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            activeIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chats',
          ),
          
          // Onglet 2 : Groupes (Groupes et Canaux)
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups_rounded),
            label: 'Groupes',
          ),
          
          // Onglet 3 : Découverte Vidéo (TikTok-like)
           BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore_rounded),
            label: 'Découverte',
          ),
        ],
      ),
    );
  }
}