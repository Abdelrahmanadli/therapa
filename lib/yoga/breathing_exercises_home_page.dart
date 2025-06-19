// File: lib/breathing_exercises_home_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your individual breathing exercise screens
import 'box_breathing_exercise_screen.dart';
import 'four_seven_eight_breathing_exercise_screen.dart';
import 'diaphragmatic_breathing_exercise_screen.dart';
import 'alternate_nostril_breathing_exercise_screen.dart';

// Define consistent colors for the app
const Color primaryBackgroundColor = Color(0xFFF1F4F8); // A light background color
const Color primaryColor = Color(0xFF91EEA5); // Default app green
const Color textColor = Color(0xFF14181B); // Dark text for readability
const Color cardColor = Colors.white; // White for card backgrounds
const Color accentColor = Color(0xFFC0F7C9); // Lighter green for accents

class BreathingExercisesHomePage extends StatefulWidget {
  const BreathingExercisesHomePage({super.key});

  @override
  State<BreathingExercisesHomePage> createState() => _BreathingExercisesHomePageState();
}

class _BreathingExercisesHomePageState extends State<BreathingExercisesHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false, // Set to false if you want custom back button or none
        title: Text(
          'Breathing Exercises',
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.bold,
            color: textColor, // AppBar title color, changed to match other app text
            fontSize: 24,
          ),
        ),
        centerTitle: true, // Ensures the title is truly centered
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textColor), // Back button color
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Instruction / welcome text
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                "Choose an exercise to improve your focus and memory.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: textColor,
                ),
              ),
            ),
            _buildExerciseCard(
              context,
              'Box Breathing',
              'A calming technique used to reduce stress and improve focus. Inhale, hold, exhale, hold, all for equal counts.',
              const BoxBreathingExerciseScreen(),
            ),
            _buildExerciseCard(
              context,
              '4-7-8 Breathing',
              'A relaxing breath technique that helps with sleep and anxiety. Inhale for 4, hold for 7, exhale for 8.',
              const FourSevenEightBreathingExerciseScreen(),
            ),
            _buildExerciseCard(
              context,
              'Diaphragmatic Breathing',
              'Focuses on engaging your diaphragm to draw air deeper into your lungs, reducing stress and improving relaxation.',
              const DiaphragmaticBreathingExerciseScreen(),
            ),
            _buildExerciseCard(
              context,
              'Alternate Nostril Breathing',
              'A yoga technique to balance mind and body, reduce stress, and improve focus by alternating breathing through each nostril.',
              const AlternateNostrilBreathingExerciseScreen(),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build consistent cards for each exercise
  Widget _buildExerciseCard(BuildContext context, String title, String description, Widget page) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: cardColor, // Card background color
      child: InkWell( // InkWell for tap effect
        borderRadius: BorderRadius.circular(15.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.interTight(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor, // Title color, using primary green
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: textColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.arrow_forward_ios, color: primaryColor, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
