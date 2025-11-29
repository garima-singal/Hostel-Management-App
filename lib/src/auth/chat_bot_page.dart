import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final _messageController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final String _apiKey = "AIzaSyBBLyvFeR9i8YOvsvLZ38CfengEax7fpvc"; // Ensure this is your correct key
  late final GenerativeModel _model;

  final List<String> _conversationStarters = [
    'Report a maintenance issue',
    'Ask about hostel rules',
    'Get a status update on a complaint',
  ];

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      // UPDATED: More specific System Instruction for reporting
      systemInstruction: Content.text(
          "You are HostelBot, a polite AI assistant for AL Hostel. Your primary role is to log complaints. When a user reports a specific issue (like 'no water' or 'broken fan'), you must acknowledge the issue, assure the student it will be logged, and then thank them. Do not try to solve the technical issue yourself. Always be friendly and professional."
      ),
    );
  }

  // NEW: Logic for Categorization and Priority Assignment
  Map<String, String> _analyzeComplaint(String text) {
    final lowerCaseText = text.toLowerCase();
    String category = 'General';
    String priority = 'Low';

    if (lowerCaseText.contains('water') || lowerCaseText.contains('leak') || lowerCaseText.contains('plumbing')) {
      category = 'Plumbing';
      if (lowerCaseText.contains('not coming') || lowerCaseText.contains('no water')) {
        priority = 'Urgent';
      } else if (lowerCaseText.contains('small leak') || lowerCaseText.contains('slow')) {
        priority = 'Medium';
      }
    } else if (lowerCaseText.contains('wifi') || lowerCaseText.contains('internet') || lowerCaseText.contains('network')) {
      category = 'IT/Network';
      if (lowerCaseText.contains('down') || lowerCaseText.contains('no internet')) {
        priority = 'Urgent';
      } else {
        priority = 'Medium';
      }
    } else if (lowerCaseText.contains('light') || lowerCaseText.contains('fan') || lowerCaseText.contains('ac') || lowerCaseText.contains('power')) {
      category = 'Electrical';
      if (lowerCaseText.contains('no power') || lowerCaseText.contains('short circuit')) {
        priority = 'Urgent';
      } else {
        priority = 'Medium';
      }
    } else if (lowerCaseText.contains('broken') || lowerCaseText.contains('table') || lowerCaseText.contains('bed')) {
      category = 'Maintenance';
      priority = 'Medium';
    } else if (lowerCaseText.contains('mess') || lowerCaseText.contains('food') || lowerCaseText.contains('dirty') || lowerCaseText.contains('bad smell')) {
      category = 'Hygiene/Mess';
      priority = 'Medium';
    }

    return {'category': category, 'priority': priority};
  }

  Future<List<Content>> _getChatHistory() async {
    final snapshot = await _firestore
        .collection('complaints')
        .orderBy('timestamp', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final isBot = data['isBot'] as bool? ?? false;
      final text = data['text'] as String? ?? '';
      return Content(
        isBot ? 'model' : 'user',
        [TextPart(text)],
      );
    }).toList();
  }

  void _sendMessage({String? presetMessage}) async {
    final user = _auth.currentUser;
    final messageText = presetMessage ?? _messageController.text.trim();

    if (user == null || messageText.isEmpty) return;

    _messageController.clear();

    // Analyze the text to get category and priority
    final analysis = _analyzeComplaint(messageText);

    // Add user's message to Firestore with NEW prioritization data
    await _firestore.collection('complaints').add({
      'text': messageText,
      'senderId': user.uid,
      'isBot': false,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'unresolved',
      'category': analysis['category'],
      'priority': analysis['priority'],
    });

    try {
      final history = await _getChatHistory();
      final chat = _model.startChat(history: history);

      final response = await chat.sendMessage(Content.text(messageText));
      final botResponseText = response.text ?? 'Sorry, I could not generate a response.';

      await _firestore.collection('complaints').add({
        'text': botResponseText,
        'senderId': 'GeminiBot',
        'isBot': true,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'resolved',
        'category': 'response',
        'priority': 'low',
      });
    } catch (e) {
      print('Gemini API Error: $e');

      await _firestore.collection('complaints').add({
        'text': 'An error occurred. Please try again later.',
        'senderId': 'GeminiBot',
        'isBot': true,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'error',
        'category': 'error',
        'priority': 'low',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A237E);
    const background = Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Hostel ChatBot'),
        backgroundColor: primaryBlue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('complaints')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: primaryBlue));
                }

                final messages = snapshot.data!.docs;
                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  final messageData = message.data() as Map<String, dynamic>;
                  final messageText = messageData['text'] as String;
                  final isBot = messageData['isBot'] as bool? ?? false;

                  final messageBubble = Align(
                    alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        color: isBot ? Colors.grey[300] : primaryBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        messageText,
                        style: TextStyle(
                          color: isBot ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  );
                  messageWidgets.add(messageBubble);
                }

                return ListView(
                  children: messageWidgets,
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            color: background,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _conversationStarters.map((text) {
                return ElevatedButton(
                  onPressed: () => _sendMessage(presetMessage: text),
                  child: Text(text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask a question or report an issue...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: background,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: primaryBlue),
                  onPressed: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
