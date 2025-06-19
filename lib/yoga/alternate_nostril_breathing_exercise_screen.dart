// File: lib/alternate_nostril_breathing_exercise_screen.dart

import 'package:flutter/material.dart';
import 'dart:async'; // For Timer

class AlternateNostrilBreathingExerciseScreen extends StatefulWidget {
  const AlternateNostrilBreathingExerciseScreen({super.key});

  @override
  State<AlternateNostrilBreathingExerciseScreen> createState() => _AlternateNostrilBreathingExerciseScreenState();
}

// Enum to manage the state of the breathing animation
enum BreathingPhase {
  inhaleRight,
  hold,
  exhaleLeft,
  inhaleLeft,
  exhaleRight,
  initial, // For the very beginning before any cycle starts
  instructions, // New phase for showing instructions
}

class _AlternateNostrilBreathingExerciseScreenState extends State<AlternateNostrilBreathingExerciseScreen> {
  // Animation properties
  BreathingPhase _currentPhase = BreathingPhase.instructions; // Start with instructions
  double _circleDiameter = 200.0; // Initial size of the inner circle
  final double _minCircleDiameter = 200.0; // Smallest size
  final double _maxCircleDiameter = 250.0; // Largest size
  String _displayText = "Start Breathing";

  // Durations for each phase (Adjusted for Nadi Shodhana, e.g., 4s inhale, 4s hold, 8s exhale)
  final Duration _inhaleDuration = const Duration(seconds: 4);
  final Duration _holdDuration = const Duration(seconds: 4); // Common hold duration
  final Duration _exhaleDuration = const Duration(seconds: 8);

  // Counter properties
  int _currentBreathCount = 0;
  final int _totalBreaths = 5; // Target breaths for the session (each full cycle is one breath)

  // Session control
  Timer? _breathingTimer;
  bool _isSessionComplete = false;
  bool _isBreathingActive = false; // To control starting/pausing the animation

  // Descriptions and Uses
  final String _description =
      "Alternate Nostril Breathing (Nadi Shodhana) is a yoga breathing technique that involves inhaling through one nostril, holding the breath, and then exhaling through the other nostril, alternating sides.";
  final String _uses =
      "It balances the left and right hemispheres of the brain, reduces stress, calms the mind, improves focus, and can purify energetic channels.";
  final String _howToInstructions =
      "1. Sit comfortably. Place your right thumb on your right nostril and your ring finger on your left nostril.\n2. Close your right nostril with your thumb. Inhale slowly through your left nostril.\n3. Close your left nostril with your ring finger (release thumb). Hold your breath.\n4. Open your right nostril and exhale slowly through it.\n5. Inhale slowly through your right nostril.\n6. Close your right nostril with your thumb (release ring finger). Hold your breath.\n7. Open your left nostril and exhale slowly through it.\nThis completes one round. Continue alternating.";

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

    // Inhale Right (visually just "Inhale" but implies direction by text)
    setState(() {
      _currentPhase = BreathingPhase.inhaleRight;
      _displayText = "Inhale Left"; // Instruction for user
      _circleDiameter = _maxCircleDiameter;
    });
    await Future.delayed(_inhaleDuration);
    if (!_isBreathingActive || _isSessionComplete || !mounted) return;

    // Hold
    setState(() {
      _currentPhase = BreathingPhase.hold;
      _displayText = "Hold";
      // Circle remains at max diameter
    });
    await Future.delayed(_holdDuration);
    if (!_isBreathingActive || _isSessionComplete || !mounted) return;

    // Exhale Left (visually just "Exhale" but implies direction by text)
    setState(() {
      _currentPhase = BreathingPhase.exhaleLeft;
      _displayText = "Exhale Right"; // Instruction for user
      _circleDiameter = _minCircleDiameter;
    });
    await Future.delayed(_exhaleDuration);
    if (!_isBreathingActive || _isSessionComplete || !mounted) return;

    // Inhale Left (Second half of the cycle, keeping circle at min size for preparation)
    setState(() {
      _currentPhase = BreathingPhase.inhaleLeft;
      _displayText = "Inhale Right"; // Instruction for user
      _circleDiameter = _maxCircleDiameter;
    });
    await Future.delayed(_inhaleDuration);
    if (!_isBreathingActive || _isSessionComplete || !mounted) return;

    // Hold (again)
    setState(() {
      _currentPhase = BreathingPhase.hold;
      _displayText = "Hold";
      // Circle remains at max diameter
    });
    await Future.delayed(_holdDuration);
    if (!_isBreathingActive || _isSessionComplete || !mounted) return;

    // Exhale Right (Second half of the cycle)
    setState(() {
      _currentPhase = BreathingPhase.exhaleRight;
      _displayText = "Exhale Left"; // Instruction for user
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
          'Alternate Nostril Breathing', // Specific title
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22, // Slightly smaller title for longer text
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
                        'Alternate Nostril Breathing (Nadi Shodhana)',
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
                        'Follow the instructions carefully.', // General instruction for complex breathing
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
                            duration: (_currentPhase == BreathingPhase.inhaleLeft || _currentPhase == BreathingPhase.inhaleRight)
                                ? _inhaleDuration
                                : (_currentPhase == BreathingPhase.exhaleLeft || _currentPhase == BreathingPhase.exhaleRight ? _exhaleDuration : _holdDuration),
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
