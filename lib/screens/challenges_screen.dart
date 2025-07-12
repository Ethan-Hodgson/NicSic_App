import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  late Future<AppUser?> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userFuture = user != null
          ? FirestoreService().getUser(user.uid)
          : Future.value(null);
    });
  }

  bool hasTrackedToday(DateTime? lastTracked) {
    if (lastTracked == null) return false;
    final now = DateTime.now();
    return now.year == lastTracked.year &&
        now.month == lastTracked.month &&
        now.day == lastTracked.day;
  }

  Widget _buildChallengeTile({
    required String label,
    required int currentValue,
    required int goal,
    required bool isBadge,
    required bool completed,
  }) {
    return Card(
      color: completed ? Colors.green[50] : null,
      elevation: 0,
      child: ListTile(
        leading: Icon(
          isBadge ? Icons.emoji_events : Icons.check_circle,
          color: completed ? Colors.green : Colors.grey,
        ),
        title: Text(label),
        subtitle: isBadge
            ? Text("Earn badge and a token")
            : Text("Earn a token"),
        trailing: Text(
          "$currentValue / $goal",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: completed ? Colors.green : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Challenges"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUser,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: FutureBuilder<AppUser?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!;
          final streak = user.currentStreak;
          final trackedToday = hasTrackedToday(user.lastTracked);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                "Consecutive Days Streak",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              // Track Symptoms Today Challenge (uses trackedToday)
              _buildChallengeTile(
                label: "Track symptoms today",
                currentValue: trackedToday ? 1 : 0,
                goal: 1,
                isBadge: false,
                completed: trackedToday,
              ),
              // 30 Day Challenge
              _buildChallengeTile(
                label: "30 Day Streak",
                currentValue: streak > 30 ? 30 : streak,
                goal: 30,
                isBadge: true,
                completed: streak >= 30,
              ),
              // 60 Day Challenge
              _buildChallengeTile(
                label: "60 Day Streak",
                currentValue: streak > 60 ? 60 : streak,
                goal: 60,
                isBadge: true,
                completed: streak >= 60,
              ),
              // 90 Day Challenge
              _buildChallengeTile(
                label: "90 Day Streak",
                currentValue: streak > 90 ? 90 : streak,
                goal: 90,
                isBadge: true,
                completed: streak >= 90,
              ),
              const SizedBox(height: 24),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.monetization_on, color: Colors.purple),
                title: const Text("How do I earn tokens?"),
                subtitle: const Text("Earn one token for each day you track your symptoms. Complete 30, 60, and 90 day streaks to earn special badges and extra tokens!"),
              ),
            ],
          );
        },
      ),
    );
  }
}