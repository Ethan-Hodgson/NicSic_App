import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  /// Sign-in using Email & Password
  Future<void> signInWithEmail(String email, String password) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCred.user;
      if (firebaseUser != null) {
        final appUser = AppUser.fromFirebaseUser(firebaseUser);
        await _firestoreService.createUserDocument(appUser);
      }
    } catch (e) {
      print('Email Sign-In Failed: $e');
    }
  }

  /// Sign-in using Google
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final firebaseUser = userCred.user;
      if (firebaseUser != null) {
        final appUser = AppUser.fromFirebaseUser(firebaseUser);
        await _firestoreService.createUserDocument(appUser);
      }
    } catch (e) {
      print('Google Sign-In Failed: $e');
    }
  }

  /// Sign-up using Email & Password
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCred.user;
      if (firebaseUser != null) {
        final appUser = AppUser.fromFirebaseUser(firebaseUser);
        await _firestoreService.createUserDocument(appUser);
      }
    } catch (e) {
      print('Email Sign-Up Failed: $e');
    }
  }
}