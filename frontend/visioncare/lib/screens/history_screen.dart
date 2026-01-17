import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../routes/app_routes.dart';
  

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = HistoryService.getMyScreenings();
  }

  String _formatDate(String iso) {
    final dt = DateTime.parse(iso);
    return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _resultColor(String result) {
    if (result.toLowerCase().contains('cataract')) {
      return Colors.redAccent;
    }
    return Colors.green;
  }

  bool _isDoctorReviewed(dynamic item) {
    final status = item['status'];
    return status != null && status == 'REVIEWED';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load history',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final history = snapshot.data!;

          if (history.isEmpty) {
            return const Center(
              child: Text('No screenings yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];

              final result = item['result'] ?? 'Unknown';
              final confidence = item['confidence_score'];
              final confidenceLevel = item['confidence_level'] ?? 'N/A';
              final createdAt = item['created_at'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.visibility),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          result,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _resultColor(result),
                          ),
                        ),
                      ),
                      if (_isDoctorReviewed(item))
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 20,
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (confidence != null)
                        Text(
                          'Confidence: ${(confidence * 100).toStringAsFixed(1)}% ($confidenceLevel)',
                        ),
                      const SizedBox(height: 4),
                      if (createdAt != null)
                        Text(
                          'Date: ${_formatDate(createdAt)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (_isDoctorReviewed(item)) ...[
                        const SizedBox(height: 4),
                        const Text(
                          'Doctor reviewed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.screeningDetail,
                      arguments: item['screening_id'],
                    );
                  },
                ),

              );
            },
          );
        },
      ),
    );
  }
}
