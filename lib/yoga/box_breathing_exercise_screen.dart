// File: lib/box_breathing_exercise_screen.dart

import 'package:flutter/material.dart';
import 'dart:async'; // For Timer

class BoxBreathingExerciseScreen extends StatefulWidget {
  const BoxBreathingExerciseScreen({super.key});

  @override
  State<BoxBreathingExerciseScreen> createState() => _BoxBreathingExerciseScreenState();
}

// Enum to manage the state of the breathing animation
enum BreathingPhase {
  inhale,
  holdAfterInhale,
  exhale,
  holdAfterExhale,
  initial, // For the very beginning before any cycle starts
}

class _BoxBreathingExerciseScreenState extends State<BoxBreathingExerciseScreen> {
  // Animation properties
  BreathingPhase _currentPhase = BreathingPhase.initial;
  double _circleDiameter = 200.0; // Initial size of the inner circle
  final double _minCircleDiameter = 200.0; // Smallest size for exhale/hold
  final double _maxCircleDiameter = 250.0; // Largest size for inhale
  String _displayText = "Start Breathing";

  // Durations for each phase (Box Breathing: 4-4-4-4)
  final Duration _inhaleDuration = const Duration(seconds: 4);
  final Duration _holdDuration = const Duration(seconds: 4); // Hold duration for both holds
  final Duration _exhaleDuration = const Duration(seconds: 4);

  // Counter properties
  int _currentBreathCount = 0;
  final int _totalBreaths = 5; // Target breaths for the session (reduced for quicker testing)

  // Session control
  Timer? _breathingTimer;
  bool _isSessionComplete = false;
  bool _isBreathingActive = false; // To control starting/pausing the animation

  // Descriptions and Uses
  final String _description =
      "Box breathing involves inhaling, holding, exhaling, and holding for equal counts, typically four seconds each. It's a simple yet powerful technique.";
  final String _uses =
      "Calms the nervous system, reduces stress, improves focus and concentration, often used by athletes and in high-stress professions to maintain composure.";


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
      _displayText = "Get Ready"; // Initial message before first inhale
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

    // Hold After Inhale Phase (4 seconds)
    setState(() {
      _currentPhase = BreathingPhase.holdAfterInhale;
      _displayText = "Hold 4";
      // Circle remains at max diameter during this hold
    });
    await Future.delayed(_holdDuration);
    if (!_isBreathingActive || _isSessionComplete || !mounted) return;

    // Exhale Phase (4 seconds)
    setState(() {
      _currentPhase = BreathingPhase.exhale;
      _displayText = "Exhale 4";
      _circleDiameter = _minCircleDiameter;
    });
    await Future.delayed(_exhaleDuration);
    if (!_isBreathingActive || _isSessionComplete || !mounted) return;

    // Hold After Exhale Phase (4 seconds)
    setState(() {
      _currentPhase = BreathingPhase.holdAfterExhale;
      _displayText = "Hold 4";
      // Circle remains at min diameter during this hold
    });
    await Future.delayed(_holdDuration);
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
        _displayText = "Session Ended"; // Custom message if ended early
      } else {
        _displayText = "Complete!"; // Message if all breaths are done
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
          'Box Breathing', // Specific title
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24, // Adjusted font size for title
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
                  'Inhale, Hold, Exhale, Hold. Repeat.', // Specific instruction
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20, // Adjusted font size
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
                      duration: (_currentPhase == BreathingPhase.inhale || _currentPhase == BreathingPhase.exhale)
                          ? (_currentPhase == BreathingPhase.inhale ? _inhaleDuration : _exhaleDuration)
                          : _holdDuration, // Use hold duration for hold phases
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
