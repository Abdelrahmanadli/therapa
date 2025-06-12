// File: lib/specialty_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/scheduler.dart'; // Import for SchedulerBinding

// Define custom colors (consistent with other pages)
const Color primaryGreen = Color(0xFF91EEA5);
const Color lightBackground = Color(0xFFF1F4F8);
const Color primaryText = Color(0xFF14181B);
const Color secondaryText = Color(0xFF57636C);
const Color alternateColor = Color(0xFFE0E0E0);
const Color cardBackground = Colors.white;

class SpecialtySelectionScreen extends StatefulWidget {
  final List<String> initialSelectedSpecialties;
  final List<String> allSpecialties;

  const SpecialtySelectionScreen({
    super.key,
    required this.initialSelectedSpecialties,
    required this.allSpecialties,
  });

  @override
  State<SpecialtySelectionScreen> createState() => _SpecialtySelectionScreenState();
}

class _SpecialtySelectionScreenState extends State<SpecialtySelectionScreen> {
  // A temporary list to hold selected specialties within this screen,
  // allowing changes without affecting the parent until 'Done' is pressed.
  late List<String> _currentSelections;

  @override
  void initState() {
    super.initState();
    // Initialize with a copy of the initial list to avoid modifying the parent's list directly
    _currentSelections = List.from(widget.initialSelectedSpecialties);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: Text(
          'Select Specialties',
          style: GoogleFonts.interTight(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            // Defer the pop operation using SchedulerBinding
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) { // Ensure the widget is still mounted
                Navigator.of(context).pop(null);
              }
            });
          },
        ),
        elevation: 4.0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: widget.allSpecialties.length,
                itemBuilder: (context, index) {
                  final specialty = widget.allSpecialties[index];
                  return Card(
                    color: cardBackground,
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                        color: _currentSelections.contains(specialty) ? primaryGreen : alternateColor,
                        width: _currentSelections.contains(specialty) ? 2.0 : 1.0,
                      ),
                    ),
                    elevation: 2.0,
                    child: CheckboxListTile(
                      title: Text(
                        specialty,
                        style: GoogleFonts.inter(
                          color: primaryText,
                          fontSize: 16.0,
                        ),
                      ),
                      value: _currentSelections.contains(specialty),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            _currentSelections.add(specialty);
                          } else {
                            _currentSelections.remove(specialty);
                          }
                        });
                      },
                      activeColor: primaryGreen,
                      checkColor: cardBackground,
                      controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Defer the pop operation using SchedulerBinding
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          if (mounted) { // Ensure the widget is still mounted
                            Navigator.of(context).pop(List.from(_currentSelections));
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        elevation: 2.0,
                      ),
                      child: Text(
                        'Done',
                        style: GoogleFonts.interTight(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
