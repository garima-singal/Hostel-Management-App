import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentRegistrationPage extends StatefulWidget {
  const StudentRegistrationPage({super.key});

  @override
  State<StudentRegistrationPage> createState() =>
      _StudentRegistrationPageState();
}

class _StudentRegistrationPageState extends State<StudentRegistrationPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _roomController = TextEditingController();
  final _courseController = TextEditingController();
  final _passController = TextEditingController();

  File? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _registerStudent() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final room = _roomController.text.trim();
    final course = _courseController.text.trim();
    final password = _passController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        room.isEmpty ||
        course.isEmpty ||
        password.isEmpty ||
        _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill all fields and upload a photo")));
      return;
    }

    setState(() => _isUploading = true);

    UserCredential? userCredential;
    try {
      // Step 1: Create user in Firebase Authentication
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Step 2: Create student document in Firestore
      await FirebaseFirestore.instance.collection('students').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'roomNo': room,
        'course': course,
        'photoBase64': base64Image,
        'attendance': [],
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Student registered successfully")));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Auth Error: ${e.message}")));
    } catch (e) {
      // Rollback: If Firestore fails, delete the user from Authentication
      if (userCredential != null) {
        userCredential.user?.delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Registration failed. Please try again. Error: $e")));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A237E);
    const background = Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('Student Registration',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue)),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: primaryBlue.withOpacity(0.1),
                      backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? const Icon(Icons.camera_alt_rounded,
                          color: primaryBlue, size: 40)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_rounded),
                  _buildTextField(
                      controller: _emailController,
                      label: 'Official Email',
                      icon: Icons.email_rounded),
                  _buildTextField(
                      controller: _roomController,
                      label: 'Room No',
                      icon: Icons.meeting_room_rounded),
                  _buildTextField(
                      controller: _courseController,
                      label: 'Course',
                      icon: Icons.school_rounded),
                  _buildTextField(
                      controller: _passController,
                      label: 'Password',
                      icon: Icons.lock_rounded,
                      obscure: true),
                  const SizedBox(height: 40),
                  _isUploading
                      ? const CircularProgressIndicator(color: primaryBlue)
                      : ElevatedButton(
                    onPressed: _registerStudent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: background,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: const Text('Register', style: TextStyle(fontSize: 18)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    const primaryBlue = Color(0xFF1A237E);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        cursorColor: primaryBlue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: primaryBlue),
          prefixIcon: Icon(icon, color: primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: primaryBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
        ),
      ),
    );
  }
}
// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class StudentRegistrationPage extends StatefulWidget {
//   const StudentRegistrationPage({super.key});
//
//   @override
//   State<StudentRegistrationPage> createState() => _StudentRegistrationPageState();
// }
//
// class _StudentRegistrationPageState extends State<StudentRegistrationPage> {
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _roomController = TextEditingController();
//   final _courseController = TextEditingController();
//   final _passController = TextEditingController();
//
//   File? _imageFile;
//   bool _isUploading = false;
//
//   Future<void> _pickImage() async {
//     final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50);
//     if (picked != null) {
//       setState(() {
//         _imageFile = File(picked.path);
//       });
//     }
//   }
//
//   Future<void> _registerStudent() async {
//     final name = _nameController.text.trim();
//     final email = _emailController.text.trim();
//     final room = _roomController.text.trim();
//     final course = _courseController.text.trim();
//     final password = _passController.text.trim();
//
//     if (name.isEmpty || email.isEmpty || room.isEmpty || course.isEmpty || password.isEmpty || _imageFile == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields and upload a photo")));
//       return;
//     }
//
//     setState(() => _isUploading = true);
//
//     try {
//       final bytes = await _imageFile!.readAsBytes();
//       final base64Image = base64Encode(bytes);
//
//       final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       final uid = userCredential.user!.uid;
//
//       await FirebaseFirestore.instance.collection('students').doc(uid).set({
//         'uid': uid,
//         'name': name,
//         'email': email,
//         'roomNo': room,
//         'course': course,
//         'photoBase64': base64Image,
//         'attendance': [], // ✅ Important: initialize this field
//         'createdAt': Timestamp.now(),
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Student registered successfully")));
//       Navigator.pop(context);
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Auth Error: ${e.message}")));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
//     } finally {
//       setState(() => _isUploading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.indigo[700],
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text('Student Registration',
//                   style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
//               const SizedBox(height: 20),
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: CircleAvatar(
//                   radius: 55,
//                   backgroundColor: Colors.white24,
//                   backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
//                   child: _imageFile == null
//                       ? const Icon(Icons.camera_alt, color: Colors.white70, size: 35)
//                       : null,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               _buildTextField(controller: _nameController, label: 'Name'),
//               _buildTextField(controller: _emailController, label: 'Official Email'),
//               _buildTextField(controller: _roomController, label: 'Room No'),
//               _buildTextField(controller: _courseController, label: 'Course'),
//               _buildTextField(controller: _passController, label: 'Password', obscure: true),
//               const SizedBox(height: 30),
//               _isUploading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : ElevatedButton(
//                 onPressed: _registerStudent,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: Colors.indigo,
//                   padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 ),
//                 child: const Text('Register'),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     bool obscure = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: TextField(
//         controller: controller,
//         obscureText: obscure,
//         style: const TextStyle(color: Colors.white),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: Colors.white),
//           filled: true,
//           fillColor: Colors.white24,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       ),
//     );
//   }
// }




