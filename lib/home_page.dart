// File: lib/home_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For getting current user info
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore operations
import 'package:intl/intl.dart'; // For date formatting
import 'package:therapa/LandingPage.dart';
import 'dart:math'; // For random data generation

// Import your TasksPage here
import 'package:therapa/tasks_page.dart'; // Adjust path if needed

// Define custom colors based on your specifications and image analysis
const Color primaryGreen = Color(0xFF91EEA5); // The main green color
const Color lightBackground = Color(0xFFF1F4F8); // Background color for the page
const Color primaryText = Color(0xFF14181B); // Main dark text color
const Color secondaryText = Color(0xFF57636C); // Hint text, descriptive text
const Color cardBackground = Colors.white; // Background for cards
const Color accentGreen = Color(0xFFE0FFEA); // Lighter green for checkmark background (approximated from image)

// Function to generate random exercise items (still needed for 'Recommended Exercise')
List<Map<String, String>> _generateRandomExercises(int count) {
  final List<String> exerciseTitles = [
    'Meditation',
    'Yoga',
    'Breathing Exercises',
    'Journaling',
    'Nature Walk',
    'Stretching',
    'Mindful Eating',
    'Positive Affirmations',
    'Deep Sleep',
    'Gratitude Practice'
  ];
  final List<String> exerciseSubtitles = [
    'Mindfulness & Calm',
    'Flexibility & Strength',
    'Stress Relief',
    'Self-Reflection',
    'Grounding & Fresh Air',
    'Conscious Consumption',
    'Boosting Mood',
    'Restorative Recovery',
    'Appreciation & Joy',
    'Inner Peace'
  ];
  final random = Random();
  return List.generate(count, (index) {
    int titleIndex = random.nextInt(exerciseTitles.length);
    return {
      'title': exerciseTitles[titleIndex],
      'subtitle': exerciseSubtitles[random.nextInt(exerciseSubtitles.length)],
    };
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String routeName = 'home';
  static String routePath = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Text editing controller for the "Talk to us..." field
  late TextEditingController textController;
  late FocusNode textFieldFocusNode;

  // List of random exercise items for "Recommended Exercise"
  late List<Map<String, String>> _recommendedExercises;

  // For the bottom navigation bar
  int _selectedIndex = 0; // Current selected tab index

  // Current authenticated user
  User? currentUser;
  String? _firstName; // New: State variable to store the first name

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    textFieldFocusNode = FocusNode();

    // Initialize current user
    currentUser = FirebaseAuth.instance.currentUser;

    // Fetch user's first name from Firestore
    _fetchUserName();

    // Generate random data for recommended exercises
    _recommendedExercises = _generateRandomExercises(5); // Example: 5 exercises
  }

  // New function to fetch user's first name
  Future<void> _fetchUserName() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _firstName = userDoc['firstName'] as String? ?? currentUser?.displayName?.split(' ').first ?? 'Guest';
          });
        } else {
          setState(() {
            _firstName = currentUser?.displayName?.split(' ').first ?? 'Guest';
          });
          print('User document does not exist for UID: ${currentUser!.uid}');
        }
      } catch (e) {
        print('Error fetching user data: $e');
        setState(() {
          _firstName = currentUser?.displayName?.split(' ').first ?? 'Guest'; // Fallback to display name or 'Guest'
        });
      }
    } else {
      setState(() {
        _firstName = 'Guest'; // Set to 'Guest' if no user is logged in
      });
    }
  }

  @override
  void dispose() {
    textController.dispose();
    textFieldFocusNode.dispose();
    super.dispose();
  }

  // Function to toggle task completion status in Firestore
  Future<void> _toggleTaskCompletion(String taskId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'completed': !currentStatus,
      });
      print('Task $taskId completion status toggled to ${!currentStatus}');
    } catch (e) {
      print('Error toggling task completion: $e');
      // Optionally show an alert to the user
      _showAlertDialog('Error', 'Failed to update task completion. Please try again.');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no user is logged in, show a message or redirect
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view this page.'),
        ),
      );
    }

    // Get the start and end of the current day for Firestore query
    final DateTime now = DateTime.now();
    final DateTime startOfToday = DateTime(now.year, now.month, now.day);
    final DateTime endOfToday = startOfToday.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));

    return GestureDetector(
      onTap: () {
        // Dismiss keyboard on tap outside of input fields
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: lightBackground, // Set main background color
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Section
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 44.0, 16.0, 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Profile Picture (Card with rounded image)
                    // Added InkWell to make the profile picture tappable
                    InkWell(
                      onTap: () async {
                        // Log out the user from Firebase
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LandingPage()),
                        );
                        print('User signed out.');
                        // The StreamBuilder in main.dart will automatically handle navigation to LandingPage
                      },
                      borderRadius: BorderRadius.circular(40.0), // Match the card's border radius
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: primaryGreen, // Card background color (border-like)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0), // Fully rounded
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0), // Padding inside the card for the image
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40.0), // Image rounded
                            child: Image.network(
                              'https://placehold.co/80x80/91EEA5/FFFFFF/png?text=P', // Placeholder image URL
                              width: 40.0,
                              height: 40.0,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset('assets/images/default_avatar.png', width: 40, height: 40, fit: BoxFit.cover), // Fallback image if network fails
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Display First Name and Greeting
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Displaying the fetched first name or a loading indicator
                          _firstName == null
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                            strokeWidth: 2.0,
                          )
                              : Text(
                            _firstName!, // Use the fetched first name
                            style: GoogleFonts.interTight(
                              color: primaryText,
                              fontSize: 22.0, // Match visual
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                            child: Text(
                              'Good morning!',
                              style: GoogleFonts.inter(
                                color: secondaryText,
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // "How are you Feeling Today?" Section
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 0.0, 10.0),
                child: Text(
                  'How are you Feeling Today?',
                  style: GoogleFonts.inter(
                    color: primaryText,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600, // Semi-bold
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardBackground, // White background
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 10.0,
                        color: Color(0x162D3A21), // Soft shadow
                        offset: Offset(0.0, 10.0),
                        spreadRadius: 2.0,
                      )
                    ],
                    borderRadius: BorderRadius.circular(18.0), // Rounded corners
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 12.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: textController,
                                focusNode: textFieldFocusNode,
                                autofocus: false, // Prevents immediate focus on load
                                obscureText: false,
                                decoration: InputDecoration(
                                  hintText: 'Talk to us...',
                                  hintStyle: GoogleFonts.inter(
                                    color: secondaryText,
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent, // No visible border
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.zero, // No rounded corners for underline
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent, // No visible border
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  errorBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  focusedErrorBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.transparent,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  contentPadding: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 8.0, 12.0),
                                ),
                                style: GoogleFonts.inter(
                                  color: primaryText,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.normal,
                                ),
                                maxLines: 8,
                                minLines: 3,
                                // No validator for this text field in the original FlutterFlow code, assuming it's free text.
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end, // Align button to end
                          children: [
                            Flexible(
                              child: Align(
                                alignment: AlignmentDirectional.centerEnd, // Align button to the end
                                child: ElevatedButton(
                                  onPressed: () {
                                    print('Talk to us button pressed!');
                                    // Handle text submission here
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(90.0, 40.0), // Fixed size for button
                                    backgroundColor: primaryGreen, // Green background
                                    foregroundColor: Colors.white, // White icon color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                                    ),
                                    elevation: 2.0,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward, // Arrow icon
                                    size: 25.0,
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
              ),
              // "Tasks for Today" Section
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 0.0, 10.0),
                    child: Text(
                      'Tasks for Today',
                      style: GoogleFonts.inter(
                        color: primaryText,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd, // Align to end
                    child: InkWell( // Custom button for Add Task, navigates to TasksPage
                      borderRadius: BorderRadius.circular(8.0),
                      onTap: () async {
                        print('Add Task button pressed! Navigating to Tasks Page');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TasksPage()), // Navigate to TasksPage
                        );
                      },
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),

                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            color: secondaryText,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
                child: Container(
                  width: double.infinity,
                  height: 200.0, // Fixed height for the task list container
                  decoration: BoxDecoration(
                    color: cardBackground,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 10.0,
                        color: Color(0x33000000),
                        offset: Offset(0.0, 2.0),
                      )
                    ],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 5.0, 0.0),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: (currentUser != null)
                          ? FirebaseFirestore.instance
                          .collection('tasks')
                          .where('userRef', isEqualTo: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid))
                          .where('taskDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
                          .where('taskDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfToday))
                          .orderBy('taskDate', descending: false)
                          .orderBy('completed', descending: false) // Uncompleted tasks first
                          .snapshots()
                          : Stream.empty(), // Return empty stream if no user
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No tasks for today!',
                              style: GoogleFonts.inter(color: secondaryText),
                            ),
                          );
                        }

                        final tasks = snapshot.data!.docs;

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 10.0), // Padding inside listview
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: tasks.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 5.0),
                          itemBuilder: (context, index) {
                            final taskDoc = tasks[index];
                            final taskTitle = taskDoc['title'] as String? ?? 'No Title';
                            final isCompleted = taskDoc['completed'] as bool? ?? false;

                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                color: cardBackground, // White background
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  // Checkbox Area
                                  InkWell(
                                    onTap: () async {
                                      // Toggle completion status in Firestore
                                      await FirebaseFirestore.instance.collection('tasks').doc(taskDoc.id).update({
                                        'completed': !isCompleted,
                                      });
                                      print('Task ${taskDoc.id} completion status toggled to ${!isCompleted}');
                                    },
                                    child: Container(
                                      width: 24.0,
                                      height: 24.0,
                                      decoration: BoxDecoration(
                                        color: isCompleted ? primaryGreen : accentGreen, // Green if checked, light green if unchecked
                                        borderRadius: BorderRadius.circular(4.0),
                                        border: Border.all(
                                          color: primaryGreen,
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
                                  ),
                                  const SizedBox(width: 12.0),
                                  // Task Title
                                  Expanded(
                                    child: Text(
                                      taskTitle,
                                      style: GoogleFonts.inter(
                                        color: primaryText,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                        decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              // "Recommended Exercise" Section
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 0.0, 10.0),
                child: Text(
                  'Recommended Exercise ',
                  style: GoogleFonts.inter(
                    color: primaryText,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 175.0, // Fixed height for horizontal list
                decoration: const BoxDecoration(), // No specific decoration
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(15.0, 0.0, 15.0, 0.0),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal, // Horizontal scrolling
                    itemCount: _recommendedExercises.length, // Use random data
                    itemBuilder: (context, index) {
                      final item = _recommendedExercises[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Spacing between cards
                        child: Container(
                          width: 130.0, // Fixed width for each exercise card
                          decoration: BoxDecoration(
                            color: cardBackground, // White background
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 10.0,
                                color: Color(0x33000000), // Soft shadow
                                offset: Offset(0.0, 2.0),
                              )
                            ],
                            borderRadius: BorderRadius.circular(12.0), // Rounded corners
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // Exercise Icon/Image
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 10.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0), // Rounded corners for image
                                  child: Icon(
                                    // Using a simple icon as a placeholder for SVG/Image.
                                    // In a real app, you might use a more elaborate custom icon or network image.
                                    index % 2 == 0 ? Icons.self_improvement : Icons.spa, // Alternating icons
                                    size: 80.0,
                                    color: primaryGreen, // Icon color
                                  ),
                                ),
                              ),
                              // Exercise Title
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(12.5, 0.0, 0.0, 4.0),
                                  child: Text(
                                    item['title']!, // "Meditation", "Yoga" etc.
                                    style: GoogleFonts.inter(
                                      color: primaryText,
                                      fontSize: 14.0, // Smaller font for title
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              // Exercise Subtitle
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(12.5, 0.0, 0.0, 0.0),
                                  child: Text(
                                    item['subtitle']!, // "Mindfulness" etc.
                                    style: GoogleFonts.inter(
                                      color: secondaryText, // Lighter color for subtitle
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 80.0), // Add padding for bottom navigation bar
            ],
          ),
        ),
        // Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white, // White background for navbar
          selectedItemColor: primaryGreen, // Green for selected icon
          unselectedItemColor: secondaryText, // Darker color for unselected
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            // TODO: Implement navigation for each tab
            // Example: if (index == 0) { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage())); }
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home), // Home icon
              label: 'Home',
            ),
            BottomNavigationBarItem(
              // Placeholder for the "ghost" or "owl" like icon
              // You might need a custom icon font or SVG for exact match
              icon: Icon(Icons.psychology_alt), // A generic psychology/mind icon
              label: 'Therapy', // Label based on visual context
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), // Chat icon
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }
}
