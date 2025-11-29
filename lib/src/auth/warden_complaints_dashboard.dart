import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'warden_complaint_detail_page.dart'; // NEW IMPORT

class WardenComplaintsDashboard extends StatelessWidget {
  const WardenComplaintsDashboard({super.key});

  // Define color mapping for priority
  Color getPriorityColor(String priority) {
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

  // Define sort mapping for priority (Urgent > Medium > Low)
  int prioritySort(String p1, String p2) {
    const order = {'Urgent': 3, 'Medium': 2, 'Low': 1, 'General': 0};
    final score1 = order[p1] ?? 0;
    final score2 = order[p2] ?? 0;
    return score2.compareTo(score1);
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A237E);
    const background = Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Complaint Prioritization'),
        backgroundColor: primaryBlue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .where('isBot', isEqualTo: false) // Only show user's complaints
            .where('status', isEqualTo: 'unresolved')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryBlue));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No unresolved complaints.'));
          }

          final rawComplaints = snapshot.data!.docs;

          // Process and map raw documents to a safe list of maps
          final List<Map<String, dynamic>> safeComplaints = rawComplaints.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'doc': doc, // Store the document reference for navigation
              'text': data['text'] as String? ?? 'No message provided.',
              'category': data['category'] as String? ?? 'General',
              'priority': data['priority'] as String? ?? 'Low',
            };
          }).toList();

          // Manually sort by Priority (Urgent first)
          safeComplaints.sort((a, b) {
            final p1 = a['priority'] as String;
            final p2 = b['priority'] as String;
            return prioritySort(p1, p2);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: safeComplaints.length,
            itemBuilder: (context, index) {
              final complaint = safeComplaints[index];
              final priority = complaint['priority'] as String;
              final category = complaint['category'] as String;
              final text = complaint['text'] as String;

              final priorityColor = getPriorityColor(priority);

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.warning_rounded,
                    color: priorityColor,
                  ),
                  title: Text(
                    text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Category: $category • Priority: $priority',
                    style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to detail page, passing the original document snapshot
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WardenComplaintDetailPage(
                          complaintDoc: complaint['doc'] as DocumentSnapshot,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}