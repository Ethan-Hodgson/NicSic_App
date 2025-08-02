import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'symptom_history_screen.dart'; // <-- import this!

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<AppUser?> _userFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userFuture = user != null
        ? FirestoreService().getUser(user.uid)
        : Future.value(null);
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildBadge({required String label, required IconData icon, required bool earned, required Color color}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: earned ? color : Colors.grey[300],
          child: Icon(
            icon,
            color: earned ? Colors.white : Colors.grey[500],
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: earned ? color : Colors.grey)),
      ],
    );
  }

  // --- Add navigation function for history
  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SymptomHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
        ),
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<AppUser?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!;
          final badges = user.badges ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),

                // Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 70, color: Colors.grey[600]),
                ),

                const SizedBox(height: 32),
                Text(
                  user.name ?? "User’s Name",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  user.email ?? "User’s email",
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Badges section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Your Badges", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBadge(
                            label: "Bronze",
                            icon: Icons.emoji_events,
                            earned: badges.contains('bronze'),
                            color: Colors.brown,
                          ),
                          _buildBadge(
                            label: "Silver",
                            icon: Icons.emoji_events,
                            earned: badges.contains('silver'),
                            color: Colors.grey,
                          ),
                          _buildBadge(
                            label: "Gold",
                            icon: Icons.emoji_events,
                            earned: badges.contains('gold'),
                            color: Colors.amber[700]!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- History Button ---
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.history),
                    label: const Text("View Symptom History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    onPressed: _navigateToHistory,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Settings button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Settings coming soon!")),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text("Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 18),

                // Log out button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text("Log Out", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          );
        },
      ),
    );
  }
}