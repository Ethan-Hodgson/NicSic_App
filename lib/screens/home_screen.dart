import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'symptom_tracker_screen.dart';
import 'challenges_screen.dart';
import 'profile_screen.dart';
import 'health_info_screen.dart';
import '../game/game_screen.dart';
import 'shop_screen.dart';

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

  Future<void> _loadUserData() async {
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
      await Future.delayed(const Duration(milliseconds: 300));
      await _loadUserData();
      if (tokenEarned == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("You earned a token for tracking today!"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.deepPurple,
          ),
        );
      }
    } else if (index == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ShopScreen()),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      await _loadUserData();
    } else if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChallengesScreen()),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      await _loadUserData();
    } else if (index == 3) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      await _loadUserData();
    }
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

  void _navigateToHealthInfoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HealthInfoScreen()),
    );
  }

  void _navigateToShop() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShopScreen()),
    ).then((_) => _loadUserData());
  }

  void _navigateToGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color background = Colors.grey[100]!;
    final Color card = Colors.white;
    final Color text = Colors.grey[900]!;
    final Color accent = Colors.blueAccent;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: card,
        title: const Text(
          "NicSic",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 24,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: _logout,
            tooltip: "Log out",
          ),
        ],
        centerTitle: true,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, ${user.name}",
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 16),

                // --- Game Card ---
                Container(
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.sports_esports, color: accent, size: 32),
                    title: const Text("Feeling a craving?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    subtitle: const Text("Play a game to distract yourself.", style: TextStyle(fontSize: 15)),
                    trailing: TextButton(
                      onPressed: _navigateToGame,
                      child: const Text("Play", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // --- Track Symptoms Button ---
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButtonFilled(
                    child: const Text("Track Symptoms", style: TextStyle(fontSize: 17)),
                    onPressed: () async {
                      final tokenEarned = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(builder: (_) => const SymptomTrackerScreen()),
                      );
                      await Future.delayed(const Duration(milliseconds: 300));
                      await _loadUserData();
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
                  ),
                ),
                const SizedBox(height: 18),

                // --- Streak/Last Tracked Section ---
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        label: "Last Tracked",
                        value: formatLastTracked(user.lastTracked),
                        icon: Icons.calendar_today_rounded,
                        color: Colors.blue[100]!,
                        textColor: text,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _InfoCard(
                        label: "Current Streak",
                        value: "${user.currentStreak} days",
                        icon: Icons.emoji_events,
                        color: Colors.green[100]!,
                        textColor: text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // --- Health Info ---
                GestureDetector(
                  onTap: _navigateToHealthInfoScreen,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            color: Colors.red[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.health_and_safety, size: 24, color: Colors.white),
                        ),
                        const SizedBox(width: 18),
                        const Expanded(
                          child: Text(
                            "Health Info",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 17)
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // --- Tokens / Shop ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 34, color: Colors.deepPurple[300]),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Tokens", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                            Text("${user.tokens}", style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w400)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _navigateToShop,
                        child: const Text("Shop", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
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
        backgroundColor: card,
        elevation: 0.6,
        unselectedItemColor: Colors.grey[500],
        selectedItemColor: accent,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onNavBarTapped,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Track'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Challenges'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// --- Reusable Card Widget for Info Tiles ---
class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color textColor;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor.withOpacity(0.7), size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.8))),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: textColor)),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Flat iOS-like Button (Cupertino style) ---
class CupertinoButtonFilled extends StatelessWidget {
  final Widget child;
  final void Function()? onPressed;

  const CupertinoButtonFilled({super.key, required this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blueAccent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 17,
              letterSpacing: 0.2,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}