import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

enum EventType { tap, hold }

class _Event {
  final EventType type;
  final Color color;
  final double duration; // seconds
  _Event({required this.type, required this.color, required this.duration});
}

// Map skinId to { color: ..., emoji: ... }
const Map<String, Map<String, dynamic>> kSkinPresets = {
  'classic_green':   { 'color': Colors.green,  'emoji': null },
  'red_apple':       { 'color': Colors.red,    'emoji': '🍎' },
  'pineapple':       { 'color': Colors.yellow, 'emoji': '🍍' },
  'blueberry':       { 'color': Colors.blue,   'emoji': '🫐' },
  'orange_orange':   { 'color': Colors.orange, 'emoji': '🍊' },
  'grapefruit':      { 'color': Colors.pink,   'emoji': '🍊' },
  // Add more skins as you wish!
};

class _GameScreenState extends State<GameScreen> {
  static const int gameDuration = 30; // seconds
  static const double tapMin = 0.7, tapMax = 1.0;
  static const double holdMin = 1.3, holdMax = 1.7;
  final Random _random = Random();

  late List<_Event> _events;
  int _currentEvent = 0;
  int _score = 0;
  int _countdown = gameDuration;
  int _tapMultiplier = 1;
  Timer? _gameTimer;
  Timer? _eventTimer;
  String _feedback = "";
  bool _gameEnded = false;

  // Hold state
  bool _isHolding = false;
  DateTime? _holdStart;
  bool _holdAwarded = false;
  double _holdWindowEnd = 0; // absolute time in seconds since start
  double _elapsed = 0; // seconds since game started

  // Skin stuff
  String _skinId = 'classic_green';
  Color _skinColor = Colors.green;
  String? _skinEmoji;

  @override
  void initState() {
    super.initState();
    _loadSkinAndStart();
  }

  Future<void> _loadSkinAndStart() async {
    // Get current user UID
    final user = FirebaseAuth.instance.currentUser;
    String skinId = 'classic_green';
    if (user != null) {
      final skinData = await FirestoreService().getUserSkins(user.uid);
      skinId = skinData['selectedSkin'] ?? 'classic_green';
    }
    final skinInfo = kSkinPresets[skinId] ?? kSkinPresets['classic_green']!;
    setState(() {
      _skinId = skinId;
      _skinColor = skinInfo['color'];
      _skinEmoji = skinInfo['emoji'];
    });
    _events = _generateEventsToFillTime();
    _startGame();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _eventTimer?.cancel();
    super.dispose();
  }

  List<_Event> _generateEventsToFillTime() {
    List<_Event> events = [];
    double totalTime = 0;
    while (totalTime < gameDuration) {
      int greens = _random.nextInt(3) + 2; // 2-4 greens
      int yellows = _random.nextInt(2) + 2; // 2-3 yellows
      int reds = _random.nextInt(2) + 1; // 1-2 reds

      for (int i = 0; i < greens; i++) {
        double dur = _randTapDur();
        if (totalTime + dur > gameDuration) break;
        events.add(_Event(type: EventType.tap, color: _skinColor, duration: dur));
        totalTime += dur;
      }
      for (int i = 0; i < yellows; i++) {
        double dur = _randTapDur();
        if (totalTime + dur > gameDuration) break;
        events.add(_Event(type: EventType.tap, color: Colors.yellow, duration: dur));
        totalTime += dur;
      }
      for (int i = 0; i < reds; i++) {
        double dur = _randTapDur();
        if (totalTime + dur > gameDuration) break;
        events.add(_Event(type: EventType.tap, color: Colors.red, duration: dur));
        totalTime += dur;
      }
      double holdDur = _randHoldDur();
      if (totalTime + holdDur < gameDuration) {
        events.add(_Event(type: EventType.hold, color: Colors.orange, duration: holdDur));
        totalTime += holdDur;
      } else if (totalTime < gameDuration) {
        double leftover = gameDuration - totalTime;
        if (leftover > 0.3) {
          events.add(_Event(type: EventType.hold, color: Colors.orange, duration: leftover));
          totalTime += leftover;
        }
        break;
      }
    }
    return events;
  }

  double _randTapDur() => _random.nextDouble() * (tapMax - tapMin) + tapMin;
  double _randHoldDur() => _random.nextDouble() * (holdMax - holdMin) + holdMin;

