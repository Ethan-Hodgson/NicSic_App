import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SymptomHistoryScreen extends StatelessWidget {
  const SymptomHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Symptom History")),
        body: const Center(child: Text("Not signed in.")),
      );
    }

    final logsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('symptomLogs')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text("Symptom History")),
      body: StreamBuilder<QuerySnapshot>(
        stream: logsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No symptom history yet."));
          }

          final logs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, idx) {
              final log = logs[idx].data() as Map<String, dynamic>;
              final date = log['date'] ?? '';
              final symptoms = (log['symptoms'] as List?)?.join(", ") ?? "";
              final other = log['other'] ?? "";

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text("Symptoms: $symptoms", style: const TextStyle(fontSize: 16)),
                      if (other.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text("Other notes: $other", style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}