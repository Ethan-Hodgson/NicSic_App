import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

const Map<String, Map<String, dynamic>> kSkinPresets = {
  'classic_green':   { 'color': Colors.green,  'emoji': null },
  'red_apple':       { 'color': Colors.red,    'emoji': '🍎' },
  'pineapple':       { 'color': Colors.yellow, 'emoji': '🍍' },
  'blueberry':       { 'color': Colors.blue,   'emoji': '🫐' },
  'orange_orange':   { 'color': Colors.orange, 'emoji': '🍊' },
  'grapefruit':      { 'color': Colors.pink,   'emoji': '🍊' },
};

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

enum EventType { tap, hold }

class _Event {
  final EventType type;
  final Color color;
  final double duration;
  _Event({required this.type, required this.color, required this.duration});
}

class _GameScreenState extends State<GameScreen> {
  static const int gameDuration = 30;
  static const double tapMin = 0.7, tapMax = 1.0;
  static const double holdMin = 2.0, holdMax = 2.5;
  static const double minCircle = 110.0;

  final Random _random = Random();

  late List<_Event> _events;
  int _currentEvent = 0;
  double _circleScale = 1.0;
  int _displayScore = 0;
  int _countdown = gameDuration;
  int _tapMultiplier = 1;
  Timer? _gameTimer;
  Timer? _eventTimer;
  String _feedback = "";
  bool _gameEnded = false;
  double _elapsed = 0;

  // Hold Event State
  bool _isHoldEvent = false;
  bool _isHolding = false;
  bool _holdSuccess = false;
  DateTime? _holdStart;
  double _holdRequired = 1.0;
  double _holdEventEndTime = 0.0;

  // Skin
  String _skinId = 'classic_green';
  Color _skinColor = Colors.green;
  String? _skinEmoji;

  final AudioPlayer _audioPlayer = AudioPlayer();

