// File: lib/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For TapGestureRecognizer in RichText
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firebase Firestore

// Import your LoginPage here
import 'package:therapa/login_page.dart'; // Adjust this path if your file structure is different
// Import your HomePage here
import 'package:therapa/home_page.dart'; // Adjust this path if your file structure is different


// Define custom colors based on your specifications
// These are directly from your prompt and the image.
const Color primaryGreen = Color(0xFF91EEA5); // Primary greenish color
const Color lightBackground = Color(0xFFF1F4F8); // Background color (used as input field fill)
const Color yellowishColor = Color(0xFFEEE691); // New yellowish color for gradient
const Color primaryText = Color(0xFF14181B); // Assuming dark text color
const Color secondaryText = Color(0xFF57636C); // Assuming secondary text color (like hints)
const Color errorColor = Colors.red; // Standard error color

// Regex patterns for validation (from your original FlutterFlow code)
// Removed kTextValidatorUsernameRegex as it's no longer directly used.
const String kTextValidatorEmailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static String routeName = 'RegisterPage'; // For potential named routes
  static String routePath = '/registerPage';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  // Controls when validation messages are shown. Starts disabled.
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  // Text editing controllers for the input fields
  late TextEditingController firstNameTextController; // New: First Name
  late TextEditingController lastNameTextController;  // New: Last Name
  late TextEditingController emailAddressTextController;
  late TextEditingController passwordTextController;
  late TextEditingController confirmpasswordTextController;

  // Focus nodes for managing input focus
  late FocusNode firstNameFocusNode; // New: First Name
  late FocusNode lastNameFocusNode;  // New: Last Name
  late FocusNode emailAddressFocusNode;
  late FocusNode passwordFocusNode;
  late FocusNode confirmpasswordFocusNode;

  // State variables for password visibility
  bool passwordVisibility = false;
  bool confirmpasswordVisibility = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    firstNameTextController = TextEditingController(); // Initialize new controllers
    lastNameTextController = TextEditingController();  // Initialize new controllers
    emailAddressTextController = TextEditingController();
    passwordTextController = TextEditingController();
    confirmpasswordTextController = TextEditingController();

    // Initialize focus nodes
    firstNameFocusNode = FocusNode(); // Initialize new focus nodes
    lastNameFocusNode = FocusNode();  // Initialize new focus nodes
    emailAddressFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    confirmpasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes to prevent memory leaks
    firstNameTextController.dispose(); // Dispose new controllers
    lastNameTextController.dispose();  // Dispose new controllers
    emailAddressTextController.dispose();
    passwordTextController.dispose();
    confirmpasswordTextController.dispose();

    firstNameFocusNode.dispose(); // Dispose new focus nodes
    lastNameFocusNode.dispose();  // Dispose new focus nodes
    emailAddressFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmpasswordFocusNode.dispose();

    super.dispose();
  }

  // Validator for First Name field
  String? _firstNameValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'First Name is required';
    }
    return null;
  }

  // Validator for Last Name field
  String? _lastNameValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Last Name is required';
    }
    return null;
  }

  // Validator for email field, adapted from your FlutterFlow code
  String? _emailAddressTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Email is required';
    }
    if (val.length < 7) {
      return 'Requires at least 7 characters.';
    }
    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Has to be a valid email address.';
    }
    return null;
  }

  // Validator for password field, adapted from your FlutterFlow code
  String? _passwordTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Password is required';
    }
    if (val.length < 7) {
      return 'Requires at least 7 characters.';
    }
    return null;
  }

  // Validator for confirm password field, adapted from your FlutterFlow code
  String? _confirmpasswordTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Confirm Password is required';
    }
    if (val.length < 7) {
      return 'Requires at least 7 characters.';
    }
    if (val != passwordTextController.text) {
      return 'Passwords do not match!'; // Specific message for password mismatch
    }
    return null;
  }

  // Function to show custom alert dialog for errors/success
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
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapping outside of text fields
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        // The background of the scaffold is a gradient as seen in the image
        backgroundColor: Colors.transparent, // Set to transparent to allow Container's gradient to show
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryGreen, yellowishColor], // Top to bottom gradient
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.87, -1.0), // Starts from top right, goes to bottom left
              end: AlignmentDirectional(-0.87, 1.0),
            ),
          ),
          alignment: AlignmentDirectional.center, // Center the content vertically
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top icon/logo area
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 10.0),
                  child: Container(
                    width: 200.0,
                    height: 70.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    alignment: AlignmentDirectional.center,
                    child: Icon(
                      Icons.flutter_dash, // Example icon, replace with your actual logo/icon
                      color: primaryText, // Using primaryText for icon color
                      size: 70.0,
                    ),
                  ),
                ),
                // Main content container (the white card)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      maxWidth: 400.0, // Reduced max width for a smaller container
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white, // White background for the card
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 4.0,
                          color: Color(0x33000000), // Shadow color
                          offset: Offset(0.0, 2.0),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.center,
                      child: Form(
                        key: _formKey,
                        // Set autovalidateMode based on the state variable
                        autovalidateMode: _autovalidateMode,
                        child: Padding(
                          padding: const EdgeInsets.all(32.0), // Padding inside the card
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center, // Center contents of the card
                            children: [
                              Text(
                                'Create an account',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.interTight( // Font from your original code
                                  fontSize: 34.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold, // Adjusted for visual match
                                  color: primaryText,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 24.0),
                                child: Text(
                                  'Let\'s get started by filling out the form below.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter( // Font from your original code
                                    letterSpacing: 0.0,
                                    fontSize: 14.0, // Adjusted font size
                                    color: secondaryText,
                                  ),
                                ),
                              ),
                              // New: First Name Text Field
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: TextFormField(
                                    controller: firstNameTextController,
                                    focusNode: firstNameFocusNode,
                                    autofocus: false,
                                    textInputAction: TextInputAction.next,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'First Name',
                                      labelStyle: GoogleFonts.inter(color: secondaryText),
                                      hintStyle: GoogleFonts.inter(color: secondaryText),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: lightBackground,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: primaryGreen,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: lightBackground,
                                      contentPadding: const EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 24.0),
                                    ),
                                    style: GoogleFonts.inter(color: primaryText),
                                    validator: (value) => _firstNameValidator(context, value),
                                  ),
                                ),
                              ),
                              // New: Last Name Text Field
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: TextFormField(
                                    controller: lastNameTextController,
                                    focusNode: lastNameFocusNode,
                                    autofocus: false,
                                    textInputAction: TextInputAction.next,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'Last Name',
                                      labelStyle: GoogleFonts.inter(color: secondaryText),
                                      hintStyle: GoogleFonts.inter(color: secondaryText),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: lightBackground,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: primaryGreen,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: lightBackground,
                                      contentPadding: const EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 24.0),
                                    ),
                                    style: GoogleFonts.inter(color: primaryText),
                                    validator: (value) => _lastNameValidator(context, value),
                                  ),
                                ),
                              ),
                              // Email Address Text Field
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: TextFormField(
                                    controller: emailAddressTextController,
                                    focusNode: emailAddressFocusNode,
                                    autofocus: false,
                                    autofillHints: const [AutofillHints.email],
                                    textInputAction: TextInputAction.next,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: GoogleFonts.inter(color: secondaryText),
                                      hintStyle: GoogleFonts.inter(color: secondaryText),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: lightBackground,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: primaryGreen,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: lightBackground,
                                    ),
                                    style: GoogleFonts.inter(color: primaryText),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) => _emailAddressTextControllerValidator(context, value),
                                  ),
                                ),
                              ),
                              // Password Text Field
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: TextFormField(
                                    controller: passwordTextController,
                                    focusNode: passwordFocusNode,
                                    autofocus: false,
                                    autofillHints: const [AutofillHints.password],
                                    textInputAction: TextInputAction.next,
                                    obscureText: !passwordVisibility, // Toggles visibility
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: GoogleFonts.inter(color: secondaryText),
                                      hintStyle: GoogleFonts.inter(color: secondaryText),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: lightBackground,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: primaryGreen,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: lightBackground,
                                      suffixIcon: InkWell(
                                        onTap: () => setState(
                                              () => passwordVisibility = !passwordVisibility,
                                        ),
                                        focusNode: FocusNode(skipTraversal: true), // Skip traversal for icon
                                        child: Icon(
                                          passwordVisibility ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                          color: secondaryText,
                                          size: 24.0,
                                        ),
                                      ),
                                    ),
                                    style: GoogleFonts.inter(color: primaryText),
                                    validator: (value) => _passwordTextControllerValidator(context, value),
                                  ),
                                ),
                              ),
                              // Confirm Password Text Field
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: TextFormField(
                                    controller: confirmpasswordTextController,
                                    focusNode: confirmpasswordFocusNode,
                                    autofocus: false,
                                    textInputAction: TextInputAction.done,
                                    obscureText: !confirmpasswordVisibility, // Toggles visibility
                                    decoration: InputDecoration(
                                      labelText: 'Confirm Password',
                                      labelStyle: GoogleFonts.inter(color: secondaryText),
                                      hintStyle: GoogleFonts.inter(color: secondaryText),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: lightBackground,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: primaryGreen,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: errorColor,
                                          width: 2.0,
                                        ),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: lightBackground,
                                      suffixIcon: InkWell(
                                        onTap: () => setState(
                                              () => confirmpasswordVisibility = !confirmpasswordVisibility,
                                        ),
                                        focusNode: FocusNode(skipTraversal: true), // Skip traversal for icon
                                        child: Icon(
                                          confirmpasswordVisibility ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                          color: secondaryText,
                                          size: 24.0,
                                        ),
                                      ),
                                    ),
                                    style: GoogleFonts.inter(color: primaryText),
                                    validator: (value) => _confirmpasswordTextControllerValidator(context, value),
                                  ),
                                ),
                              ),
                              // Create Account Button
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Trigger validation for the entire form
                                    setState(() {
                                      _autovalidateMode = AutovalidateMode.always;
                                    });

                                    // Check if the form is valid after triggering validation
                                    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
                                      // If form is invalid, validation errors will now be visible.
                                      // No need to show a general alert for validation failure.
                                      return;
                                    }

                                    // If form is valid, proceed with Firebase operations
                                    try {
                                      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                        email: emailAddressTextController.text,
                                        password: passwordTextController.text,
                                      );

                                      // If authentication is successful, save user data to Firestore
                                      if (userCredential.user != null) {
                                        // Update user's display name with a combined name for Firebase Auth profile (optional)
                                        await userCredential.user!.updateDisplayName('${firstNameTextController.text} ${lastNameTextController.text}');

                                        // Get a reference to the 'users' collection in Firestore
                                        CollectionReference users = FirebaseFirestore.instance.collection('users');

                                        // Set user data in a document named after their Firebase User ID (UID)
                                        await users.doc(userCredential.user!.uid).set({
                                          'firstName': firstNameTextController.text.trim(), // Save first name
                                          'lastName': lastNameTextController.text.trim(),   // Save last name
                                          'email': emailAddressTextController.text,
                                          'created_at': FieldValue.serverTimestamp(), // Firestore server timestamp
                                          // Add any other user-specific data you want to store here
                                        });

                                        // Registration successful, navigate to HomePage
                                        if (mounted) { // Check if the widget is still in the widget tree
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => const HomePage()),
                                          );
                                        }
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      // Handle specific Firebase authentication errors
                                      print('Firebase Auth Error: ${e.code} - ${e.message}');
                                      String errorMessage = 'An error occurred. Please try again.';
                                      if (e.code == 'weak-password') {
                                        errorMessage = 'The password provided is too weak.';
                                      } else if (e.code == 'email-already-in-use') {
                                        errorMessage = 'An account already exists for that email.';
                                      } else if (e.code == 'invalid-email') {
                                        errorMessage = 'The email address is not valid.';
                                      }
                                      _showAlertDialog('Registration Failed', errorMessage);
                                    } catch (e) {
                                      // Handle other potential errors (e.g., Firestore write errors)
                                      print('General Error: $e');
                                      _showAlertDialog('Error', 'Something went wrong during registration or data saving. Please try again.');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 44.0), // Match original height
                                    backgroundColor: primaryGreen, // Button background color
                                    foregroundColor: Colors.white, // Text color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                                    ),
                                    elevation: 3.0, // Match original elevation
                                    side: const BorderSide(color: Colors.transparent, width: 1.0), // Transparent border
                                  ),
                                  child: Text(
                                    'Create Account',
                                    style: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold, // Adjusted for visual match
                                      fontSize: 16.0, // Adjusted for visual match
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // "Already have an account? Sign in here" text
                              Padding(
                                // Increased bottom padding for more space at the bottom
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                child: RichText(
                                  textScaler: MediaQuery.of(context).textScaler,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Already have an account?',
                                        style: GoogleFonts.inter( // Font from your original code
                                          color: primaryText, // Default text color
                                          letterSpacing: 0.0,
                                          fontSize: 14.0, // Adjusted font size
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' Sign in here',
                                        style: GoogleFonts.inter( // Font from your original code
                                          fontWeight: FontWeight.w600,
                                          color: primaryGreen, // Primary color for link
                                          letterSpacing: 0.0,
                                          decoration: TextDecoration.underline, // Underlined link
                                          fontSize: 14.0,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            // Navigate to the Login Page
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const LoginPage()), // Navigate to LoginPage
                                            );
                                          },
                                      )
                                    ],
                                    style: GoogleFonts.inter(letterSpacing: 0.0), // Base style for RichText
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
