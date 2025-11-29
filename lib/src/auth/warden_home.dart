import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student.dart';
import 'student_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'warden_feedback_dashboard.dart';
import 'warden_complaints_dashboard.dart';
import 'warden_notice_board_page.dart';
import 'warden_menu_recommendation_page.dart'; // NEW IMPORT for Menu Recommender

class WardenHome extends StatefulWidget {
  const WardenHome({super.key});

  @override
  State<WardenHome> createState() => _WardenHomeState();
}

class _WardenHomeState extends State<WardenHome> {
  late Future<List<Student>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _fetchStudents();
  }

  Future<List<Student>> _fetchStudents() async {
    final querySnapshot =
    await FirebaseFirestore.instance.collection('students').get();
    return querySnapshot.docs
        .map((doc) => Student.fromFirestore(doc.data()!))
        .toList();
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  // Function to get daily attendance data as a Map<DateTime, int>
  Map<DateTime, int> _getDailyAttendanceMap(List<Student> students) {
    Map<DateTime, int> dailyAttendance = {};
    for (var student in students) {
      for (var record in student.attendanceRecords) {
        if (record.isPresent) {
          // Use DateTime object for reliable comparison and storage
          final date = DateTime(record.date.year, record.date.month, record.date.day);
          dailyAttendance.update(date, (value) => value + 1,
              ifAbsent: () => 1);
        }
      }
    }
    return dailyAttendance;
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF0F4F8);
    const primaryBlue = Color(0xFF1A237E);
    const accentGray = Color(0xFFB0BEC5);
    const orangeAccent = Color(0xFFFF9800); // Distinct color for Announcements
    const indigoAccent = Color(0xFF3F51B5); // Distinct color for Menu Recommender

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Warden Dashboard',
          style: TextStyle(color: background, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        actions: [
          IconButton(
            onPressed: () => setState(() => _studentsFuture = _fetchStudents()),
            icon: const Icon(Icons.refresh, color: background),
          ),
          // Complaint Prioritization Dashboard Button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WardenComplaintsDashboard()),
              );
            },
            icon: const Icon(Icons.support_agent_rounded, color: background),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: background),
          ),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: primaryBlue));
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: accentGray)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No students found',
                  style: TextStyle(color: accentGray)),
            );
          }

          final students = snapshot.data!;
          final dailyAttendance = _getDailyAttendanceMap(students);
          final sortedDates = dailyAttendance.keys.toList()
            ..sort((a, b) => a.compareTo(b));

          final spots = sortedDates.asMap().entries.map((entry) {
            final index = entry.key;
            final date = entry.value;
            return FlSpot(index.toDouble(), dailyAttendance[date]!.toDouble());
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attendance Overview',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue),
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          minX: 0,
                          maxX: sortedDates.length.toDouble() > 0 ? sortedDates.length.toDouble() - 1 : 0,
                          minY: 0,
                          maxY: students.length.toDouble() + 1,

                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  // Handles fl_chart: ^0.71.0 compatibility
                                  if (value.toInt() < sortedDates.length) {
                                    final date = sortedDates[value.toInt()];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        '${date.day}/${date.month}',
                                        style: const TextStyle(
                                          color: primaryBlue,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  // Handles fl_chart: ^0.71.0 compatibility
                                  if (value.toInt() % 5 == 0 && value.toInt() > 0) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          color: primaryBlue,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Colors.black26,
                              width: 1,
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: primaryBlue,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // --- QUICK ACTION BUTTONS ---
                Row(
                  children: [
                    // Button 1: Publish Notice
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WardenNoticeBoardPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.campaign_rounded),
                        label: const Text('Publish Notice', style: TextStyle(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangeAccent, // Distinct color for urgency
                          foregroundColor: background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Button 2: Food Feedback Dashboard
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WardenFeedbackDashboard(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.restaurant_menu_rounded),
                        label: const Text('View Feedback', style: TextStyle(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue.withOpacity(0.8),
                          foregroundColor: background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Button 3: Menu Recommendation (NEW)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WardenMenuRecommendationPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.star_rate_rounded),
                        label: const Text('Menu Recommender', style: TextStyle(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: indigoAccent,
                          foregroundColor: background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'Student Details',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.person_rounded, color: primaryBlue),
                        title: Text(student.name,
                            style: const TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text('Room: ${student.roomNumber}',
                            style: const TextStyle(color: accentGray)),
                        trailing: Text(
                          '${student.attendanceRecords.where((record) => record.isPresent).length} days',
                          style: const TextStyle(
                              color: primaryBlue, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StudentDetailPage(student: student),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}