// File: lib/four_seven_eight_breathing_exercise_screen.dart

import 'package:flutter/material.dart';
import 'dart:async'; // For Timer

class FourSevenEightBreathingExerciseScreen extends StatefulWidget {
  const FourSevenEightBreathingExerciseScreen({super.key});

  @override
  State<FourSevenEightBreathingExerciseScreen> createState() => _FourSevenEightBreathingExerciseScreenState();
}

// Enum to manage the state of the breathing animation
enum BreathingPhase {
  inhale,
  hold,
  exhale,
  initial, // For the very beginning before any cycle starts
}

class _FourSevenEightBreathingExerciseScreenState extends State<FourSevenEightBreathingExerciseScreen> {
  // Animation properties
  BreathingPhase _currentPhase = BreathingPhase.initial;
  double _circleDiameter = 200.0; // Initial size of the inner circle
  final double _minCircleDiameter = 200.0; // Smallest size for exhale
  final double _maxCircleDiameter = 250.0; // Largest size for inhale
  String _displayText = "Start Breathing";

  // Durations for each phase (4-7-8 Breathing)
  final Duration _inhaleDuration = const Duration(seconds: 4);
  final Duration _holdDuration = const Duration(seconds: 7);
  final Duration _exhaleDuration = const Duration(seconds: 8);

  // Counter properties
  int _currentBreathCount = 0;
  final int _totalBreaths = 4; // Target breaths for the session (4-7-8 is usually done for fewer reps)

  // Session control
  Timer? _breathingTimer;
  bool _isSessionComplete = false;
  bool _isBreathingActive = false; // To control starting/pausing the animation

  // Descriptions and Uses
  final String _description =
      "The 4-7-8 breathing technique is a relaxing breath exercise. It involves inhaling for 4 counts, holding for 7 counts, and exhaling for 8 counts.";
  final String _uses =
      "It promotes relaxation, helps with falling asleep, manages anxiety and stress, and can be used to quickly calm the body.";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBreathingSession();
    });
  }

  @override
  void dispose() {
    _breathingTimer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  void _startBreathingSession() {
    if (_isBreathingActive && !_isSessionComplete) return;

    setState(() {
      _isBreathingActive = true;
      _isSessionComplete = false;
      _currentBreathCount = 0; // Reset for a new session
      _currentPhase = BreathingPhase.initial; // Reset phase
      _displayText = "Get Ready"; // Initial message
      _circleDiameter = _minCircleDiameter; // Start at min size
    });
    // Add a small delay before the first inhale starts to show "Get Ready"
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _runBreathingCycle();
      }
    });
  }

  void _runBreathingCycle() async {
    if (!_isBreathingActive || _isSessionComplete || !mounted) {
      return; // Stop if session is complete, paused, or widget is disposed
    }

    // Inhale Phase (4 seconds)
    setState(() {
      _currentPhase = BreathingPhase.inhale;
      _displayText = "Inhale 4";
      _circleDiameter = _maxCircleDiameter;
    });
    await Future.delayed(_inhaleDuration);
    if (!_isBreathingActive || _isSessionComplete || !mounted) return;

    // Hold Phase (7 seconds)
    setState(() {
      _currentPhase = BreathingPhase.hold;
      _displayText = "Hold 7";
      // Circle remains at max diameter during this hold
    });
    await Future.delayed(_holdDuration);
    if (!_isBreathingActive || _isSessionComplete || !mounted) return;

    // Exhale Phase (8 seconds)
    setState(() {
      _currentPhase = BreathingPhase.exhale;
      _displayText = "Exhale 8";
      _circleDiameter = _minCircleDiameter;
    });
    await Future.delayed(_exhaleDuration);
    if (!_isBreathingActive || _isSessionComplete || !mounted) return;

    // End of one breath cycle
    setState(() {
      _currentBreathCount++;
    });

    if (_currentBreathCount >= _totalBreaths) {
      // Session complete
      _endSession(complete: true);
    } else {
      // Continue to the next cycle
      _runBreathingCycle();
    }
  }

  void _endSession({bool complete = false}) {
    _breathingTimer?.cancel(); // Ensure timer is stopped
    setState(() {
      _isBreathingActive = false;
      _isSessionComplete = true;
      if (!complete) {
        _displayText = "Session Ended";
      } else {
        _displayText = "Complete!";
      }
    });
  }

  void _resetAndStartNewRound() {
    _startBreathingSession(); // Simply restart the session
  }

  void _goBack() {
    Navigator.pop(context); // Navigate back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          '4-7-8 Breathing', // Specific title
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF91EEA5), // Light green App bar
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: _goBack,
        ),
      ),
      body: SingleChildScrollView( // Made the body scrollable
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  'Inhale 4, Hold 7, Exhale 8.', // Specific instruction
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),

                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: _maxCircleDiameter,
                      height: _maxCircleDiameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.tealAccent.withOpacity(0.7),
                            blurRadius: 15,
                            spreadRadius: 3,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: (_currentPhase == BreathingPhase.inhale)
                          ? _inhaleDuration
                          : (_currentPhase == BreathingPhase.exhale ? _exhaleDuration : _holdDuration),
                      curve: Curves.easeInOut,
                      width: _circleDiameter,
                      height: _circleDiameter,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFF4DB6AC), // Inner light teal
                            Color(0xFF339989), // Mid teal
                            Color(0xFF206A5D), // Outer dark teal
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _displayText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Breath Counter
                Text(
                  '$_currentBreathCount/$_totalBreaths',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 50),
                // Session Control Buttons
                if (!_isSessionComplete)
                  ElevatedButton(
                    onPressed: _endSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'End Session',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _resetAndStartNewRound,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF91EEA5), // Light green
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Another Round',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _goBack,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400], // Grey
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Go back',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 30), // Added spacing before description section

                // Description
                Text(
                  _description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 10),

                // Uses
                Text(
                  'Uses: $_uses',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20), // Added spacing at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
