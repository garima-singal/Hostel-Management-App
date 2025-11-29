import 'package:flutter/material.dart';
import 'student.dart'; // Ensure this file exists

class StudentDetailPage extends StatelessWidget {
  final Student student;

  const StudentDetailPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A237E);
    const background = Color(0xFFF0F4F8);
    const accentGray = Color(0xFFB0BEC5);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(student.name,
            style: const TextStyle(color: background, fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        iconTheme: const IconThemeData(color: background),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                detailRow('Name', student.name, Icons.person_rounded),
                detailRow('Email', student.email, Icons.email_rounded),
                detailRow('Room No', student.roomNumber, Icons.meeting_room_rounded),
                detailRow('Course', student.course, Icons.school_rounded),
                const SizedBox(height: 20),
                const Text(
                  'Attendance Records:',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: student.attendanceRecords.length,
                    itemBuilder: (context, index) {
                      final record = student.attendanceRecords[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today,
                              color: primaryBlue),
                          title: Text(
                            '${record.date.day}/${record.date.month}/${record.date.year}',
                            style: const TextStyle(color: primaryBlue),
                          ),
                          trailing: Icon(
                            record.isPresent
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: record.isPresent
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget detailRow(String label, String value, IconData icon) {
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
          Text(value, style: const TextStyle(color: accentGray)),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'student.dart';
//
// class StudentDetailPage extends StatelessWidget {
//   final Student student;
//
//   const StudentDetailPage({super.key, required this.student});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.indigo[900],
//       appBar: AppBar(
//         title: Text(student.name, style: const TextStyle(color: Colors.white)),
//         backgroundColor: Colors.indigo[800],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Card(
//           color: Colors.indigo[700],
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 detailRow('Name', student.name),
//                 detailRow('Email', student.email),
//                 detailRow('Room No', student.roomNumber),
//                 detailRow('Course', student.course),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Attendance Records:',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//                 ),
//                 const SizedBox(height: 10),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: student.attendanceRecords.length,
//                     itemBuilder: (context, index) {
//                       final record = student.attendanceRecords[index];
//                       return ListTile(
//                         title: Text(
//                           '${record.date.day}/${record.date.month}/${record.date.year}',
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                         trailing: Icon(
//                           record.isPresent ? Icons.check_circle : Icons.cancel,
//                           color: record.isPresent ? Colors.greenAccent : Colors.redAccent,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget detailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Text(
//         '$label: $value',
//         style: const TextStyle(fontSize: 18, color: Colors.white),
//       ),
//     );
//   }
// }

