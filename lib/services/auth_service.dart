import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Email Sign-in
  Future<void> signInWithEmail(String email, String password) async {
    final userCred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = userCred.user;
    if (firebaseUser != null) {
      final appUser = AppUser.fromFirebaseUser(firebaseUser);
      await _firestoreService.createUserDocument(appUser);
    }
  }

  // Google Sign-In (new provider flow)
  Future<void> signInWithGoogle() async {
    final googleProvider = GoogleAuthProvider();
    final userCredential = await _auth.signInWithProvider(googleProvider);
    final firebaseUser = userCredential.user;
    if (firebaseUser != null) {
      final appUser = AppUser.fromFirebaseUser(firebaseUser);
      await _firestoreService.createUserDocument(appUser);
    }
  }

  // Email Sign-up
  Future<void> signUpWithEmail(String email, String password) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = userCred.user;
    if (firebaseUser != null) {
      final appUser = AppUser.fromFirebaseUser(firebaseUser);
      await _firestoreService.createUserDocument(appUser);
    }
  }

  // Sign-out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}