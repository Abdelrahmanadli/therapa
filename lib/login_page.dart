// File: lib/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // For TapGestureRecognizer in RichText
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication
import 'package:therapa/home_page.dart';
import 'register_page.dart'; // Adjust this path if your file structure is different


// Define custom colors based on your specifications and image analysis
const Color primaryGreen = Color(0xFF91EEA5); // The darker green in the gradient and button
const Color lighterGreen = Color(0xFFC0F7C9); // The lighter green at the top of the gradient
const Color lightBackground = Color(0xFFF1F4F8); // Background color for input fields
const Color primaryText = Color(0xFF14181B); // Main dark text color
const Color secondaryText = Color(0xFF57636C); // Hint text, descriptive text
const Color errorColor = Colors.red; // Standard error color
const Color yellowishColor = Color(0xFFEEE691); // Defined in previous responses

// Regex for email validation (from your original FlutterFlow code)
const String kTextValidatorEmailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static String routeName = 'LoginPage'; // For potential named routes
  static String routePath = '/login';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  // Controls when validation messages are shown. Starts disabled.
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  // Text editing controllers for the input fields
  late TextEditingController emailAddressTextController;
  late TextEditingController passwordTextController;

  // Focus nodes for managing input focus
  late FocusNode emailAddressFocusNode;
  late FocusNode passwordFocusNode;

  // State variable for password visibility
  bool passwordVisibility = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    emailAddressTextController = TextEditingController();
    passwordTextController = TextEditingController();

    // Initialize focus nodes
    emailAddressFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes to prevent memory leaks
    emailAddressTextController.dispose();
    passwordTextController.dispose();

    emailAddressFocusNode.dispose();
    passwordFocusNode.dispose();

    super.dispose();
  }

  // Validator for email field
  String? _emailAddressTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Email is required';
    }
    // Check if length is at least 7 (from original FlutterFlow code)
    if (val.length < 7) {
      return 'Requires at least 7 characters.';
    }
    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Has to be a valid email address.';
    }
    return null;
  }

  // Validator for password field
  String? _passwordTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Password is required';
    }
    // Check if length is at least 7 (from original FlutterFlow code)
    if (val.length < 7) {
      return 'Requires at least 7 characters.';
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
              // Changed colors to yellowishColor and primaryGreen for the gradient
              colors: [yellowishColor, primaryGreen], // Yellowish to primary green gradient
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
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 20.0),
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
                      maxWidth: 400.0, // Keeping the same max width as register page for consistency
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
                        autovalidateMode: _autovalidateMode, // Controlled by state
                        child: Padding(
                          padding: const EdgeInsets.all(32.0), // Padding inside the card
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center, // Center contents of the card
                            children: [
                              Text(
                                'Welcome Back',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.interTight(
                                  fontSize: 34.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  color: primaryText,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 24.0),
                                child: Text(
                                  'Fill out the information below in order to access your account.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    letterSpacing: 0.0,
                                    fontSize: 14.0,
                                    color: secondaryText,
                                  ),
                                ),
                              ),
                              // Email Address Text Field
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: emailAddressTextController,
                                    focusNode: emailAddressFocusNode,
                                    autofocus: false, // Set to false to prevent immediate focus
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
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller: passwordTextController,
                                    focusNode: passwordFocusNode,
                                    autofocus: false,
                                    autofillHints: const [AutofillHints.password],
                                    textInputAction: TextInputAction.done,
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
                              // Sign In Button
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Trigger validation for the entire form
                                    setState(() {
                                      _autovalidateMode = AutovalidateMode.always;
                                    });

                                    // Check if the form is valid after triggering validation
                                    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
                                      // If form is invalid, validation errors will now be visible.
                                      return;
                                    }

                                    // If form is valid, proceed with Firebase authentication
                                    try {
                                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                                        email: emailAddressTextController.text,
                                        password: passwordTextController.text,
                                      );

                                      // Login successful, navigate to HomePage
                                      if (mounted) { // Check if the widget is still in the widget tree
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const HomePage()),
                                        );
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      // Handle specific Firebase authentication errors
                                      print('Firebase Auth Error: ${e.code} - ${e.message}');
                                      String errorMessage = 'An error occurred. Please try again.';
                                      if (e.code == 'user-not-found') {
                                        errorMessage = 'No user found for that email.';
                                      } else if (e.code == 'wrong-password') {
                                        errorMessage = 'Wrong password provided for that user.';
                                      } else if (e.code == 'invalid-email') {
                                        errorMessage = 'The email address is not valid.';
                                      } else if (e.code == 'user-disabled') {
                                        errorMessage = 'This user account has been disabled.';
                                      }
                                      _showAlertDialog('Login Failed', errorMessage);
                                    } catch (e) {
                                      // Handle other potential errors
                                      print('General Error: $e');
                                      _showAlertDialog('Error', 'Something went wrong. Please try again.');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 44.0), // Match height
                                    backgroundColor: primaryGreen, // Button background color
                                    foregroundColor: Colors.white, // Text color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                                    ),
                                    elevation: 3.0, // Match elevation
                                    side: const BorderSide(color: Colors.transparent, width: 1.0), // Transparent border
                                  ),
                                  child: Text(
                                    'Sign In',
                                    style: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // "Don't have an account? Sign Up here" text
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 40.0), // Added bottom padding
                                child: RichText(
                                  textScaler: MediaQuery.of(context).textScaler,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Don\'t have an account?  ',
                                        style: GoogleFonts.inter( // Font from your original code
                                          color: primaryText, // Default text color
                                          letterSpacing: 0.0,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Sign Up here',
                                        style: GoogleFonts.inter( // Font from your original code
                                          fontWeight: FontWeight.w600,
                                          color: primaryGreen, // Primary color for link
                                          letterSpacing: 0.0,
                                          decoration: TextDecoration.underline, // Underlined link
                                          fontSize: 14.0,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () async {
                                            // Navigate to the RegisterPage
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const RegisterPage()),
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
