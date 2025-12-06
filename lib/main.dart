import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:yoopi/screens/splash/splash_screen.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';

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
    // Envelopper avec MultiProvider
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
        home: const SplashScreen(),
      ),
    );
  }
}