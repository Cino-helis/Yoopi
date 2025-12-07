import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:yoopi/screens/splash/splash_screen.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuration de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const YoopiApp());
}

class YoopiApp extends StatelessWidget {
  const YoopiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Ajoutez d'autres providers ici plus tard
      ],
      child: MaterialApp(
        title: 'Yoopi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: const Color(0xFF1A0B2E),
          fontFamily: 'Poppins',
          useMaterial3: true,
        ),
        // Utiliser AuthWrapper au lieu de SplashScreen directement
        // AuthWrapper vérifie automatiquement l'état de connexion
        home: const SplashScreenWithAuth(),
      ),
    );
  }
}

/// Écran qui affiche le Splash puis redirige selon l'état de connexion
class SplashScreenWithAuth extends StatefulWidget {
  const SplashScreenWithAuth({super.key});

  @override
  State<SplashScreenWithAuth> createState() => _SplashScreenWithAuthState();
}

class _SplashScreenWithAuthState extends State<SplashScreenWithAuth> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    // Attendre 3 secondes pour l'animation du splash
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // Naviguer vers AuthWrapper qui gère la logique de connexion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}