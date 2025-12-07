import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yoopi/screens/auth/login_screen.dart';
import 'package:yoopi/screens/home/home_screen.dart';

/// AuthWrapper vérifie l'état de connexion au démarrage
/// Si l'utilisateur est connecté → HomeScreen
/// Sinon → LoginScreen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Écoute les changements d'état d'authentification
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // En attente de la vérification
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1A0B2E),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7C3AED),
              ),
            ),
          );
        }

        // Utilisateur connecté
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // Utilisateur non connecté
        return const LoginScreen();
      },
    );
  }
}