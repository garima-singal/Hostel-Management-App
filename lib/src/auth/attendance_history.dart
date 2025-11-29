import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryPage extends StatelessWidget {
  const AttendanceHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.indigo[700],
      appBar: AppBar(
        title: const Text('Attendance History', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: user == null
          ? const Center(child: Text('User not logged in', style: TextStyle(color: Colors.white)))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('userId', isEqualTo: user.uid)
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No attendance records found', style: TextStyle(color: Colors.white)));
          }

          final records = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final timestamp = record['time'] as Timestamp;
              final dateTime = timestamp.toDate();
              final formattedDate = DateFormat('dd MMM yyyy – hh:mm a').format(dateTime);
              final status = record['status'];

              return Card(
                color: Colors.white24,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(formattedDate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Status: $status', style: const TextStyle(color: Colors.white70)),
                  leading: const Icon(Icons.check_circle, color: Colors.lightGreenAccent),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
