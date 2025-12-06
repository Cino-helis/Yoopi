import 'package:flutter/material.dart';
import 'package:yoopi/screens/home/home_screen.dart';
import 'package:yoopi/providers/auth_provider.dart';
import 'package:provider/provider.dart';


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

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fonction d'inscription avec Firebase
  Future<void> _handleRegister() async {
    // Effacer l'erreur précédente
    context.read<AuthProvider>().clearError();

    // Valider le formulaire
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Appeler le service d'authentification
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // Navigation vers HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Afficher l'erreur via SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Erreur lors de l\'inscription'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Créer un compte',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Stack(
            children: [
              // Contenu principal
              SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

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
                            enabled: !authProvider.isLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un nom d\'utilisateur.';
                              }
                              if (value.length < 3) {
                                return 'Le nom d\'utilisateur doit contenir au moins 3 caractères.';
                              }
                              if (value.contains(' ')) {
                                return 'Le nom d\'utilisateur ne peut pas contenir d\'espaces.';
                              }
                              // Vérifier les caractères autorisés
                              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                                return 'Utilisez uniquement des lettres, chiffres et _.';
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
                            enabled: !authProvider.isLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre email.';
                              }
                              if (!value.contains('@')) {
                                return 'Veuillez entrer une adresse email valide.';
                              }
                              // Validation email plus stricte
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Format d\'email invalide.';
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
                            enabled: !authProvider.isLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un mot de passe.';
                              }
                              if (value.length < 6) {
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
                      onPressed: authProvider.isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA855F7),
                        disabledBackgroundColor: const Color(0xFFA855F7).withOpacity(0.5),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "S'inscrire",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // Overlay de chargement
              if (authProvider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFA855F7),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Widget utilitaire pour les champs de texte
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? Colors.white : Colors.white.withOpacity(0.5),
      ),
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: enabled ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.3),
        ),
        prefixIcon: Icon(
          icon,
          color: enabled ? const Color(0xFFA855F7) : const Color(0xFFA855F7).withOpacity(0.5),
        ),
        filled: true,
        fillColor: enabled ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.04),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05), width: 1.5),
        ),
      ),
    );
  }
}