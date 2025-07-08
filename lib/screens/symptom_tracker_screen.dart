import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart'; // Make sure this import is correct for handleStreakRewards!
import 'home_screen.dart';

class SymptomTrackerScreen extends StatefulWidget {
  const SymptomTrackerScreen({super.key});

  @override
  State<SymptomTrackerScreen> createState() => _SymptomTrackerScreenState();
}

class _SymptomTrackerScreenState extends State<SymptomTrackerScreen> {
  final _dateController = TextEditingController();
  final _otherController = TextEditingController();
  final List<String> _symptoms = [
    "Headache",
    "Cough",
    "Fever",
    "Fatigue",
    "Sore throat",
    "Nausea",
    "Irritated"
  ];

  final Map<String, bool> _selectedSymptoms = {};

  @override
  void initState() {
    super.initState();
    for (var symptom in _symptoms) {
      _selectedSymptoms[symptom] = false;
    }
    // Default date to today
    final now = DateTime.now();
    _dateController.text =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _dateController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _saveSymptoms() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final selected = _selectedSymptoms.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Parse the date the user picked or default to today
    DateTime trackedDate;
    try {
      trackedDate = DateTime.parse(_dateController.text);
    } catch (_) {
      trackedDate = DateTime.now();
    }
    final today = DateTime(trackedDate.year, trackedDate.month, trackedDate.day);

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final userDoc = await userDocRef.get();

    DateTime? lastTracked;
    int currentStreak = 0;

    if (userDoc.exists) {
      final data = userDoc.data()!;
      if (data['lastTracked'] != null) {
        lastTracked = (data['lastTracked'] as Timestamp).toDate();
        lastTracked = DateTime(lastTracked.year, lastTracked.month, lastTracked.day);
      }
      currentStreak = data['currentStreak'] ?? 0;
    }

    // Calculate new streak
    int newStreak = 1;
    if (lastTracked != null) {
      final daysDifference = today.difference(lastTracked).inDays;
      if (daysDifference == 0) {
        // Already tracked today
        newStreak = currentStreak;
      } else if (daysDifference == 1) {
        // Tracked yesterday, streak up
        newStreak = currentStreak + 1;
      } else {
        // Missed a day, streak resets
        newStreak = 1;
      }
    }

    try {
      // Save symptom log
      await userDocRef.collection('symptomLogs').add({
        'date': _dateController.text,
        'symptoms': selected,
        'other': _otherController.text.trim(),
        'timestamp': Timestamp.now(),
      });

      // Update the lastTracked and currentStreak in the user document
      await userDocRef.update({
        'lastTracked': Timestamp.fromDate(today),
        'currentStreak': newStreak,
      });

      // Reward logic for streaks/badges/tokens
      await FirestoreService().handleStreakRewards(user, newStreak);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Well done for tracking your symptoms today. Keep up the hard work!"),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred: $e"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
        title: const Text("Symptom Tracker"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date input
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 24),

            const Text(
              "Select symptoms",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Symptom checkboxes
            ..._symptoms.map((symptom) => CheckboxListTile(
                  title: Text(symptom),
                  value: _selectedSymptoms[symptom],
                  onChanged: (val) {
                    setState(() {
                      _selectedSymptoms[symptom] = val!;
                    });
                  },
                )),

            // "Other" symptom input
            const SizedBox(height: 16),
            TextField(
              controller: _otherController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Other",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: _saveSymptoms,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Save", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}