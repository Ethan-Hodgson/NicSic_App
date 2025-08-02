import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

// Example skins: id, display, color, cost
final List<Map<String, dynamic>> availableSkins = [
  {
    'id': 'default',
    'label': 'Classic',
    'emoji': '⭕',
    'color': Colors.blue,
    'cost': 0,
  },
  {
    'id': 'pineapple',
    'label': 'Pineapple',
    'emoji': '🍍',
    'color': Colors.yellow[800],
    'cost': 3,
  },
  {
    'id': 'apple',
    'label': 'Apple',
    'emoji': '🍎',
    'color': Colors.red,
    'cost': 3,
  },
  {
    'id': 'grape',
    'label': 'Grape',
    'emoji': '🍇',
    'color': Colors.purple,
    'cost': 4,
  },
  {
    'id': 'watermelon',
    'label': 'Watermelon',
    'emoji': '🍉',
    'color': Colors.green,
    'cost': 4,
  },
  // Add more skins as desired!
];

class _ShopScreenState extends State<ShopScreen> {
  late Future<AppUser?> _userFuture;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _userFuture = user != null
        ? FirestoreService().getUser(user.uid)
        : Future.value(null);
  }

  Future<void> _buySkin(AppUser user, String skinId, int cost) async {
    if (user.tokens < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not enough tokens!")),
      );
      return;
    }
    if (user.ownedSkins.contains(skinId)) return; // Already owned

    // Update Firestore: subtract tokens, add to ownedSkins
    await FirestoreService().updateTokens(user.uid, user.tokens - cost);
    await FirestoreService().addOwnedSkin(user.uid, skinId);
    setState(() {
      _userFuture = FirestoreService().getUser(user.uid);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Skin purchased!")),
    );
  }

  Future<void> _selectSkin(AppUser user, String skinId) async {
    await FirestoreService().setSelectedSkin(user.uid, skinId);
    setState(() {
      _userFuture = FirestoreService().getUser(user.uid);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Skin equipped!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
      ),
      body: FutureBuilder<AppUser?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Tokens:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Text("${user.tokens}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 0),
              Expanded(
                child: ListView.builder(
                  itemCount: availableSkins.length,
                  itemBuilder: (context, i) {
                    final skin = availableSkins[i];
                    final isOwned = user.ownedSkins.contains(skin['id']);
                    final isSelected = user.selectedSkin == skin['id'];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                      elevation: isSelected ? 4 : 1,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: skin['color'],
                          child: Text(
                            skin['emoji'],
                            style: const TextStyle(fontSize: 30),
                          ),
                          radius: 32,
                        ),
                        title: Text(skin['label'], style: const TextStyle(fontSize: 20)),
                        subtitle: isSelected
                            ? const Text("In use", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                            : isOwned
                                ? const Text("Owned", style: TextStyle(color: Colors.blueGrey))
                                : Text("Cost: ${skin['cost']} tokens"),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.green, size: 28)
                            : isOwned
                                ? OutlinedButton(
                                    onPressed: () => _selectSkin(user, skin['id']),
                                    child: const Text("Use"),
                                  )
                                : OutlinedButton(
                                    onPressed: () => _buySkin(user, skin['id'], skin['cost']),
                                    child: const Text("Buy"),
                                  ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}