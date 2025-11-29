import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'welcome_page.dart';

class PermissionGate extends StatefulWidget {
  const PermissionGate({super.key});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final statusLocation = await Permission.location.request();
    final statusCamera = await Permission.camera.request();

    if (statusLocation.isGranted && statusCamera.isGranted) {
      // Navigate to WelcomePage after permissions granted
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
    } else {
      setState(() {
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Permissions are required to proceed.",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPermissions,
              child: const Text("Grant Permissions"),
            ),
          ],
        ),
      ),
    );
  }
}

