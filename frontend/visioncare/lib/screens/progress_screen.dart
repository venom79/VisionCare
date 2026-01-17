import 'package:flutter/material.dart';
import '../services/screening_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<Map<String, dynamic>> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = ScreeningService.getProgress();
  }

  String _formatDate(String iso) {
    final dt = DateTime.parse(iso);
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _trendColor(String trend) {
    switch (trend.toUpperCase()) {
      case 'IMPROVING':
        return Colors.green;
      case 'WORSENING':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _deltaText(double delta) {
    if (delta < 0) {
      return 'Cataract probability decreased by '
          '${(delta.abs() * 100).toStringAsFixed(1)}%';
    } else if (delta > 0) {
      return 'Cataract probability increased by '
          '${(delta * 100).toStringAsFixed(1)}%';
    } else {
      return 'No significant change detected';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                'Failed to load progress',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data!;
          final trend = data['trend'] ?? 'UNKNOWN';
          final delta = data['delta'] ?? 0.0;
          final history = data['history'] as List<dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= TREND SUMMARY =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _trendColor(trend).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Trend',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _trendColor(trend),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _deltaText(delta),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ================= HISTORY =================
                Text(
                  'Scan History',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    final prob = item['prob_cataract'];
                    final result = item['result'];
                    final date = item['date'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(Icons.show_chart),
                        title: Text(
                          result,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Cataract Probability: '
                              '${(prob * 100).toStringAsFixed(1)}%',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(date),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
