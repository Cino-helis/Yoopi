import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestFirebaseSimple extends StatelessWidget {
  const TestFirebaseSimple({super.key});

  Future<void> testAuth() async {
    try {
      // Test authentification
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "test${DateTime.now().millisecondsSinceEpoch}@yoopi.com",
        password: "test123456",
      );
      print("✅ AUTH OK ! User: ${credential.user?.uid}");
    } catch (e) {
      print("❌ AUTH Erreur: $e");
    }
  }

  Future<void> testFirestore() async {
    try {
      // Test Firestore
      await FirebaseFirestore.instance.collection('test').add({
        'message': 'Hello Yoopi',
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("✅ FIRESTORE OK !");
    } catch (e) {
      print("❌ FIRESTORE Erreur: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0B2E),
      appBar: AppBar(
        title: const Text("Test Firebase"),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: testAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text("Tester Authentication", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: testFirestore,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA855F7),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text("Tester Firestore", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}