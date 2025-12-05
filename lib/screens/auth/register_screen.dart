import 'package:flutter/material.dart';
import 'package:yoopi/screens/home/home_screen.dart';

// Écran d'Inscription (Register)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Fonction pour gérer l'inscription (implémentation Firebase à venir)
  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implémenter la logique d'inscription Firebase ici.
      // Par exemple : createUserWithEmailAndPassword(...);
      
      // Remplacer la SnackBar par la navigation pour tester
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const HomeScreen())
    );
      
      // Après une inscription réussie, vous pouvez revenir à l'écran de connexion :
      // Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // L'AppBar est discrète et permet de revenir en arrière
        backgroundColor: Colors.transparent, 
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Flèche de retour blanche
        title: const Text(
          'Créer un compte',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20), // Espace après l'AppBar
            
            // Titre de l'écran
            const Text(
              'Rejoignez la communauté !',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Inscrivez-vous en quelques secondes.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Formulaire d'Inscription
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Champ Nom d'utilisateur
                  _buildTextField(
                    controller: _usernameController,
                    labelText: 'Nom d\'utilisateur',
                    icon: Icons.person_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 3) {
                        return 'Le nom d\'utilisateur doit contenir au moins 3 caractères.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
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

            // Bouton d'Inscription
            ElevatedButton(
              onPressed: _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA855F7), // Violet clair/vif
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "S'inscrire",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Note: Le lien vers la connexion n'est pas nécessaire ici car l'AppBar permet déjà de revenir.
          ],
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
        prefixIcon: Icon(icon, color: const Color(0xFFA855F7)), 
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