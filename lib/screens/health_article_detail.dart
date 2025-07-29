import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HealthArticleDetail extends StatelessWidget {
  final String title;
  final List<Widget> body;
  final List<Widget> references;

  const HealthArticleDetail({
    super.key,
    required this.title,
    required this.body,
    required this.references,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...body,
          const SizedBox(height: 24),
          const Divider(),
          const Text(
            "References",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ...references,
        ],
      ),
    );
  }
}

// ------- Article #1: Why Quit -------
class WhyQuitArticle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HealthArticleDetail(
      title: "Why Quit?",
      body: [
        Row(
          children: [
            const Icon(Icons.favorite, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "⭐ 90% of people who quit vaping said they felt less stressed, anxious, or depressed.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.health_and_safety, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Avoid harmful chemicals like formaldehyde and acrolein that can damage your lungs and DNA.",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.spa, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "✨ Better skin: Quitting means healthier, glowing skin as nicotine dries and damages it.",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.yellow[100],
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Did you know? Quitting vaping improves your blood vessels, mood, and helps you heal faster!",
                    style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      references: [
        refLink("Truth Initiative (2025)",
          "https://truthinitiative.org/research-resources/emerging-tobacco-products/e-cigarettes-facts-stats-and-regulations"),
        refLink("Healthline: Benefits of Quitting Vaping",
          "https://www.healthline.com/health/benefits-of-quitting-vaping"),
      ],
    );
  }
}

// ------- Article #2: Nicotine Withdrawal -------
class WithdrawalArticle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HealthArticleDetail(
      title: "Nicotine Withdrawal",
      body: [
        Row(
          children: [
            Icon(Icons.warning, color: Colors.deepOrange[300]),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Withdrawal symptoms can be tough but don’t last forever! They mean your body is recovering. Most physical symptoms fade in 2–4 weeks.",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          "Common symptoms:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("• Feeling down or irritable"),
              Text("• Difficulty concentrating"),
              Text("• Poor sleep"),
              Text("• Increased hunger"),
              Text("• Obsessive thoughts about vaping"),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text(
          "It’s normal to slip-up when you’re trying to quit. Each attempt teaches you more about what works for you!",
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
      references: [
        refLink("NSW Health – Quit Support Factsheet",
          "https://www.health.nsw.gov.au/tobacco/Pages/vaping-quit-support-young-people-factsheet.aspx"),
      ],
    );
  }
}

// ------- Article #3: Coping with Cravings -------
class CravingsArticle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HealthArticleDetail(
      title: "Coping with Cravings",
      body: [
        Row(
          children: [
            Icon(Icons.tips_and_updates, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Cravings get easier with practice! Try these tricks:",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Card(
          color: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("• Avoid triggers in the first two weeks"),
                Text("• Snack instead of vaping to keep hands/mouth busy"),
                Text("• Get active – go for a walk or run"),
                Text("• Ask for support from someone you trust"),
                Text("• Try deep breathing or meditation"),
                Text("• Distract yourself: call a friend, play a game, read, or listen to music"),
              ],
            ),
          ),
        ),
      ],
      references: [
        refLink("NSW Health – Quit Support Factsheet",
          "https://www.health.nsw.gov.au/tobacco/Pages/vaping-quit-support-young-people-factsheet.aspx"),
      ],
    );
  }
}

// ------- Article #4: Building Motivation -------
class MotivationArticle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HealthArticleDetail(
      title: "Building Motivation",
      body: [
        Row(
          children: [
            Icon(Icons.rocket_launch, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Here’s how young people succeed in quitting:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Card(
          color: Colors.purple[50],
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("• Pick a quit date (choose a low-stress time)"),
                Text("• Make a quit plan for cravings & slip-ups"),
                Text("• Get rid of vapes & avoid triggers"),
                Text("• Tell friends or family for support"),
                Text("• Quit with a friend!"),
                Text("• Reach out to professionals if you need more help"),
                Text("• Figure out your biggest triggers and have a plan"),
              ],
            ),
          ),
        ),
      ],
      references: [
        refLink("NSW Health – Quit Support Factsheet",
          "https://www.health.nsw.gov.au/tobacco/Pages/vaping-quit-support-young-people-factsheet.aspx"),
      ],
    );
  }
}

