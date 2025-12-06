import 'package:flutter/material.dart';
import 'package:yoopi/screens/auth/register_screen.dart';
import 'package:yoopi/providers/auth_provider.dart';
import 'package:provider/provider.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fonction de connexion avec Firebase
  Future<void> _handleLogin() async {
    // Effacer l'erreur précédente
    context.read<AuthProvider>().clearError();

    // Valider le formulaire
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Appeler le service d'authentification
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
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
          content: Text(authProvider.errorMessage ?? 'Erreur de connexion'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Stack(
            children: [
              // Contenu principal
              SingleChildScrollView(
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
                              enabled: !authProvider.isLoading,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre email.';
                                }
                                if (!value.contains('@')) {
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
                              enabled: !authProvider.isLoading,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre mot de passe.';
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

                      // Bouton de Connexion
                      ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          disabledBackgroundColor: const Color(0xFF7C3AED).withOpacity(0.5),
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
                        onPressed: authProvider.isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterScreen(),
                                  ),
                                );
                              },
                        child: Text(
                          "Pas encore de compte ? S'inscrire",
                          style: TextStyle(
                            color: authProvider.isLoading
                                ? Colors.white.withOpacity(0.4)
                                : Colors.white.withOpacity(0.8),
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Overlay de chargement (optionnel, déjà géré par le bouton)
              if (authProvider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF7C3AED),
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