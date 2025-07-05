import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final DateTime createdAt;
  final DateTime? lastTracked;
  final int currentStreak;
  final List<String> badges;
  final int tokens;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdAt,
    this.lastTracked,
    required this.currentStreak,
    required this.badges,
    required this.tokens,
  });

  factory AppUser.fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? 'User',
      createdAt: DateTime.now(),
      lastTracked: null,
      currentStreak: 0,
      badges: [],
      tokens: 0,
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastTracked: data['lastTracked'] != null
          ? (data['lastTracked'] as Timestamp).toDate()
          : null,
      currentStreak: data['currentStreak'] ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
      tokens: data['tokens'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastTracked': lastTracked != null
          ? Timestamp.fromDate(lastTracked!)
          : null,
      'currentStreak': currentStreak,
      'badges': badges,
      'tokens': tokens,
    };
  }
}