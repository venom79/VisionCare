import 'package:flutter/material.dart';
import '../services/doctor_service.dart';
import '../routes/app_routes.dart';

class DoctorReviewedScreen extends StatefulWidget {
  const DoctorReviewedScreen({super.key});

  @override
  State<DoctorReviewedScreen> createState() => _DoctorReviewedScreenState();
}

class _DoctorReviewedScreenState extends State<DoctorReviewedScreen> {
  late Future<List<dynamic>> _reviewedFuture;

  @override
  void initState() {
    super.initState();
    _reviewedFuture = DoctorService.getReviewedCases();
  }

  String _formatDate(String iso) {
    final dt = DateTime.parse(iso);
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviewed Cases'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _reviewedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                'Failed to load reviewed cases',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final cases = snapshot.data!;

          if (cases.isEmpty) {
            return const Center(
              child: Text('No reviewed cases yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final item = cases[index];

              final doctorDecision =
                  item['doctor_decision'] ?? '—';
              final originalResult =
                  item['original_result'] ?? '—';
              final confidenceLevel =
                  item['confidence_level'] ?? '—';
              final reviewedAt =
                  item['reviewed_at'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(
                    Icons.verified,
                    color: Colors.blue,
                  ),
                  title: Text(
                    doctorDecision,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('AI Result: $originalResult'),
                      Text('Confidence: $confidenceLevel'),
                      if (reviewedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Reviewed at: ${_formatDate(reviewedAt)}',
                          style: const TextStyle(fontSize: 12),
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
