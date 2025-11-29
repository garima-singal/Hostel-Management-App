import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'food_feedback_page.dart';
import 'chat_bot_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  String? _studentName;
  String? _studentEmail;
  String? _studentRoom;
  String? _studentCourse;
  String? _photoBase64;
  List<Map<String, dynamic>> _attendanceRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
    _setupFCM();
  }

  void _setupFCM() async {
    await FirebaseMessaging.instance.requestPermission();
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print("FCM Token: $token");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🚨 NEW NOTICE: ${message.notification?.title ?? 'Announcement'}", style: const TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 8),
          backgroundColor: Colors.red.shade700,
        ),
      );
    });
  }

  Future<void> _fetchStudentData() async {
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
      await FirebaseFirestore.instance.collection('students').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _studentName = data['name'];
          _studentEmail = data['email'];
          _studentRoom = data['roomNo'];
          _studentCourse = data['course'];
          _photoBase64 = data['photoBase64'];
          _attendanceRecords =
          List<Map<String, dynamic>>.from(data['attendance'] ?? []);
        });
      }
    }

    setState(() => _isLoading = false);
  }

  Future<bool> _isWithinAllowedLocation() async {
    const allowedLatitude = 28.3670;
    const allowedLongitude = 77.3170;
    const allowedRadiusInMeters = 100.0;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }
    }

    final position =
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    final distance = Geolocator.distanceBetween(
      allowedLatitude,
      allowedLongitude,
      position.latitude,
      position.longitude,
    );

    return distance <= allowedRadiusInMeters;
  }

  Future<void> _markAttendance() async {
    try {
      final picked = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 50);
      if (picked == null) return;

      final inputImage = InputImage.fromFilePath(picked.path);

      final options = FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate);
      final faceDetector = FaceDetector(options: options);
      final faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No face detected. Please try again.')),
        );
        return;
      } else if (faces.length > 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Multiple faces detected. Please be alone in the photo.')),
        );
        return;
      }

      final isAllowed = await _isWithinAllowedLocation();
      if (!isAllowed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be at the university to mark attendance.')),
        );
        return;
      }

      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);

      bool alreadyMarkedToday = _attendanceRecords.any((record) {
        final recordDate = (record['date'] as Timestamp).toDate();
        return recordDate.year == todayDate.year &&
            recordDate.month == todayDate.month &&
            recordDate.day == todayDate.day;
      });

      if (alreadyMarkedToday) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance already marked today')),
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final newAttendance = {
        'date': Timestamp.now(),
        'isPresent': true,
      };

      _attendanceRecords.add(newAttendance);

      await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .update({'attendance': _attendanceRecords});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance marked successfully')),
      );

      _fetchStudentData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  // Widget for the Announcement Banner
  Widget _buildAnnouncementBanner() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('timestamp', descending: true)
          .limit(1) // Only show the latest announcement
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink(); // Hide if no announcements
        }

        final doc = snapshot.data!.docs.first;
        final title = doc['title'] as String? ?? 'Announcement';
        final message = doc['message'] as String? ?? '';
        final timestamp = doc['timestamp'] as Timestamp?;

        // --- NEW 12-HOUR EXPIRY LOGIC ---
        if (timestamp != null) {
          final publishTime = timestamp.toDate();
          final expiryTime = publishTime.add(const Duration(hours: 12));
          final now = DateTime.now();

          // If the current time is AFTER the expiry time, hide the banner
          if (now.isAfter(expiryTime)) {
            return const SizedBox.shrink(); // Notice has expired
          }
        }
        // --- END EXPIRY LOGIC ---

        String timeString = 'No date available';
        if (timestamp != null) {
          final date = timestamp.toDate();
          // Format the date to show Day/Month/Year and Hour:Minute
          timeString = '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
        }

        return Card(
          color: Colors.orange.shade100,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            leading: Icon(Icons.campaign_rounded, color: Colors.orange.shade800),
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
            // Subtitle now shows the timestamp
            subtitle: Text('Posted: $timeString - $message', maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(title),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message),
                      const SizedBox(height: 10),
                      Text('Published on: $timeString', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A237E);
    const background = Color(0xFFF0F4F8);
    const accentGray = Color(0xFFB0BEC5);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Student Home', style: TextStyle(color: background, fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        actions: [
          IconButton(
            onPressed: _fetchStudentData,
            icon: const Icon(Icons.refresh, color: background),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: background),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatBotPage()),
              );
            },
            icon: const Icon(Icons.chat_bubble_rounded, color: background),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryBlue))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Insert Announcement Banner here
            _buildAnnouncementBanner(),

            if (_photoBase64 != null)
              CircleAvatar(
                radius: 55,
                backgroundImage: MemoryImage(base64Decode(_photoBase64!)),
              ),
            const SizedBox(height: 20),
            _buildDetailCard(
              children: [
                _detailText('Name', _studentName ?? 'N/A', Icons.person_rounded),
                _detailText('Email', _studentEmail ?? 'N/A', Icons.email_rounded),
                _detailText('Room No', _studentRoom ?? 'N/A', Icons.meeting_room_rounded),
                _detailText('Course', _studentCourse ?? 'N/A', Icons.school_rounded),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _markAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: background,
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Text('Mark Attendance', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FoodFeedbackPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue.withOpacity(0.8),
                foregroundColor: background,
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child: const Text('Give Food Feedback', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 30),
            const Text('Attendance Records',
                style: TextStyle(
                    fontSize: 20,
                    color: primaryBlue,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._attendanceRecords.map((record) {
              final recordDate = (record['date'] as Timestamp).toDate();
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.calendar_month,
                      color: primaryBlue),
                  title: Text(
                    '${recordDate.day}/${recordDate.month}/${recordDate.year}',
                    style: const TextStyle(color: primaryBlue),
                  ),
                  trailing: const Icon(Icons.check_circle_rounded,
                      color: Colors.green),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _detailText(String label, String value, IconData icon) {
    const primaryBlue = Color(0xFF1A237E);
    const accentGray = Color(0xFFB0BEC5);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: accentGray),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}