import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Créer un profil utilisateur
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String username,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'username': username,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'offline',
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // Récupérer un profil utilisateur
  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  // Mettre à jour le statut
  Future<void> updateStatus(String status) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser.uid).update({
        'status': status,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  // Mettre en ligne (à appeler au démarrage de l'app)
  Future<void> setOnline() async {
    await updateStatus('online');
  }

  // Mettre hors ligne (à appeler au fermeture de l'app)
  Future<void> setOffline() async {
    await updateStatus('offline');
  }

  // Écouter l'état de l'app pour mettre à jour le statut automatiquement
  void setupPresence(){
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Mettre en ligne au démarrage
      setOnline();
    }
      
  }

  // Stream du profil utilisateur
  Stream<DocumentSnapshot> getUserProfileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // Rechercher des utilisateurs
  Future<QuerySnapshot> searchUsers(String query) async {
    final queryLower = query.toLowerCase();

    // Rechercher des utilisateurs par nom d'utilisateur
    return await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();
  }

  // Récupérer tous les utilisateurs (pour les contacts)
  Future<QuerySnapshot> getAllUsers() async {
    return await _firestore
        .collection('users')
        .orderBy('username')
        .limit(50)
        .get();
  }

  // Récupérer l'utilisateur actuel
  String? get currentUserId => _auth.currentUser?.uid;
}