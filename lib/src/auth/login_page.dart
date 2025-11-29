// login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'student_home.dart';
import 'warden_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Student';
  bool _isLoggingIn = false;

  Future<void> _login() async {
    setState(() => _isLoggingIn = true);

    try {
      String email = _identifierController.text.trim();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );

      if (_selectedRole == 'Student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WardenHome()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoggingIn = false);
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 28,
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedRole = value);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Role',
                      labelStyle: const TextStyle(color: primaryBlue),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: primaryBlue, width: 2),
                      ),
                    ),
                    items: ['Student', 'Warden']
                        .map((role) => DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _identifierController,
                    cursorColor: primaryBlue,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: primaryBlue),
                      prefixIcon: const Icon(Icons.email_rounded, color: primaryBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: primaryBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    cursorColor: primaryBlue,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: primaryBlue),
                      prefixIcon: const Icon(Icons.lock_rounded, color: primaryBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: primaryBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _isLoggingIn
                      ? const CircularProgressIndicator(color: primaryBlue)
                      : ElevatedButton(
                    onPressed: _login,
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
                    child: const Text('Login', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'student_home.dart'; // Import the student home page
// import 'warden_home.dart'; // Import the warden home page
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final _identifierController = TextEditingController(); // Email
//   final _passwordController = TextEditingController();
//   String _selectedRole = 'Student'; // default role
//   bool _isLoggingIn = false;
//
//   Future<void> _login() async {
//     setState(() => _isLoggingIn = true);
//
//     try {
//       String email = _identifierController.text.trim(); // Email for both roles
//
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email,
//         password: _passwordController.text.trim(),
//       );
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Login successful')),
//       );
//
//       // Navigate to the correct home page based on the selected role
//       if (_selectedRole == 'Student') {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const StudentHomePage()),
//         );
//       } else {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => WardenHome()),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     } finally {
//       setState(() => _isLoggingIn = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.indigo.shade900,
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Login',
//                 style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 30),
//
//               DropdownButtonFormField<String>(
//                 value: _selectedRole,
//                 onChanged: (value) {
//                   if (value != null) {
//                     setState(() => _selectedRole = value);
//                   }
//                 },
//                 dropdownColor: Colors.indigo.shade900,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: InputDecoration(
//                   labelText: 'Select Role',
//                   labelStyle: const TextStyle(color: Colors.white),
//                   filled: true,
//                   fillColor: Colors.white24,
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//                 items: ['Student', 'Warden']
//                     .map((role) => DropdownMenuItem(
//                   value: role,
//                   child: Text(role),
//                 ))
//                     .toList(),
//               ),
//               const SizedBox(height: 20),
//
//               TextField(
//                 controller: _identifierController,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: InputDecoration(
//                   labelText: 'Email', // Only email is asked for both roles
//                   labelStyle: const TextStyle(color: Colors.white),
//                   filled: true,
//                   fillColor: Colors.white24,
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               TextField(
//                 controller: _passwordController,
//                 obscureText: true,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   labelStyle: const TextStyle(color: Colors.white),
//                   filled: true,
//                   fillColor: Colors.white24,
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//               const SizedBox(height: 30),
//
//               _isLoggingIn
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : ElevatedButton(
//                 onPressed: _login,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: Colors.indigo,
//                   padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
//                 ),
//                 child: const Text('Login'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