// ------- Article #5: Support Resources (with buttons) -------
class SupportResourcesArticle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HealthArticleDetail(
      title: "Support Resources",
      body: [
        Text("Reach out anytime! Free help is always available:", style: TextStyle(fontSize: 16)),
        SizedBox(height: 20),
        // NZ Quitline
        Row(
          children: [
            Icon(Icons.phone, color: Colors.teal),
            SizedBox(width: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.call),
              label: Text("Call Quitline NZ"),
              onPressed: () => launchUrl(Uri.parse("tel:0800778778")),
            ),
          ],
        ),
        SizedBox(height: 12),
        // US Smokefree
        Row(
          children: [
            Icon(Icons.phone, color: Colors.blue),
            SizedBox(width: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.call),
              label: Text("Call Smokefree US"),
              onPressed: () => launchUrl(Uri.parse("tel:18007848669")),
            ),
          ],
        ),
        SizedBox(height: 12),
        // NZ Website
        Row(
          children: [
            Icon(Icons.public, color: Colors.purple),
            SizedBox(width: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.open_in_browser),
              label: Text("Visit Smokefree NZ"),
              onPressed: () => launchUrl(Uri.parse("https://www.smokefree.org.nz/quit/help-and-support/get-a-free-quit-coach")),
            ),
          ],
        ),
      ],
      references: [
        refLink("NZ Quitline", "https://www.quit.org.nz/"),
        refLink("Smokefree NZ", "https://www.smokefree.org.nz/"),
        refLink("Smokefree US", "https://smokefree.gov/"),
      ],
    );
  }
}

// ------- Article #6: Vaping and Young People -------
class YoungPeopleArticle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HealthArticleDetail(
      title: "Vaping and Young People",
      body: [
        Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.pink),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Nicotine can harm brain development in teens. Many who vape face more anxiety, mood swings, and trouble sleeping.",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Card(
          color: Colors.pink[50],
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("• Teens are at greater risk of anxiety and mood disorders"),
                Text("• Chronic vaping can damage the small airways in your lungs"),
                Text("• We’re still learning the full long-term effects!"),
              ],
            ),
          ),
        ),
      ],
      references: [
        refLink("NSW Health – Quit Support Factsheet",
          "https://www.health.nsw.gov.au/tobacco/Pages/vaping-quit-support-young-people-factsheet.aspx"),
      ],
    );
  }
}

// ------- Article #7: Myths vs Facts (you can expand this) -------
class MythsFactsArticle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HealthArticleDetail(
      title: "Myths vs Facts",
      body: [
        Row(
          children: [
            Icon(Icons.fact_check, color: Colors.deepPurple),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Don’t fall for common vaping myths! Know the facts.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Card(
          color: Colors.deepPurple[50],
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Myth: Vaping is harmless."),
                Text("Fact: Vaping can still cause lung and DNA damage!"),
                SizedBox(height: 10),
                Text("Myth: It’s not addictive."),
                Text("Fact: Nicotine in vapes is highly addictive."),
                SizedBox(height: 10),
                Text("Myth: All vapes are regulated."),
                Text("Fact: Many black-market vapes have unknown chemicals."),
              ],
            ),
          ),
        ),
      ],
      references: [
        refLink("Truth Initiative – Vaping Facts", "https://truthinitiative.org/research-resources/emerging-tobacco-products/e-cigarettes-facts-stats-and-regulations"),
      ],
    );
  }
}

// ---- Helper for reference links ----
Widget refLink(String label, String url) => InkWell(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
        child: Text(label,
            style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontSize: 15)),
      ),
      onTap: () => launchUrl(Uri.parse(url)),
    );