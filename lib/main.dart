import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yoopi/screens/splash/splash_screen.dart';
import 'firebase_options.dart';
import 'services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class YoopiApp extends StatefulWidget {
  const YoopiApp({super.key});

  @override
  State<YoopiApp> createState() => _YoopiAppState();
}

class _YoopiAppState extends State<YoopiApp> with WidgetsBindingObserver {
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Écouter les changements d'authentification
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _userService.setOnline();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // App au premier plan
        _userService.setOnline();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // App en arrière-plan ou fermée
        _userService.setOffline();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yoopi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF1A0B2E),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const SplashScreenWithAuth(),
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
    await Future.delayed(const Duration(seconds: 10));

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