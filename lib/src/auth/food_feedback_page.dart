import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodFeedbackPage extends StatefulWidget {
  const FoodFeedbackPage({super.key});

  @override
  State<FoodFeedbackPage> createState() => _FoodFeedbackPageState();
}

class _FoodFeedbackPageState extends State<FoodFeedbackPage> {
  final _feedbackController = TextEditingController();
  int _rating = 0;
  File? _imageFile;
  bool _isSubmitting = false;
  String _selectedPhrase = '';

  final primaryBlue = Color(0xFF1A237E);
  final background = Color(0xFFF0F4F8);

  final Map<String, List<String>> _phrases = {
    'positive': ['It was great!', 'Delicious food', 'Very good', 'Fresh and clean'],
    'neutral': ['It was okay', 'Average quality', 'Needs improvement'],
    'negative': ['Not good at all', 'Very bad', 'The food was cold', 'Not worth it'],
  };

  String _analyzeSentiment() {
    if (_rating >= 4 || _selectedPhrase.contains(_phrases['positive']!.first)) {
      return 'positive';
    } else if (_rating <= 2 || _selectedPhrase.contains(_phrases['negative']!.first)) {
      return 'negative';
    } else {
      return 'neutral';
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0 || (_feedbackController.text.trim().isEmpty && _selectedPhrase.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a rating and a comment.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to submit feedback.')),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      final sentimentLabel = _analyzeSentiment();

      final imageData = _imageFile != null ? _imageFile!.path : null;

      await FirebaseFirestore.instance.collection('food_feedback').add({
        'userId': user.uid,
        'rating': _rating,
        'comment': _feedbackController.text.trim(),
        'photoPath': imageData,
        'sentiment': sentimentLabel,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Feedback'),
        backgroundColor: primaryBlue,
      ),
      backgroundColor: background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Rate Your Meal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 40,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Quickly select a phrase',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  children: _phrases['positive']!.map((phrase) {
                    return ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedPhrase = phrase;
                          _feedbackController.text = phrase;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(phrase),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: _phrases['neutral']!.map((phrase) {
                    return ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedPhrase = phrase;
                          _feedbackController.text = phrase;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(phrase),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  children: _phrases['negative']!.map((phrase) {
                    return ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedPhrase = phrase;
                          _feedbackController.text = phrase;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(phrase),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add your comments here (optional)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _feedbackController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Share your thoughts on the meal...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Add a Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue.withOpacity(0.8),
                    foregroundColor: background,
                  ),
                ),
                if (_imageFile != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Photo Selected: ${_imageFile!.path.split('/').last}',
                    style: TextStyle(color: primaryBlue),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 30),
                _isSubmitting
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A237E)))
                    : ElevatedButton(
                  onPressed: _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                  ),
                  child: const Text('Submit Feedback', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// // lib/food_feedback_page.dart
//
// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
//
// class FoodFeedbackPage extends StatefulWidget {
//   const FoodFeedbackPage({super.key});
//
//   @override
//   State<FoodFeedbackPage> createState() => _FoodFeedbackPageState();
// }
//
// class _FoodFeedbackPageState extends State<FoodFeedbackPage> {
//   final _commentController = TextEditingController();
//   File? _photoFile;
//   double _rating = 0;
//   bool _isSubmitting = false;
//
//   final user = FirebaseAuth.instance.currentUser;
//
//   Future<void> _pickImage() async {
//     final picked = await ImagePicker()
//         .pickImage(source: ImageSource.camera, imageQuality: 50);
//     if (picked != null) {
//       setState(() {
//         _photoFile = File(picked.path);
//       });
//     }
//   }
//
//   Future<void> _submitFeedback() async {
//     if (_rating == 0 || _commentController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text("Please provide a rating and a comment.")));
//       return;
//     }
//
//     setState(() => _isSubmitting = true);
//
//     try {
//       String? base64Image;
//       if (_photoFile != null) {
//         final bytes = await _photoFile!.readAsBytes();
//         base64Image = base64Encode(bytes);
//       }
//
//       await FirebaseFirestore.instance.collection('food_feedback').add({
//         'userId': user!.uid,
//         'rating': _rating,
//         'comment': _commentController.text.trim(),
//         'photoBase64': base64Image,
//         'timestamp': Timestamp.now(),
//         'status': 'unresolved', // For future warden management
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Feedback submitted successfully!")));
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error submitting feedback: $e")));
//     } finally {
//       setState(() => _isSubmitting = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     const primaryBlue = Color(0xFF1A237E);
//     const background = Color(0xFFF0F4F8);
//
//     return Scaffold(
//       backgroundColor: background,
//       appBar: AppBar(
//         title: const Text('Food Feedback'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text(
//               'How was the food today?',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             Center(
//               child: RatingBar.builder(
//                 initialRating: _rating,
//                 minRating: 1,
//                 direction: Axis.horizontal,
//                 allowHalfRating: true,
//                 itemCount: 5,
//                 itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
//                 itemBuilder: (context, _) => const Icon(
//                   Icons.star,
//                   color: primaryBlue,
//                 ),
//                 onRatingUpdate: (rating) {
//                   setState(() {
//                     _rating = rating;
//                   });
//                 },
//               ),
//             ),
//             const SizedBox(height: 30),
//             TextField(
//               controller: _commentController,
//               decoration: InputDecoration(
//                 labelText: 'Your comments',
//                 hintText: 'e.g., "The food was great!" or "The vegetables were undercooked."',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
//                 prefixIcon: const Icon(Icons.comment_rounded),
//               ),
//               maxLines: 4,
//             ),
//             const SizedBox(height: 20),
//             ListTile(
//               leading: const Icon(Icons.camera_alt_rounded),
//               title: const Text('Add Photo (Optional)'),
//               trailing: _photoFile == null
//                   ? const Icon(Icons.add_a_photo)
//                   : const Icon(Icons.check_circle, color: Colors.green),
//               onTap: _pickImage,
//             ),
//             const SizedBox(height: 30),
//             _isSubmitting
//                 ? const Center(child: CircularProgressIndicator(color: primaryBlue))
//                 : ElevatedButton(
//               onPressed: _submitFeedback,
//               child: const Text('Submit Feedback'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }