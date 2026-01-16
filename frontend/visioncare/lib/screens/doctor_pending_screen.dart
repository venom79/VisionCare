import 'package:flutter/material.dart';
import '../services/doctor_service.dart';
import '../routes/app_routes.dart';

class DoctorPendingScreen extends StatefulWidget {
  const DoctorPendingScreen({super.key});

  @override
  State<DoctorPendingScreen> createState() => _DoctorPendingScreenState();
}

class _DoctorPendingScreenState extends State<DoctorPendingScreen> {
  late Future<List<dynamic>> _pendingFuture;

  @override
  void initState() {
    super.initState();
    _pendingFuture = DoctorService.getPendingReviews();
  }

  String _formatDate(String iso) {
    final dt = DateTime.parse(iso);
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _resultColor(String result) {
    final r = result.toLowerCase();
    if (r.contains('possible')) return Colors.orange;
    if (r.contains('cataract')) return Colors.redAccent;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Reviews'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _pendingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load pending reviews',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final items = snapshot.data!;

          if (items.isEmpty) {
            return const Center(
              child: Text('No pending screenings'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              final result = item['result'] ?? 'Unknown';
              final prob = item['prob_cataract'];
              final level = item['confidence_level'];
              final patient = item['patient_name'];
              final createdAt = item['created_at'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.visibility),
                  title: Text(
                    result,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _resultColor(result),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (patient != null)
                        Text('Patient: $patient'),
                      if (prob != null && level != null)
                        Text(
                          'Cataract Probability: ${(prob * 100).toStringAsFixed(1)}% ($level)',
                        ),
                      if (createdAt != null)
                        Text(
                          'Submitted: ${_formatDate(createdAt)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
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