  // NEW: prevent initial “flash” until we’ve loaded skin/events
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _loadSkinAndStart();
  }

  Future<void> _loadSkinAndStart() async {
    final user = FirebaseAuth.instance.currentUser;
    String skinId = 'classic_green';
    if (user != null) {
      final skinData = await FirestoreService().getUserSkins(user.uid);
      skinId = skinData['selectedSkin'] ?? 'classic_green';
    }
    final skinInfo = kSkinPresets[skinId] ?? kSkinPresets['classic_green']!;
    _skinId = skinId;
    _skinColor = skinInfo['color'];
    _skinEmoji = skinInfo['emoji'];

    _events = _generateEventsToFillTime();
    _startGame();

    setState(() {
      _initializing = false;
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _eventTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  List<_Event> _generateEventsToFillTime() {
    final events = <_Event>[];
    double totalTime = 0;
    while (totalTime < gameDuration) {
      final greens = _random.nextInt(3) + 2;
      final yellows = _random.nextInt(2) + 2;
      final reds = _random.nextInt(2) + 1;

      for (int i = 0; i < greens; i++) {
        final dur = _randTapDur();
        if (totalTime + dur > gameDuration) break;
        events.add(_Event(type: EventType.tap, color: _skinColor, duration: dur));
        totalTime += dur;
      }
      for (int i = 0; i < yellows; i++) {
        final dur = _randTapDur();
        if (totalTime + dur > gameDuration) break;
        events.add(_Event(type: EventType.tap, color: Colors.yellow, duration: dur));
        totalTime += dur;
      }
      for (int i = 0; i < reds; i++) {
        final dur = _randTapDur();
        if (totalTime + dur > gameDuration) break;
        events.add(_Event(type: EventType.tap, color: Colors.red, duration: dur));
        totalTime += dur;
      }

      final holdDur = _randHoldDur();
      if (totalTime + holdDur < gameDuration) {
        events.add(_Event(type: EventType.hold, color: Colors.orange, duration: holdDur));
        totalTime += holdDur;
      } else if (totalTime < gameDuration) {
        final leftover = gameDuration - totalTime;
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
      _circleScale = 1.0;
      _tapMultiplier = 1;
      _feedback = "";
      _gameEnded = false;
      _currentEvent = 0;
      _displayScore = 0;
      _countdown = gameDuration;
      _elapsed = 0;
      _isHoldEvent = false;
      _holdEventEndTime = 0.0;
      _holdSuccess = false;
      _isHolding = false;
      _holdStart = null;
    });

    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _elapsed += 0.1;
        final newCountdown = gameDuration - _elapsed.floor();
        if (newCountdown != _countdown) _countdown = newCountdown;
        if (_elapsed >= gameDuration) _endGame();
      });
    });

    _startEvent();
  }

  void _startEvent() {
    if (_gameEnded) return;

    if (_currentEvent >= _events.length) {
      // No more scripted events; allow tapping until time ends.
      setState(() {
        _isHoldEvent = false;
        _holdEventEndTime = 0.0;
        _holdSuccess = false;
        _isHolding = false;
        _holdStart = null;
      });
      return;
    }

    _feedback = "";
    _isHolding = false;
    _holdStart = null;
    _holdSuccess = false;

    final event = _events[_currentEvent];
    _audioPlayer.stop();

    if (event.type == EventType.hold) {
      _isHoldEvent = true;
      _holdRequired = event.duration * 0.5;        // 50% requirement
      _holdEventEndTime = _elapsed + event.duration;
    } else {
      _isHoldEvent = false;
      _holdEventEndTime = 0.0;
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

      if (event.type == EventType.tap) {
        setState(() => _feedback = "Missed!");
        _shrinkCircle();
        Future.delayed(const Duration(milliseconds: 100), _nextEvent);
      } else if (event.type == EventType.hold && !_holdSuccess) {
        // Window ended — if still holding and long enough, award; else miss.
        bool successNow = false;
        if (_isHolding && _holdStart != null) {
          final heldFor = DateTime.now().difference(_holdStart!).inMilliseconds / 1000.0;
          if (heldFor >= _holdRequired) successNow = true;
        }
        _audioPlayer.stop();

        if (successNow) {
          _awardHoldSuccess();
        } else {
          setState(() => _feedback = "Missed Hold!");
          _shrinkCircle();
          _isHolding = false;
          _holdStart = null;
          Future.delayed(const Duration(milliseconds: 200), _nextEvent);
        }
      }
    });
  }

  void _nextEvent() {
    _eventTimer?.cancel();
    _audioPlayer.stop();
    setState(() {
      _currentEvent++;
      _feedback = "";
      _isHolding = false;
      _holdStart = null;
      _holdSuccess = false;
    });
    if (!_gameEnded && _elapsed < gameDuration) {
      _startEvent();
    }
  }

  void _growCircle() {
    setState(() {
      _circleScale *= 1.18;        // growth rate you liked
      _displayScore += _tapMultiplier;
    });
  }

  void _shrinkCircle() {
    setState(() {
      _circleScale *= 0.7;
      if (_circleScale < 1.0) _circleScale = 1.0;
      _tapMultiplier = (_tapMultiplier ~/ 2).clamp(1, 999);
      if (_displayScore > 2) _displayScore -= 2;
    });
  }

  void _awardHoldSuccess() {
    if (_holdSuccess) return;
    setState(() {
      _tapMultiplier *= 2;
      _feedback = "Great Hold! Tap = x$_tapMultiplier!";
      _holdSuccess = true;
    });
    _growCircle();
    Future.delayed(const Duration(milliseconds: 250), _nextEvent);
  }

  // ---------- Gestures ----------
  void _onTapDown(TapDownDetails details) async {
    if (_gameEnded || _elapsed >= gameDuration) return;

    final bool moreEvents = _currentEvent < _events.length;
    final _Event? event = moreEvents ? _events[_currentEvent] : null;

    // Ignore taps during a hold event.
    final bool isHoldPhase = moreEvents && event != null && event.type == EventType.hold;
    if (isHoldPhase) return;

    setState(() {
      _feedback = "Nice! +$_tapMultiplier";
    });
    _growCircle();

    if (moreEvents && event != null && event.type == EventType.tap) {
      _eventTimer?.cancel();
      Future.delayed(const Duration(milliseconds: 80), _nextEvent);
    }

    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sfx/tap.mp3'), volume: 0.8);
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (_gameEnded || !_isHoldEvent || _holdSuccess || _elapsed >= _holdEventEndTime) return;
    _isHolding = true;
    _holdStart = DateTime.now();
    setState(() => _feedback = "Keep holding!");
    _audioPlayer.stop();
    _audioPlayer.play(AssetSource('sfx/hold.mp3'), volume: 0.8);
  }

  void _onLongPressEnd(LongPressEndDetails details) async {
    if (_gameEnded || !_isHoldEvent || _holdSuccess || !_isHolding || _holdStart == null) return;

    await _audioPlayer.stop();

    final heldFor = DateTime.now().difference(_holdStart!).inMilliseconds / 1000.0;
    if (_elapsed < _holdEventEndTime && heldFor >= _holdRequired) {
      _awardHoldSuccess();
    } else {
      setState(() => _feedback = "Too Quick! Try again!");
      // user can retry until the window expires
    }

    _isHolding = false;
    _holdStart = null;
  }

  void _endGame() {
    _gameTimer?.cancel();
    _eventTimer?.cancel();
    _audioPlayer.stop();
    setState(() {
      _gameEnded = true;
      _countdown = 0;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Game Over!"),
          content: Text("Your Score: $_displayScore\n\nWant to try again?"),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final gameActive = !_gameEnded && _elapsed < gameDuration;
    final bool moreEvents = _currentEvent < _events.length;
    final _Event? event = moreEvents ? _events[_currentEvent] : null;
    final bool isHold = gameActive && ((event != null && event.type == EventType.hold) || (!moreEvents && _isHoldEvent));

    // Color logic (3 taps before hold = orange, hold = red)
    Color circleColor = _skinColor;
    if (gameActive && (event != null || !moreEvents)) {
      if (isHold) {
        circleColor = Colors.red;
      } else {
        int tapsToHold = 0;
        for (int i = _currentEvent + 1; i < _events.length; i++) {
          if (_events[i].type == EventType.hold) break;
          tapsToHold++;
        }
        if (tapsToHold < 3 && _events.skip(_currentEvent).any((e) => e.type == EventType.hold)) {
          circleColor = Colors.orange;
        }
      }
    }

    final screenSize = MediaQuery.of(context).size;
    final circleSize = max(_circleScale * 40.0, minCircle);

    final actionPrompt = gameActive ? (isHold ? "Hold!" : "Tap!") : (_gameEnded ? "Game Over" : "");
    final skinEmoji = _skinEmoji;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Circle behind everything
            Positioned(
              left: (screenSize.width - circleSize) / 2,
              top: (screenSize.height - circleSize) / 2,
              width: circleSize,
              height: circleSize,
              child: Container(
                decoration: BoxDecoration(
                  color: circleColor.withOpacity(0.90),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Emoji (single render; fixed size; centered)
            Center(
              child: SizedBox(
                width: minCircle,
                height: minCircle,
                child: Center(
                  child: skinEmoji != null
                      ? Text(skinEmoji, style: const TextStyle(fontSize: 80))
                      : const Icon(Icons.circle, size: 64, color: Colors.white),
                ),
              ),
            ),

            // Gesture layer (taps/holds)
            IgnorePointer(
              ignoring: _gameEnded,
              child: GestureDetector(
                onTapDown: (moreEvents && event != null && event.type == EventType.hold) ? null : _onTapDown,
                onLongPressStart: isHold ? _onLongPressStart : null,
                onLongPressEnd: isHold ? _onLongPressEnd : null,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),

            // Top info (always visible)
            Positioned(
              top: 18,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Time Left: $_countdown",
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 4),
                  Text("Score: $_displayScore", style: const TextStyle(fontSize: 20, color: Colors.black)),
                  const SizedBox(height: 2),
                  Text("Tap Bonus: x$_tapMultiplier",
                      style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      actionPrompt,
                      key: ValueKey(actionPrompt),
                      style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom feedback
            if (_feedback.isNotEmpty && !_gameEnded)
              Positioned(
                bottom: 54,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    _feedback,
                    style: const TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold),
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