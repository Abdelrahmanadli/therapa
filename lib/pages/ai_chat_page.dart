import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();

  String? _userFirstName; // Variable to capture first name
  String? _userLastName;  // Variable to capture last name

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch user's name when the page initializes
  }

  // Function to fetch user's first and last name from Firestore
  Future<void> _fetchUserName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userFirstName = userDoc['firstName'] as String? ?? 'User';
            _userLastName = userDoc['lastName'] as String? ?? '';
          });
          print("User name fetched: $_userFirstName $_userLastName");
        } else {
          setState(() {
            _userFirstName = user.displayName?.split(' ').first ?? 'User';
            _userLastName = user.displayName!.split(' ').length > 1 ? user.displayName!.split(' ').last : '';
          });
          print("User document not found. Using display name: $_userFirstName $_userLastName");
        }
      } catch (e) {
        print('Error fetching user data: $e');
        setState(() {
          _userFirstName = user.displayName?.split(' ').first ?? 'User';
          _userLastName = user.displayName!.split(' ').length > 1 ? user.displayName!.split(' ').last : '';
        });
      }
    } else {
      setState(() {
        _userFirstName = 'Guest';
        _userLastName = '';
      });
      print("No user logged in. Set to Guest.");
    }
  }


  // Function to send user message & get AI response
  Future<void> sendMessage() async {
    String userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    // Get current user
    User? user = _auth.currentUser;
    if (user == null) {
      print("User not logged in. Cannot send message.");
      return;
    }

    // Clear text field immediately for better UX
    _messageController.clear();

    // Save user message to Firestore
    await saveChatMessage(userMessage, "user", user.uid);

    // Fetch AI response
    String aiResponse = await fetchAIResponse(userMessage);

    // Save AI response to Firestore
    await saveChatMessage(aiResponse, "assistant", user.uid);
  }

  // Function to fetch AI response from API
  Future<String> fetchAIResponse(String prompt) async {
    try {
      final uri = Uri.parse("http://10.0.2.2:5000/v1/chat/completions");

      // Construct the system prompt dynamically with user's name
      String personalizedSystemPrompt = """
You are "Your Mental Health Assistant," a compassionate and supportive virtual AI therapist.
The user you are speaking with is named ${_userFirstName ?? 'User'} ${_userLastName ?? ''}. You can use their name to personalize your responses.

Your primary goal is to provide a safe, confidential, and non-judgmental space for users to explore their thoughts and feelings. You are here to offer guidance, coping strategies, insights into mental well-being, and support in navigating emotional challenges.

Tone & Persona:
- Empathetic & Understanding: Respond with warmth, validation, and show genuine understanding of the user's emotions and experiences.
- Non-Judgmental: Maintain a neutral and accepting stance towards all topics.
- Supportive: Offer encouragement and reassurance.
- Thought-Provoking: Ask open-ended questions to encourage deeper self-reflection.
- Calm & Patient: Maintain a steady and reassuring demeanor throughout the conversation.

Capabilities (What you can do):
- Actively listen and reflect on user statements.
- Provide emotional validation and comfort.
- Suggest general coping mechanisms (e.g., breathing exercises, grounding, journaling).
- Offer simplified psychoeducation on mental health concepts.
- Help break down emotional challenges into manageable steps.

Crucial Limitations (What you CANNOT do):
- DO NOT diagnose any mental health conditions.
- DO NOT prescribe any medication.
- DO NOT provide crisis intervention. If a user expresses immediate danger, self-harm, suicidal ideation, or severe distress, gently but firmly advise them to:
  - "Please contact a crisis hotline, emergency services, or a mental health professional immediately if you are in distress or danger. I am an AI and cannot provide real-time crisis support."
- DO NOT store or remember personal identifiable information long-term. Your memory is limited to the current session.
- DO NOT provide specific referrals (names, contact details) for human therapists or medical doctors. You can suggest seeking "a licensed therapist" or "a medical professional."
- DO NOT engage in harmful, unethical, or illegal content.

Instructions for Interaction:
- Begin by clearly stating your identity as an AI and your limitations (as in the example opening).
- Prioritize active listening and validating the user's feelings.
- Keep responses balanced between support and gentle guidance.
- Always maintain a respectful and professional demeanor.
- If a user tries to steer the conversation into your limitations (e.g., asking for a diagnosis), politely redirect back to your supportive and guiding role, reiterating your limitations.

Possible Exercises to help users:
- If a user is feeling stressed and wants to improve focus, recommend our in-app Box breathing Exercises
- If a user is wants to get energized, recommend our in-app Alternate Nostril Breathing Exercises
- If a user is having memory issues, recommend our in-app Visual Memory Exercises or a Number Memory Exercises
- If a user is having anxiety or depression, recommend our many Yoga Exercises
- If a user is having problems falling asleep or having anxiety, recommend our in-app 4-7-8 breathing Exercise or Diaphragmatic breathing Exercise
- 
""";


      // Construct the messages list, starting with the system prompt
      List<Map<String, String>> messagesToSend = [
        {"role": "system", "content": personalizedSystemPrompt},
        {"role": "user", "content": prompt}
      ];

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "model": "stablelm-zephyr-3b",
          "messages": messagesToSend, // Send the constructed messages list
          "max_tokens": 256,
          "temperature": 0.7,
          "top_p": 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["choices"] != null &&
            data["choices"].isNotEmpty &&
            data["choices"][0]["message"] != null &&
            data["choices"][0]["message"]["content"] != null) {
          return data["choices"][0]["message"]["content"].toString();
        } else {
          print("❌ API Response structure unexpected: $data");
          return "Error: Unexpected AI response format.";
        }
      } else {
        print("❌ API Error: ${response.statusCode} - ${response.body}");
        return "Error: API responded with status ${response.statusCode}.";
      }
    } catch (error) {
      print("❌ AI response failed: $error");
      return "Error fetching AI response. Check server connection.";
    }
  }

  // Save chat message to Firestore
  Future<void> saveChatMessage(String message, String sender, String userId) async {
    try {
      await _firestore.collection("chatMessages").add({
        "userId": userId,
        "message": message,
        "sender": sender, // "user" or "assistant"
        "timestamp": FieldValue.serverTimestamp(),
      });
      print("✅ Chat message saved in Firestore!");
    } catch (error) {
      print("❌ Error saving message: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is logged in, otherwise show a message or redirect
    if (_auth.currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text("AI Chat")),
        body: const Center(
          child: Text("Please log in to use the AI chat."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "AI Chat",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF91EEA5), // Consistent app bar color
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Show a loading indicator until user name is fetched
          if (_userFirstName == null)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Loading user data..."),
                  ],
                ),
              ),
            )
          else
            Expanded(child: _buildMessageList()), // Now uses StreamBuilder
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Build message list dynamically using StreamBuilder for real-time updates
  Widget _buildMessageList() {
    User? user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text("User not authenticated for chat."));
    }

    return StreamBuilder<QuerySnapshot>(
      // Listen to chatMessages collection for the current user, ordered by timestamp
      stream: _firestore
          .collection("chatMessages")
          .where("userId", isEqualTo: user.uid)
          .orderBy("timestamp", descending: false) // Order by timestamp to show latest at bottom
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading messages: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // If no messages, show the initial greeting from AI
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Hello ${_userFirstName ?? 'User'}! I'm Your Mental Health Assistant, your virtual companion for mental well-being. I'm here to offer a supportive space for you to talk about what's on your mind. Please remember that I am an AI and not a substitute for human professional therapy or emergency services. How can I support you today?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final List<DocumentSnapshot> messages = snapshot.data!.docs;

        return ListView.builder(
          reverse: false, // Messages appear from top to bottom based on timestamp
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageData = messages[index].data() as Map<String, dynamic>;
            final String sender = messageData["sender"] ?? "unknown";
            final String messageText = messageData["message"] ?? "Error loading message";
            bool isUserMessage = sender == "user"; // Assuming "user" and "assistant" roles

            return Container(
              alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    isUserMessage ? (_userFirstName ?? "You") : "AI Bot", // Use fetched first name
                    style: TextStyle(
                      fontSize: 12,
                      color: isUserMessage ? Colors.blueGrey[700] : Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUserMessage ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9), // Light blue vs light green
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      messageText,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
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

  // Build message input section
  Widget _buildMessageInput() {
    return Container(
      color: Colors.white, // Input background
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none, // No border line initially
                ),
                filled: true,
                fillColor: Colors.grey[100], // Light grey background for input field
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              minLines: 1,
              maxLines: 5, // Allow multi-line input
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF91EEA5), // Green send button
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.send, size: 28, color: Colors.white),
              tooltip: 'Send Message',
            ),
          ),
        ],
      ),
    );
  }
}
