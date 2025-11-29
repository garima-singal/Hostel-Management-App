import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WardenRegistrationPage extends StatefulWidget {
  const WardenRegistrationPage({super.key});

  @override
  State<WardenRegistrationPage> createState() => _WardenRegistrationPageState();
}

class _WardenRegistrationPageState extends State<WardenRegistrationPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _isRegistering = false;

  Future<void> _registerWarden() async {
    setState(() => _isRegistering = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Warden registered successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isRegistering = false);
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
                  const Text(
                    'Warden Registration',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildTextField(
                      controller: _emailController,
                      label: 'Official Email',
                      icon: Icons.email_rounded),
                  _buildTextField(
                      controller: _passController,
                      label: 'Password',
                      icon: Icons.lock_rounded,
                      obscure: true),

                  const SizedBox(height: 40),
                  _isRegistering
                      ? const CircularProgressIndicator(color: primaryBlue)
                      : ElevatedButton(
                    onPressed: _registerWarden,
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
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class WardenRegistrationPage extends StatefulWidget {
//   const WardenRegistrationPage({super.key});
//
//   @override
//   State<WardenRegistrationPage> createState() => _WardenRegistrationPageState();
// }
//
// class _WardenRegistrationPageState extends State<WardenRegistrationPage> {
//   final _emailController = TextEditingController();
//   final _passController = TextEditingController();
//   bool _isRegistering = false;
//
//   Future<void> _registerWarden() async {
//     setState(() => _isRegistering = true);
//
//     try {
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passController.text.trim(),
//       );
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Warden registered successfully")),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: ${e.toString()}")),
//       );
//     } finally {
//       setState(() => _isRegistering = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.indigo.shade800,
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Warden Registration',
//                 style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
//               ),
//               const SizedBox(height: 30),
//
//               _buildTextField(controller: _emailController, label: 'Official Email'),
//               _buildTextField(controller: _passController, label: 'Password', obscure: true),
//
//               const SizedBox(height: 30),
//               _isRegistering
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : ElevatedButton(
//                 onPressed: _registerWarden,
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
//   Widget _buildTextField({required TextEditingController controller, required String label, bool obscure = false}) {
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

