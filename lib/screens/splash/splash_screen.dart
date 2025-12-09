import 'package:flutter/material.dart';
import 'package:yoopi/screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    
    // Configuration des animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );
    
    _controller.forward();
    
    // TODO: Navigation automatique après 3 secondes vers Login/Onboarding
    //_navigateToNext();
  }

  // void _navigateToNext() {
    /* Future.delayed(const Duration(seconds: 0), () {
       if (mounted) {
         Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
         );
       }
     });
   }*/

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0B2E), // Violet foncé
      body: Stack(
        children: [
          // Gradient background subtil
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A0B2E),
                  Color(0xFF2D1B4E),
                  Color(0xFF1A0B2E),
                ],
              ),
            ),
          ),
          
          // Contenu principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // Logo animé
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          children: [
                            // Icône d'avion en papier
                            _buildCustomLogo(),
                            
                            const SizedBox(height: 24),
                            
                            // Nom de l'app
                            Text(
                              'Yoopi',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF7C3AED).withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Slogan
                            Text(
                              'Connecter. Envoyer. Découvrir.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.7),
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const Spacer(flex: 3),
                
                // Indicateur de chargement (NOUVEAU)
                _buildLoadingIndicator(),
                
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomLogo() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/Yoopiicons.png', // Chemin vers votre logo
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback si l'image n'est pas trouvée
            return _buildFallbackLogo();
          },
        ),
      ),
    );
  }

  // Logo de secours si l'image personnalisée n'est pas trouvée
  Widget _buildFallbackLogo() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7C3AED), // Violet
            Color(0xFFA855F7), // Violet clair
          ],
        ),
        
      ),
      child: const Icon(
        Icons.send_rounded,
        size: 70,
        color: Colors.white,
      ),
    );
  }

  // NOUVEAU: Indicateur de chargement circulaire
  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 30, 
      height: 30,
      child: CircularProgressIndicator(
        color: Color(0xFF7C3AED), // Couleur violette de l'indicateur
        strokeWidth: 3,
      ),
        );
  }
}