import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    await AuthService().signInWithEmail(_email, _password);
    setState(() => _isLoading = false);
  }

  void _signInWithGoogle() async {
    setState(() => _isLoading = true);
    await AuthService().signInWithGoogle();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text("NicSick", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            TextFormField(
              key: const ValueKey('email'),
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              onSaved: (value) => _email = value!.trim(),
              validator: (value) => (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey('password'),
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onSaved: (value) => _password = value!.trim(),
              validator: (value) => (value == null || value.length < 6) ? 'Password too short' : null,
            ),
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading)
              Column(
                children: [
                  ElevatedButton(onPressed: _submit, child: const Text('Sign In')),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: _signInWithGoogle, child: const Text('Google Sign In')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}