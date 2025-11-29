import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class WardenFeedbackDashboard extends StatelessWidget {
  const WardenFeedbackDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A237E);
    const background = Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Feedback Dashboard'),
        backgroundColor: primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feedback Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('food_feedback')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: primaryBlue));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No feedback submitted yet.'));
                }

                final feedbackDocs = snapshot.data!.docs;

                // Process data for the chart
                int positiveCount = 0;
                int negativeCount = 0;
                int neutralCount = 0;

                for (var doc in feedbackDocs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final sentiment = data['sentiment'] as String;
                  if (sentiment == 'positive') {
                    positiveCount++;
                  } else if (sentiment == 'negative') {
                    negativeCount++;
                  } else {
                    neutralCount++;
                  }
                }

                final double totalCount = (positiveCount + negativeCount + neutralCount).toDouble();

                return Column(
                  children: [
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 200,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        color: Colors.green,
                                        value: positiveCount.toDouble(),
                                        title: positiveCount > 0 ? '${(positiveCount / totalCount * 100).toStringAsFixed(0)}%' : '',
                                        radius: 50,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.red,
                                        value: negativeCount.toDouble(),
                                        title: negativeCount > 0 ? '${(negativeCount / totalCount * 100).toStringAsFixed(0)}%' : '',
                                        radius: 50,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.grey,
                                        value: neutralCount.toDouble(),
                                        title: neutralCount > 0 ? '${(neutralCount / totalCount * 100).toStringAsFixed(0)}%' : '',
                                        radius: 50,
                                      ),
                                    ],
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLegend(Colors.green, 'Positive ($positiveCount)'),
                                const SizedBox(height: 8),
                                _buildLegend(Colors.red, 'Negative ($negativeCount)'),
                                const SizedBox(height: 8),
                                _buildLegend(Colors.grey, 'Neutral ($neutralCount)'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Recent Feedback',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: feedbackDocs.length,
                      itemBuilder: (context, index) {
                        final doc = feedbackDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final rating = data['rating'] as int;
                        final comment = data['comment'] as String;
                        final sentiment = data['sentiment'] as String;

                        IconData sentimentIcon;
                        Color sentimentColor;
                        if (sentiment == 'positive') {
                          sentimentIcon = Icons.sentiment_very_satisfied_rounded;
                          sentimentColor = Colors.green;
                        } else if (sentiment == 'negative') {
                          sentimentIcon = Icons.sentiment_very_dissatisfied_rounded;
                          sentimentColor = Colors.red;
                        } else {
                          sentimentIcon = Icons.sentiment_neutral_rounded;
                          sentimentColor = Colors.grey;
                        }

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Icon(sentimentIcon, color: sentimentColor),
                            title: Text(
                              'Rating: $rating stars',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: primaryBlue),
                            ),
                            subtitle: Text(
                              comment,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}