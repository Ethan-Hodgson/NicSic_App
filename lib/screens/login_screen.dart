import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  // --- Main change: after login, ask for notification permission if not asked before
  Future<void> _afterSuccessfulLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final asked = prefs.getBool('asked_notification_permission') ?? false;

    if (!asked) {
      final shouldAsk = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Daily Reminder Notifications"),
          content: const Text(
              "NicSick can remind you to track your symptoms every day. Would you like to enable daily notifications?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text("No, Thanks")),
            ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text("Allow")),
          ],
        ),
      );

      if (shouldAsk == true) {
        final granted = await NotificationService.requestPermissions();
        if (granted) {
          await NotificationService.scheduleDailyReminder(hour: 18, minute: 0); // 6PM
        }
      }
      await prefs.setBool('asked_notification_permission', true);
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _loginWithEmail() async {
    setState(() => _isLoading = true);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      await _authService.signInWithEmail(email, password);
      if (mounted) {
        await _afterSuccessfulLogin();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email Sign-In Failed: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        await _afterSuccessfulLogin();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Failed: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log In")),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _loginWithEmail,
                  child: const Text("Log In"),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
                        },
                  child: const Text("Don't have an account? Sign Up"),
                ),
                const Divider(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text("Sign In with Google"),
                  onPressed: _isLoading ? null : _loginWithGoogle,
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}