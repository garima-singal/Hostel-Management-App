import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final DateTime date;
  final bool isPresent;

  AttendanceRecord({required this.date, required this.isPresent});

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      date: (map['date'] as Timestamp).toDate(),
      isPresent: map['isPresent'] ?? false,
    );
  }
}

class Student {
  final String id;
  final String name;
  final String email;
  final String course;
  final String roomNumber;
  final String? photoBase64;
  final List<AttendanceRecord> attendanceRecords;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.course,
    required this.roomNumber,
    this.photoBase64,
    required this.attendanceRecords,
  });

  factory Student.fromFirestore(Map<String, dynamic> data) {
    return Student(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      course: data['course'] ?? '',
      roomNumber: data['roomNo'] ?? '',
      photoBase64: data['photoBase64'],
      attendanceRecords: data['attendance'] != null
          ? List<Map<String, dynamic>>.from(data['attendance'])
          .map((record) => AttendanceRecord.fromMap(record))
          .toList()
          : [],
    );
  }
}
