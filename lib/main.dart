import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yoopi/screens/splash/splash_screen.dart';
import 'firebase_options.dart';

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
    return MaterialApp(
      title: 'Yoopi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF1A0B2E),
        fontFamily: 'Poppins', // Vous devrez ajouter cette font dans pubspec.yaml
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}