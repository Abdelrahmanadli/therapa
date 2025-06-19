import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Keep this import even if not directly used for user fetching here, often part of app context
import 'package:flutter/material.dart';

// Import the new view-only pages
import 'therapist_mood_history_view_page.dart';
import 'therapist_tasks_view_page.dart';

// Define consistent colors for the app
const Color primaryBackgroundColor = Color(0xFFF1F4F8); // A light background color
const Color primaryColor = Color(0xFF91EEA5); // Default app green
const Color textColor = Color(0xFF14181B); // Dark text for readability
const Color cardColor = Colors.white; // White for card backgrounds
const Color buttonTextColor = Colors.white; // Text color for primary buttons
const Color secondaryButtonColor = Colors.grey; // Color for secondary actions (e.g., back button background)

class TherapistUserProfilePage extends StatefulWidget {
  final String userId; // Receives user ID from navigation

  const TherapistUserProfilePage({super.key, required this.userId});

  @override
  State<TherapistUserProfilePage> createState() =>
      _TherapistUserProfilePageState();
}

class _TherapistUserProfilePageState extends State<TherapistUserProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Load user data when page opens
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot doc =
      await _firestore.collection("users").doc(widget.userId).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        // If user data not found, pop the page and show a message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Error: User profile not found"),
                backgroundColor: Colors.red),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to load user profile: $e"),
              backgroundColor: Colors.red),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "User Profile",
          style: TextStyle(
            color: textColor, // Consistent title color
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: primaryColor, // Consistent AppBar background
        centerTitle: true,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator()) // Show loader while fetching data
          : userData == null
          ? const Center(child: Text("User data not available"))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons horizontally
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReadOnlyField("First Name", userData!['firstName'] ?? "N/A"),
                    _buildReadOnlyField("Last Name", userData!['lastName'] ?? "N/A"),
                    _buildReadOnlyField("Email", userData!['email'] ?? "N/A"),
                    // You can add more fields here if needed from userData
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30), // Spacing between profile card and buttons

            // Button to Mood History
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TherapistMoodHistoryViewPage(
                      userId: widget.userId,
                      userName: "${userData!['firstName'] ?? 'User'} ${userData!['lastName'] ?? ''}",
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.mood, color: buttonTextColor),
              label: const Text(
                "View Mood History",
                style: TextStyle(fontSize: 18, color: buttonTextColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, // App's primary green
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 3,
              ),
            ),
            const SizedBox(height: 15), // Spacing between buttons

            // Button to Tasks List
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TherapistTasksViewPage(
                      userId: widget.userId,
                      userName: "${userData!['firstName'] ?? 'User'} ${userData!['lastName'] ?? ''}",
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.task, color: buttonTextColor),
              label: const Text(
                "View Tasks List",
                style: TextStyle(fontSize: 18, color: buttonTextColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, // App's primary green
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 3,
              ),
            ),
            const SizedBox(height: 30), // Spacing before back button

            // Back Button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryButtonColor, // Greyish color
                foregroundColor: buttonTextColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 3,
              ),
              child: const Text(
                "Back to Contacts",
                style: TextStyle(fontSize: 18, color: buttonTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function for read-only fields
  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
          floatingLabelStyle: TextStyle(color: primaryColor), // Highlight label when focused
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          filled: true,
          fillColor: Colors.grey[50], // Light fill for the text field
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        style: const TextStyle(fontSize: 16, color: textColor),
      ),
    );
  }
}
