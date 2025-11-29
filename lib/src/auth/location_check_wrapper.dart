import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'student_home.dart'; // Your student home page

class LocationCheckWrapper extends StatefulWidget {
  const LocationCheckWrapper({super.key});

  @override
  State<LocationCheckWrapper> createState() => _LocationCheckWrapperState();
}

class _LocationCheckWrapperState extends State<LocationCheckWrapper> {
  bool _locationGranted = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      _showPermissionDialog();
    } else {
      setState(() {
        _locationGranted = true;
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Location Required"),
        content: const Text("Location permission is needed to use this app."),
        actions: [
          TextButton(
            child: const Text("Exit"),
            onPressed: () => Navigator.of(context).popUntil((_) => false),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _locationGranted ? const StudentHomePage() : const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
