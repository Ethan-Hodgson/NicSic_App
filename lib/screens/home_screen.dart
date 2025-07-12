import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nicsick_app/screens/symptom_tracker_screen.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'challenges_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<AppUser?> _userFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userFuture = user != null
          ? FirestoreService().getUser(user.uid)
          : Future.value(null);
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _onNavBarTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      final tokenEarned = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const SymptomTrackerScreen()),
      );
      _loadUserData();
      if (tokenEarned == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You earned a token for tracking today!"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.deepPurple,
          ),
        );
      }
    } else if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChallengesScreen()),
      );
      _loadUserData();
    }
    // Add logic for History, Profile as needed
  }

  String formatLastTracked(DateTime? lastTracked) {
    if (lastTracked == null) return "Never";
    final now = DateTime.now();
    final difference = now.difference(lastTracked);

    if (difference.inDays == 0) {
      return "Today";
    } else if (difference.inDays == 1) {
      return "1 day ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return "$weeks week${weeks > 1 ? 's' : ''} ago";
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return "$months month${months > 1 ? 's' : ''} ago";
    } else {
      final years = (difference.inDays / 365).floor();
      return "$years year${years > 1 ? 's' : ''} ago";
    }
  }

  void _navigateToGameScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Game screen coming soon!")),
    );
  }

  void _navigateToHealthInfoScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Health info coming soon!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NicSic"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<AppUser?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("User data not found."));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Welcome back, ${user.name}",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () async {
                    final tokenEarned = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => const SymptomTrackerScreen()),
                    );
                    _loadUserData();
                    if (tokenEarned == true && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("You earned a token for tracking today!"),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.deepPurple,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20)),
                  child: const Text("Track Symptoms", style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Last Tracked", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              formatLastTracked(user.lastTracked),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.insert_chart, size: 36),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.green[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.emoji_events, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Current Streak", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("${user.currentStreak} days"),
                          const Text("Keep it up!"),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: _navigateToHealthInfoScreen,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.red[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.health_and_safety, size: 30),
                        ),
                        const SizedBox(width: 18),
                        const Expanded(
                          child: Text(
                            "Health",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 18)
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.purple[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.auto_awesome, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Tokens", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("${user.tokens}"),
                            const Text("Earn by completing challenges"),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _navigateToGameScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Use Token"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[200],
        unselectedItemColor: Colors.blue,
        selectedItemColor: Colors.blue,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onNavBarTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Track'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Challenges'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}