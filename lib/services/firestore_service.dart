import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserDocument(User? user) async {
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'createdAt': Timestamp.now(),
        'streak': 0,
        'badges': [],
        'tokens': 0,
      });
    }
  }
}