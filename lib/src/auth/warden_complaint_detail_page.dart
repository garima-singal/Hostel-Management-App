import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WardenComplaintDetailPage extends StatelessWidget {
  final DocumentSnapshot complaintDoc;

  const WardenComplaintDetailPage({super.key, required this.complaintDoc});

  // Define color mapping for consistency
  Color getPriorityColor(String? priority) {
    switch (priority) {
      case 'Urgent':
        return Colors.redAccent;
      case 'Medium':
        return Colors.amber[700]!;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _markResolved(BuildContext context) async {
    final complaintData = complaintDoc.data() as Map<String, dynamic>;
    final originalText = complaintData['text'] as String? ?? 'An issue';
    final category = complaintData['category'] as String? ?? 'General';
    final userId = complaintData['senderId'] as String? ?? 'Unknown';

    try {
      // 1. Update the original user's complaint document to 'resolved'
      await complaintDoc.reference.update({'status': 'resolved'});

      // 2. Add a new 'System' message to the chat history for the student to see
      // This is the notification to the student
      await FirebaseFirestore.instance.collection('complaints').add({
        'text': 'System Update: Your $category complaint ("$originalText") has been resolved by the Warden. Thank you for your patience!',
        'senderId': 'System',
        'isBot': true, // Treated as a bot/system message
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'resolved',
        'category': 'system_update',
        'priority': 'Low',
        'resolvedByWardenId': userId, // For tracking who raised the original issue
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complaint marked as RESOLVED and student notified.")),
      );
      Navigator.pop(context); // Go back to the dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to resolve complaint: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A237E);
    final data = complaintDoc.data() as Map<String, dynamic>;
    final priority = data['priority'] as String? ?? 'Low';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
        backgroundColor: primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Original Complaint:', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 5),
                    Text(
                      data['text'] ?? 'No message provided.',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const Divider(height: 30),
                    _detailRow('Status', data['status'] ?? 'N/A', Colors.black54),
                    _detailRow('Priority', priority, getPriorityColor(priority)),
                    _detailRow('Category', data['category'] ?? 'N/A', primaryBlue),
                    _detailRow('Time', data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate().toString().substring(0, 16) : 'N/A', Colors.black54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (data['status'] == 'unresolved')
              ElevatedButton.icon(
                onPressed: () => _markResolved(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark as Resolved'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('This complaint has already been resolved.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}