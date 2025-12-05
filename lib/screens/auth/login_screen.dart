import 'package:flutter/material.dart';
import 'package:yoopi/screens/auth/register_screen.dart';
import 'package:yoopi/screens/home/home_screen.dart';
// Écran de Connexion (Login)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Fonction pour gérer la connexion (implémentation Firebase à venir)
  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implémenter la logique de connexion Firebase ici.
      // Par exemple : signInWithEmailAndPassword(...);
      
      // Remplacer la SnackBar par la navigation pour tester
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const HomeScreen())
    );
      
      // Exemple de navigation (à remplacer par la vérification de l'état d'authentification)
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Le ScaffoldBackgroundColor est défini dans main.dart, mais on le redéfinit pour la clarté.
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              
              // Titre de l'écran
              const Text(
                'Bienvenue sur Yoopi',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Connectez-vous pour découvrir!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Formulaire de Connexion
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Champ Email
                    _buildTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Veuillez entrer une adresse email valide.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Champ Mot de passe
                    _buildTextField(
                      controller: _passwordController,
                      labelText: 'Mot de passe',
                      icon: Icons.lock_rounded,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Bouton de Connexion
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED), // Violet de votre logo
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Se connecter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const Spacer(flex: 1),

              // Lien vers l'Inscription
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: Text(
                  "Pas encore de compte ? S'inscrire",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget utilitaire pour les champs de texte
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: const Color(0xFFA855F7)), // Icône violette claire
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
      ),
    );
  }
}