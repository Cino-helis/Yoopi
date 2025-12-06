import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Instances Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de l'utilisateur courant (pour écouter les changements d'état)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obtenir l'utilisateur courant
  User? get currentUser => _auth.currentUser;

  // Vérifier si un utilisateur est connecté
  bool get isSignedIn => _auth.currentUser != null;

  /// INSCRIPTION (Register)
  /// Crée un nouveau compte utilisateur avec email/password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Vérifier si le username existe déjà
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'Ce nom d\'utilisateur est déjà pris.',
        };
      }

      // Créer le compte Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Créer le document utilisateur dans Firestore
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

        // Mettre à jour le profil Firebase Auth
        await user.updateDisplayName(username.trim());

        return {
          'success': true,
          'message': 'Inscription réussie !',
          'user': user,
        };
      }

      return {
        'success': false,
        'message': 'Erreur lors de la création du compte.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur inattendue s\'est produite : $e',
      };
    }
  }

  /// CONNEXION (Login)
  /// Connecte un utilisateur existant avec email/password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Mettre à jour le statut en ligne dans Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        });

        return {
          'success': true,
          'message': 'Connexion réussie !',
          'user': user,
        };
      }

      return {
        'success': false,
        'message': 'Erreur lors de la connexion.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Une erreur inattendue s\'est produite : $e',
      };
    }
  }

  /// DÉCONNEXION (Logout)
  /// Déconnecte l'utilisateur courant
  Future<Map<String, dynamic>> signOut() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        // Mettre à jour le statut hors ligne dans Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }

      await _auth.signOut();

      return {
        'success': true,
        'message': 'Déconnexion réussie.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la déconnexion : $e',
      };
    }
  }

  /// RÉINITIALISATION DU MOT DE PASSE
  /// Envoie un email de réinitialisation
  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());

      return {
        'success': true,
        'message': 'Email de réinitialisation envoyé. Vérifiez votre boîte mail.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'envoi de l\'email : $e',
      };
    }
  }

  /// SUPPRIMER LE COMPTE
  /// Supprime le compte utilisateur et ses données
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        // Supprimer le document Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Supprimer le compte Firebase Auth
        await user.delete();

        return {
          'success': true,
          'message': 'Compte supprimé avec succès.',
        };
      }

      return {
        'success': false,
        'message': 'Aucun utilisateur connecté.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la suppression du compte : $e',
      };
    }
  }

  /// MESSAGES D'ERREUR PERSONNALISÉS
  /// Traduit les codes d'erreur Firebase en messages compréhensibles
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé par un autre compte.';
      case 'invalid-email':
        return 'L\'adresse email est invalide.';
      case 'operation-not-allowed':
        return 'Cette opération n\'est pas autorisée.';
      case 'weak-password':
        return 'Le mot de passe est trop faible. Utilisez au moins 6 caractères.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'user-not-found':
        return 'Aucun compte ne correspond à cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'invalid-credential':
        return 'Les identifiants fournis sont invalides.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'network-request-failed':
        return 'Erreur de connexion. Vérifiez votre connexion internet.';
      default:
        return 'Une erreur s\'est produite. Code: $code';
    }
  }
}