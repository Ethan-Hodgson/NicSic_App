import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'health_article_detail.dart';

class HealthInfoScreen extends StatelessWidget {
  const HealthInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health & Education")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HealthArticleCard(
            title: "Why Quit?",
            summary: "The health and life benefits of quitting vaping.",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WhyQuitArticle())),
          ),
          HealthArticleCard(
            title: "Nicotine Withdrawal",
            summary: "What to expect and how to cope when quitting.",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WithdrawalArticle())),
          ),
          HealthArticleCard(
            title: "Coping with Cravings",
            summary: "Tips and tricks for getting through the tough moments.",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CravingsArticle())),
          ),
          HealthArticleCard(
            title: "Building Motivation",
            summary: "Stay inspired and track your quit journey.",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MotivationArticle())),
          ),
          HealthArticleCard(
            title: "Support Resources",
            summary: "Where to find help, hotlines, and more.",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SupportResourcesArticle())),
          ),
          HealthArticleCard(
            title: "Vaping and Young People",
            summary: "How vaping affects teens and young adults.",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => YoungPeopleArticle())),
          ),
          HealthArticleCard(
            title: "Myths vs Facts",
            summary: "Busting common vaping myths.",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MythsFactsArticle())),
          ),
        ],
      ),
    );
  }
}

class HealthArticleCard extends StatelessWidget {
  final String title;
  final String summary;
  final VoidCallback onTap;
  const HealthArticleCard({super.key, required this.title, required this.summary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(summary),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}