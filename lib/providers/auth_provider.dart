import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/user_model.dart'; // Décommentez après avoir créé le fichier
// import '../services/auth_service.dart'; // Décommentez après avoir créé le fichier

class AuthProvider with ChangeNotifier {
  // final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // État de chargement
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Utilisateur courant
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Données utilisateur Firestore
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;

  // Message d'erreur
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    // Écouter les changements d'état d'authentification
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _loadUserData();
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  /// CHARGER LES DONNÉES UTILISATEUR DEPUIS FIRESTORE
  Future<void> _loadUserData() async {
    if (_currentUser == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (doc.exists) {
        _userData = doc.data();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des données utilisateur: $e');
    }
  }

  /// INSCRIPTION
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Vérifier si le username existe déjà
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        _errorMessage = 'Ce nom d\'utilisateur est déjà pris.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Créer le compte
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Créer le document dans Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email.trim().toLowerCase(),
          'username': username.trim().toLowerCase(),
          'displayName': username.trim(),
          'photoUrl': '',
          'bio': '',
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'fcmTokens': [],
        });

        await user.updateDisplayName(username.trim());

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Erreur lors de la création du compte.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Une erreur inattendue s\'est produite.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// CONNEXION
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Mettre à jour le statut en ligne
        await _firestore.collection('users').doc(user.uid).update({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        });

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Erreur lors de la connexion.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Une erreur inattendue s\'est produite.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// DÉCONNEXION
  Future<void> signOut() async {
    try {
      if (_currentUser != null) {
        await _firestore.collection('users').doc(_currentUser!.uid).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }

      await _auth.signOut();
      _userData = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
    }
  }

  /// RÉINITIALISER LE MOT DE PASSE
  Future<bool> resetPassword({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'envoi de l\'email.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// EFFACER LE MESSAGE D'ERREUR
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// MESSAGES D'ERREUR TRADUITS
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'invalid-email':
        return 'L\'adresse email est invalide.';
      case 'weak-password':
        return 'Le mot de passe est trop faible (min. 6 caractères).';
      case 'user-not-found':
        return 'Aucun compte ne correspond à cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'invalid-credential':
        return 'Identifiants invalides.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'network-request-failed':
        return 'Erreur de connexion. Vérifiez votre internet.';
      default:
        return 'Une erreur s\'est produite.';
    }
  }
}