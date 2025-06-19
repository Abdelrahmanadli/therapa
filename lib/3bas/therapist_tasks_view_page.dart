// File: lib/therapist_tasks_view_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:google_fonts/google_fonts.dart'; // For consistent fonts

// Define consistent colors for the app, matching the #91EEA5 primary color
const Color primaryBackgroundColor = Color(0xFFF1F4F8);
const Color primaryColor = Color(0xFF91EEA5); // Default app green
const Color textColor = Color(0xFF14181B); // Dark text for readability
const Color secondaryTextColor = Color(0xFF57636C); // Greyish text
const Color cardColor = Colors.white;
const Color completedTaskColor = Colors.green;
const Color pendingTaskColor = Colors.orange;
const Color accentGreen = Color(0xFFE0FFEA); // A lighter green for unchecked boxes, if needed

class TherapistTasksViewPage extends StatefulWidget {
  final String userId;
  final String userName; // To display the user's name in the AppBar

  const TherapistTasksViewPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  _TherapistTasksViewPageState createState() => _TherapistTasksViewPageState();
}

class _TherapistTasksViewPageState extends State<TherapistTasksViewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        title: Text(
          "${widget.userName}'s Tasks", // Dynamic title
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
      body: _buildTaskList(),
    );
  }

  // Fetch and display tasks for the specific user ID using DocumentReference
  Widget _buildTaskList() {
    // Create a DocumentReference to the specific user's document
    final userDocRef = _firestore.collection('users').doc(widget.userId);

    return StreamBuilder<QuerySnapshot>(
      // Query the top-level 'tasks' collection
      stream: _firestore
          .collection('tasks')
      // Filter tasks where 'userRef' field is equal to the user's DocumentReference
          .where('userRef', isEqualTo: userDocRef)
      // Removed date filtering to show all tasks for the user
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Firestore Stream Error for Tasks: ${snapshot.error}"); // Added print for debugging
          return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.red)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)));
        }

        var taskList = snapshot.data?.docs ?? [];

        if (taskList.isEmpty) {
          print("No tasks found for user ${widget.userId} with userRef matching ${userDocRef.path}."); // Debug print
          return Center(
            child: Text(
              "No tasks found for ${widget.userName}.",
              style: TextStyle(fontSize: 18, color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          );
        }

        // Added print for debugging fetched tasks
        print("Fetched ${taskList.length} tasks for user: ${widget.userName} (ID: ${widget.userId})");
        for (var doc in taskList) {
          print("Task data: ${doc.data()}");
        }


        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          itemCount: taskList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12.0),
          itemBuilder: (context, index) {
            final taskDoc = taskList[index];
            final taskTitle = taskDoc['title'] as String? ?? 'No Title';
            final isCompleted = taskDoc['completed'] as bool? ?? false;
            final Timestamp? taskDateTimestamp = taskDoc['taskDate'] as Timestamp?; // Get taskDate as Timestamp
            final String taskDate = _formatDate(taskDateTimestamp?.toDate()); // Format it

            return Container( // Changed from InkWell to Container as navigation is removed
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: cardColor, // White background
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 4.0,
                    color: Color(0x33000000), // Hex for rgba(0,0,0,0.2)
                    offset: Offset(0.0, 2.0),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Checkbox Area (now just displays status, not interactive)
                  Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? primaryColor // Green if checked
                          : accentGreen, // Light green if unchecked
                      borderRadius: BorderRadius.circular(4.0),
                      border: Border.all(
                        color: primaryColor,
                        width: 2.0,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(
                      Icons.check,
                      size: 16.0,
                      color: Colors.white,
                    )
                        : null,
                  ),
                  const SizedBox(width: 12.0),
                  // Task Title and Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          taskTitle,
                          style: GoogleFonts.inter(
                            color: textColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        if (taskDate != "N/A") // Only show date if available
                          Text(
                            "Due: $taskDate",
                            style: GoogleFonts.inter(
                              color: secondaryTextColor,
                              fontSize: 12.0,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Formats DateTime to a readable date string (DD/MM/YYYY)
  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}
