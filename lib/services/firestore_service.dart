import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserDocument(User? user) async {
    if (user == null) return;
    final docRef = _firestore.collection('users').doc(user.uid);

    final exists = (await docRef.get()).exists;
    if (!exists) {
      await docRef.set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'uid': user.uid,
      });
    }
  }
}