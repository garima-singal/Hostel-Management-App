import 'package:flutter/material.dart';
import 'login_page.dart';
import 'role_selection_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A237E);
    const background = Color(0xFFF0F4F8);
    const accentGray = Color(0xFFB0BEC5);

    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.apartment_rounded,
                  size: 100, color: primaryBlue),
              const SizedBox(height: 20),
              const Text(
                'Welcome to HostelLink!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Your all-in-one attendance management solution.',
                style: TextStyle(
                  fontSize: 16,
                  color: accentGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: background,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 80, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                child: const Text('Login', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),

              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryBlue, width: 2),
                  foregroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 70, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Register', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'login_page.dart';
// import 'role_selection_page.dart';
//
// class WelcomePage extends StatelessWidget {
//   const WelcomePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.indigo.shade900,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 30.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Welcome !',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 40),
//
//               ElevatedButton(
//                 onPressed: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const LoginPage()),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: Colors.indigo,
//                   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                 ),
//                 child: const Text('Login'),
//               ),
//               const SizedBox(height: 20),
//
//               ElevatedButton(
//                 onPressed: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: Colors.indigo,
//                   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                 ),
//                 child: const Text('Register'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




