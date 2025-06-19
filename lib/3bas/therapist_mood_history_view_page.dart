// File: lib/therapist_mood_history_view_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import Intl package for date formatting
import 'package:google_fonts/google_fonts.dart'; // For consistent fonts

// Define consistent colors for the app
const Color primaryBackgroundColor = Color(0xFFF1F4F8);
const Color primaryColor = Color(0xFF91EEA5);
const Color textColor = Color(0xFF14181B);
const Color secondaryTextColor = Color(0xFF57636C);
const Color cardColor = Colors.white;

class TherapistMoodHistoryViewPage extends StatefulWidget {
  final String userId;
  final String userName; // To display the user's name in the AppBar

  const TherapistMoodHistoryViewPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  _TherapistMoodHistoryViewPageState createState() => _TherapistMoodHistoryViewPageState();
}

class _TherapistMoodHistoryViewPageState extends State<TherapistMoodHistoryViewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        title: Text(
          "${widget.userName}'s Mood History", // Dynamic title
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 22, // Slightly smaller for longer titles
          ),
          overflow: TextOverflow.ellipsis, // Handle long names
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildMoodList(),
    );
  }

  // Fetch and display mood history for the specific user ID
  Widget _buildMoodList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("moodRecords")
          .where("userId", isEqualTo: widget.userId) // Filter by provided userId
          .orderBy("timestamp", descending: false) // Order by timestamp
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.red)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)));
        }

        var moodList = snapshot.data?.docs ?? [];

        if (moodList.isEmpty) {
          return Center(
            child: Text(
              "No mood records found for ${widget.userName}.",
              style: TextStyle(fontSize: 18, color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: moodList.length,
          itemBuilder: (context, index) {
            var moodData = moodList[index].data() as Map<String, dynamic>;

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: cardColor,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.2), // Light green background
                  child: Text(
                    moodData["mood"] != null && moodData["mood"].isNotEmpty
                        ? moodData["mood"][0] // Display first emoji from mood
                        : '?', // Fallback if mood is empty
                    style: TextStyle(fontSize: 20, color: textColor),
                  ),
                ),
                title: Text(
                  moodData["mood"] ?? "Unknown Mood",
                  style: GoogleFonts.interTight(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(moodData["timestamp"]?.toString() ?? 'N/A'), // Date format
                      style: GoogleFonts.inter(fontSize: 14, color: secondaryTextColor),
                    ),
                    if (moodData["note"] != null && moodData["note"].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          "📌 Note: ${_sanitizeText(moodData["note"])}",
                          style: GoogleFonts.inter(fontSize: 15, fontStyle: FontStyle.italic, color: secondaryTextColor),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Formats Firestore timestamp into a readable date format (DD/MM/YYYY)
  String _formatDate(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      return DateFormat('dd/MM/yyyy - hh:mm a').format(dateTime); // Added time for more detail
    } catch (e) {
      return "Invalid Date";
    }
  }

  // Cleans text to avoid invalid UTF-16 characters
  String _sanitizeText(String text) {
    return text.replaceAll(RegExp(r'[^\u0000-\uFFFF]'), ''); // Remove non-UTF-16 characters
  }
}
