import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WardenNoticeBoardPage extends StatefulWidget {
  const WardenNoticeBoardPage({super.key});

  @override
  State<WardenNoticeBoardPage> createState() => _WardenNoticeBoardPageState();
}

class _WardenNoticeBoardPageState extends State<WardenNoticeBoardPage> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isPublishing = false;

  final primaryBlue = const Color(0xFF1A237E);
  final background = const Color(0xFFF0F4F8);

  Future<void> _publishNotice() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill both title and message.")),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      await FirebaseFirestore.instance.collection('announcements').add({
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Announcement published successfully!")),
      );
      Navigator.pop(context); // Go back to home
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to publish: ${e.toString()}")),
      );
    } finally {
      setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Publish Announcement'),
        backgroundColor: primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'New Notice',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Notice Title (e.g., Water Cutoff)',
                    prefixIcon: Icon(Icons.campaign_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _messageController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Details (e.g., Water will be off from 10am to 1pm.)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 40),
                _isPublishing
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
                    : ElevatedButton.icon(
                  onPressed: _publishNotice,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Publish Notice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: background,
                    padding: const EdgeInsets.symmetric(vertical: 15),
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