// File: lib/diaphragmatic_breathing_exercise_screen.dart

import 'package:flutter/material.dart';
import 'dart:async'; // For Timer

class DiaphragmaticBreathingExerciseScreen extends StatefulWidget {
  const DiaphragmaticBreathingExerciseScreen({super.key});

  @override
  State<DiaphragmaticBreathingExerciseScreen> createState() => _DiaphragmaticBreathingExerciseScreenState();
}

// Enum to manage the state of the breathing animation
enum BreathingPhase {
  inhale,
  exhale,
  initial, // For the very beginning before any cycle starts
  instructions, // New phase for showing instructions
}

class _DiaphragmaticBreathingExerciseScreenState extends State<DiaphragmaticBreathingExerciseScreen> {
  // Animation properties
  BreathingPhase _currentPhase = BreathingPhase.instructions; // Start with instructions
  double _circleDiameter = 200.0; // Initial size of the inner circle
  final double _minCircleDiameter = 200.0; // Smallest size for exhale
  final double _maxCircleDiameter = 250.0; // Largest size for inhale
  String _displayText = "Start Breathing";

  // Durations for each phase (Diaphragmatic Breathing: e.g., 4s inhale, 6s exhale)
  final Duration _inhaleDuration = const Duration(seconds: 4);
  final Duration _exhaleDuration = const Duration(seconds: 6);

  // Counter properties
  int _currentBreathCount = 0;
  final int _totalBreaths = 10; // Target breaths for the session

  // Session control
  Timer? _breathingTimer;
  bool _isSessionComplete = false;
  bool _isBreathingActive = false; // To control starting/pausing the animation

  // Descriptions and Uses
  final String _description =
      "Diaphragmatic breathing, or belly breathing, is a technique that focuses on engaging your diaphragm, a muscle located below your lungs, to draw air deeper into your lungs.";
  final String _uses =
      "It reduces stress and anxiety, lowers heart rate and blood pressure, improves relaxation, strengthens the diaphragm, and can help with conditions like COPD.";
  final String _howToInstructions =
      "1. Lie on your back or sit comfortably.\n2. Place one hand on your chest and the other on your belly.\n3. Inhale slowly through your nose, feeling your belly rise while your chest remains relatively still.\n4. Exhale slowly through pursed lips, feeling your belly fall.\n5. Focus on the movement of your belly, not your chest.";

  @override
  void initState() {
    super.initState();
    // Start with instructions, the user will trigger the actual breathing cycle
    setState(() {
      _currentPhase = BreathingPhase.instructions;
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
      _currentPhase = BreathingPhase.initial; // Transition to initial breathing phase
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

    // Inhale Phase
    setState(() {
      _currentPhase = BreathingPhase.inhale;
      _displayText = "Breathe in";
      _circleDiameter = _maxCircleDiameter; // Bigger size for inhale
    });
    await Future.delayed(_inhaleDuration);

    if (!_isBreathingActive || _isSessionComplete || !mounted) return;

    // Exhale Phase
    setState(() {
      _currentPhase = BreathingPhase.exhale;
      _displayText = "Breathe out";
      _circleDiameter = _minCircleDiameter; // Smaller size for exhale (back to initial)
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
          'Diaphragmatic Breathing', // Specific title
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
                if (_currentPhase == BreathingPhase.instructions) // Show instructions initially
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Diaphragmatic Breathing (Belly Breathing)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Uses: $_uses',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'How to do it:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _howToInstructions,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _startBreathingSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF91EEA5),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Start Exercise',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  )
                else // Show breathing animation and controls
                  Column(
                    children: [
                      const Text(
                        'Focus on your belly.', // Specific instruction
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
                                : _exhaleDuration, // Only inhale and exhale have animation duration
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
                      const SizedBox(height: 30), // Added spacing
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