  void _startGame() {
    setState(() {
      _score = 0;
      _tapMultiplier = 1;
      _feedback = "";
      _gameEnded = false;
      _currentEvent = 0;
      _countdown = gameDuration;
      _elapsed = 0;
    });

    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _elapsed += 0.1;
        int newCountdown = gameDuration - _elapsed.floor();
        if (newCountdown != _countdown) {
          _countdown = newCountdown;
        }
        if (_elapsed >= gameDuration) {
          _endGame();
        }
      });
    });

    _startEvent();
  }

  void _startEvent() {
    if (_gameEnded) return;
    // If there are no more pre-gen events, just keep showing tap!
    if (_currentEvent >= _events.length) {
      _feedback = "";
      setState(() {});
      return;
    }

    _feedback = "";
    _isHolding = false;
    _holdAwarded = false;
    _holdStart = null;

    _Event event = _events[_currentEvent];
    if (event.type == EventType.hold) {
      _holdWindowEnd = _elapsed + event.duration;
    }

    setState(() {});

    _eventTimer?.cancel();
    _eventTimer = Timer(Duration(milliseconds: (event.duration * 1000).round()), () {
      if (_gameEnded) return;
      if (_elapsed >= gameDuration) {
        _endGame();
        return;
      }
      if (_currentEvent >= _events.length) return;
      final event = _events[_currentEvent];
      if (event.type == EventType.tap) {
        setState(() {
          _feedback = "Missed!";
        });
        Future.delayed(const Duration(milliseconds: 100), _nextEvent);
      } else if (event.type == EventType.hold && !_holdAwarded) {
        setState(() {
          _feedback = "Missed Hold!";
        });
        // Allow retry, keep showing hold
        Future.delayed(const Duration(milliseconds: 100), () {
          setState(() {
            _feedback = "Hold!";
          });
        });
      }
    });
  }

  void _nextEvent() {
    _eventTimer?.cancel();
    setState(() {
      _currentEvent++;
      _feedback = "";
    });
    if (!_gameEnded && _elapsed < gameDuration) {
      _startEvent();
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (_gameEnded) return;
    final bool moreEvents = _currentEvent < _events.length;
    final _Event? event = moreEvents ? _events[_currentEvent] : null;

    if (!moreEvents || (event != null && event.type == EventType.tap)) {
      setState(() {
        _score += _tapMultiplier;
        _feedback = "Nice! +$_tapMultiplier";
      });
      if (moreEvents) {
        _eventTimer?.cancel();
        Future.delayed(const Duration(milliseconds: 80), _nextEvent);
      }
    } else if (event != null && event.type == EventType.hold) {
      _isHolding = true;
      _holdStart ??= DateTime.now();
      setState(() {
        _feedback = "Keep holding!";
      });
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_gameEnded) return;
    final bool moreEvents = _currentEvent < _events.length;
    final _Event? event = moreEvents ? _events[_currentEvent] : null;

    if (event != null &&
        event.type == EventType.hold &&
        _isHolding &&
        _holdStart != null &&
        !_holdAwarded) {
      double heldFor = DateTime.now().difference(_holdStart!).inMilliseconds / 1000.0;
      double eventDur = event.duration;
      // Award if held for 50% of event window
      if (heldFor >= 0.5 * eventDur) {
        setState(() {
          _tapMultiplier = _tapMultiplier * 2;
          _feedback = "Great Hold! Tap = x$_tapMultiplier!";
          _holdAwarded = true;
        });
        _eventTimer?.cancel();
        Future.delayed(const Duration(milliseconds: 120), _nextEvent);
      } else {
        setState(() {
          _feedback = "Too Quick! Try again!";
        });
        // User can keep holding
      }
      _isHolding = false;
      _holdStart = null;
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _eventTimer?.cancel();
    setState(() {
      _gameEnded = true;
      _countdown = 0;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text("Game Over!"),
            content: Text("Your Score: $_score\n\nWant to try again?"),
            actions: [
              TextButton(
                child: const Text("Exit"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Play Again"),
                onPressed: () {
                  Navigator.pop(context);
                  _loadSkinAndStart();
                },
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool gameActive = !_gameEnded && _elapsed < gameDuration;
    final bool moreEvents = _currentEvent < _events.length;
    final _Event? event = moreEvents ? _events[_currentEvent] : null;
    final bool isHold = gameActive && event != null && event.type == EventType.hold;

    Color circleColor;
    String circleText;
    String? skinEmoji = _skinEmoji;

    if (gameActive) {
      if (isHold) {
        circleColor = Colors.orange;
        circleText = skinEmoji ?? "Hold!";
      } else if (event != null) {
        circleColor = event.color;
        circleText = skinEmoji ?? "Tap!";
      } else {
        circleColor = _skinColor;
        circleText = skinEmoji ?? "Tap!";
      }
    } else {
      circleColor = Colors.grey[400]!;
      circleText = "Game Over";
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Time Left: $_countdown",
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Score: $_score",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Tap Bonus: x$_tapMultiplier",
                      style: const TextStyle(fontSize: 16, color: Colors.deepPurple, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      circleText,
                      style: TextStyle(fontSize: skinEmoji != null ? 70 : 40, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            if (_feedback.isNotEmpty && !_gameEnded)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 250),
                  child: Text(
                    _feedback,
                    style: TextStyle(
                        color: _feedback.contains("Nice") || _feedback.contains("Great") ? Colors.green : Colors.red,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (_gameEnded)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}