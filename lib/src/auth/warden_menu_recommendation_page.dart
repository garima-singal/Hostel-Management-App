import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WardenMenuRecommendationPage extends StatelessWidget {
  const WardenMenuRecommendationPage({super.key});

  final Map<String, List<Map<String, dynamic>>> _sampleMenuDatabase = const {
    'Breakfast': [
      {'name': 'Aloo Paratha', 'pref_score': 90},
      {'name': 'Poha', 'pref_score': 80},
      {'name': 'Bread Butter & Jam', 'pref_score': 65},
      {'name': 'Boiled Eggs', 'pref_score': 75},
      {'name': 'Upma', 'pref_score': 60},
    ],
    'Lunch': [
      {'name': 'Dal Makhani & Roti', 'pref_score': 95},
      {'name': 'Rajma Chawal', 'pref_score': 92},
      {'name': 'Mixed Veg Curry', 'pref_score': 70},
      {'name': 'Chhole Bhature', 'pref_score': 85},
      {'name': 'Aloo Gobhi & Paratha', 'pref_score': 78},
    ],
    'Dinner': [
      {'name': 'Paneer Butter Masala', 'pref_score': 98},
      {'name': 'Curry', 'pref_score': 96},
      {'name': 'Kadi Chawal', 'pref_score': 75},
      {'name': 'Tawa Roti & Simple Dal', 'pref_score': 60},
      {'name': 'Veg Biryani', 'pref_score': 88},
    ],
  };

  // --- Logic to Process Feedback ---
  Future<double> _analyzeFeedbackScore() async {
    final snapshot = await FirebaseFirestore.instance.collection('food_feedback').get();

    List<int> allRatings = [];
    int netSentimentScore = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final rating = data['rating'] as int? ?? 3;

      allRatings.add(rating);

      // Calculate net sentiment from ratings
      if (rating >= 4) {
        netSentimentScore++;
      } else if (rating <= 2) {
        netSentimentScore--;
      }
    }

    if (allRatings.isEmpty) return 50.0; // Default score if no data

    final avgRating = allRatings.reduce((a, b) => a + b) / allRatings.length;
    final totalReviews = allRatings.length;

    // Formula: (Average Rating / 5) + (Net Sentiment / Total Reviews)
    final performanceScore = (avgRating / 5) + (netSentimentScore / totalReviews * 0.5);

    return double.parse((performanceScore * 100).toStringAsFixed(1));
  }
  // --- End Logic ---

  // NEW: Generates the 7-day menu based on the score
  Map<String, Map<String, String>> _generateWeeklyMenu(double overallScore) {
    Map<String, Map<String, String>> weeklyMenu = {};
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    // Determine the type of dishes to suggest based on overall score
    List<Map<String, dynamic>> breakfastPool, lunchPool, dinnerPool;

    if (overallScore >= 70) {
      // High score: Suggest only high-preference dishes (pref_score > 75)
      breakfastPool = _sampleMenuDatabase['Breakfast']!.where((d) => d['pref_score'] > 75).toList();
      lunchPool = _sampleMenuDatabase['Lunch']!.where((d) => d['pref_score'] > 80).toList();
      dinnerPool = _sampleMenuDatabase['Dinner']!.where((d) => d['pref_score'] > 85).toList();
    } else if (overallScore >= 50) {
      // Medium score: Suggest a mix of medium and high dishes
      breakfastPool = _sampleMenuDatabase['Breakfast']!.where((d) => d['pref_score'] > 60).toList();
      lunchPool = _sampleMenuDatabase['Lunch']!.where((d) => d['pref_score'] > 65).toList();
      dinnerPool = _sampleMenuDatabase['Dinner']!.where((d) => d['pref_score'] > 70).toList();
    } else {
      // Low score: Suggest lower-rated dishes and recommend they be replaced
      breakfastPool = _sampleMenuDatabase['Breakfast']!.where((d) => d['pref_score'] < 70).toList();
      lunchPool = _sampleMenuDatabase['Lunch']!.where((d) => d['pref_score'] < 75).toList();
      dinnerPool = _sampleMenuDatabase['Dinner']!.where((d) => d['pref_score'] < 80).toList();
    }

    // Ensure pools have enough items to avoid errors (loop through all dishes if pools are too small)
    final bPool = breakfastPool.isNotEmpty ? breakfastPool : _sampleMenuDatabase['Breakfast']!;
    final lPool = lunchPool.isNotEmpty ? lunchPool : _sampleMenuDatabase['Lunch']!;
    final dPool = dinnerPool.isNotEmpty ? dinnerPool : _sampleMenuDatabase['Dinner']!;

    for (int i = 0; i < 7; i++) {
      weeklyMenu[days[i]] = {
        'Breakfast': bPool[i % bPool.length]['name'] as String,
        'Lunch': lPool[i % lPool.length]['name'] as String,
        'Dinner': dPool[i % dPool.length]['name'] as String,
      };
    }

    return weeklyMenu;
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A237E);
    const background = Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Menu Recommendation'),
        backgroundColor: primaryBlue,
      ),
      body: FutureBuilder<double>(
        future: _analyzeFeedbackScore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryBlue));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error analyzing data: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No feedback data available for analysis.'));
          }

          final score = snapshot.data!;
          final recommendationText = score >= 70 ? "HIGH SUCCESS" : score >= 50 ? "FAIR STABILITY" : "URGENT OVERHAUL";
          final color = score >= 70 ? Colors.green : score >= 50 ? Colors.amber[700]! : Colors.red;
          final weeklyMenu = _generateWeeklyMenu(score);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI-Generated Weekly Menu Plan',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue),
                ),
                const SizedBox(height: 20),

                // Display Overall Performance Score
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Icon(
                      score >= 70 ? Icons.emoji_events_rounded : Icons.warning_rounded,
                      color: color,
                      size: 40,
                    ),
                    title: Text(
                      recommendationText,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                    ),
                    subtitle: const Text('Current Overall Student Satisfaction Score'),
                    trailing: Text(
                      '${score.toStringAsFixed(1)}%',
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Display Menu Table
                const Text(
                  'Recommended 7-Day Menu:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue),
                ),
                const SizedBox(height: 10),
                _buildMenuTable(weeklyMenu, color),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuTable(Map<String, Map<String, String>> menu, Color scoreColor) {
    const primaryBlue = Color(0xFF1A237E);
    final headers = ['Day', 'Breakfast', 'Lunch', 'Dinner'];
    final rows = menu.entries.map((entry) {
      final day = entry.key;
      final meals = entry.value;
      return [day, meals['Breakfast']!, meals['Lunch']!, meals['Dinner']!];
    }).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.all(color: Colors.grey.shade300, width: 1),
        children: [
          // Header Row
          TableRow(
            decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1)),
            children: headers.map((header) => _buildTableCell(header, isHeader: true)).toList(),
          ),
          // Data Rows
          ...rows.map((row) {
            return TableRow(
              children: row.map((cell) => _buildTableCell(cell, isUrgent: scoreColor == Colors.red)).toList(),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, bool isUrgent = false}) {
    Color textColor = Colors.black87;
    if (isHeader) textColor = Colors.black;
    if (isUrgent) textColor = Colors.red.shade800;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 14 : 13,
          color: textColor,
        ),
      ),
    );
  }
}