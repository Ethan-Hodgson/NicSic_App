import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a user document from AppUser model if it doesn't exist
  Future<void> createUserDocument(AppUser user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      await docRef.set(user.toMap());
      print("Firestore document created for UID: ${user.uid}");
    }
  }

  /// Fetches the AppUser from Firestore
  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!);
      } else {
        print("No user document found for UID: $uid");
        return null;
      }
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  /// Rewards for currentStreak: Give badge and token at 30/60/90
  Future<void> handleStreakRewards(User user, int streak) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();
    List<String> badges = List<String>.from(doc.data()?['badges'] ?? []);
    int tokens = doc.data()?['tokens'] ?? 0;

    bool changed = false;

    // 30 day badge
    if (streak >= 30 && !badges.contains('bronze')) {
      badges.add('bronze');
      tokens += 1;
      changed = true;
    }
    // 60 day badge
    if (streak >= 60 && !badges.contains('silver')) {
      badges.add('silver');
      tokens += 1;
      changed = true;
    }
    // 90 day badge
    if (streak >= 90 && !badges.contains('gold')) {
      badges.add('gold');
      tokens += 1;
      changed = true;
    }
    if (changed) {
      await userRef.update({'badges': badges, 'tokens': tokens});
    }
  }

  /// Call when user wins game to award badge
  Future<void> awardBadgeAfterGame(User user, String challengeKey) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    final data = doc.data();
    if (data == null) return;
    final badges = List<String>.from(data['badges'] ?? []);

    final challengeToBadge = {
      'streak_30': 'bronze',
      'streak_60': 'silver',
      'streak_90': 'gold',
    };

    final badgeToAward = challengeToBadge[challengeKey];
    if (badgeToAward != null && !badges.contains(badgeToAward)) {
      badges.add(badgeToAward);
      await docRef.update({'badges': badges});
    }
  }

  /// Get all user challenge completion info for display
  Future<List<String>> getCompletedChallenges(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return [];
    return List<String>.from(data['completedChallenges'] ?? []);
  }

  /// Update the user's token count (NEW: for game access, etc)
  Future<void> updateTokens(String uid, int newTokenCount) async {
    await _firestore.collection('users').doc(uid).update({
      'tokens': newTokenCount,
    });
  }
}