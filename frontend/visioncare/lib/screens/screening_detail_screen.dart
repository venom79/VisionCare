import 'package:flutter/material.dart';
import '../services/history_service.dart';

class ScreeningDetailScreen extends StatefulWidget {
  final String screeningId;

  const ScreeningDetailScreen({
    super.key,
    required this.screeningId,
  });

  @override
  State<ScreeningDetailScreen> createState() => _ScreeningDetailScreenState();
}

class _ScreeningDetailScreenState extends State<ScreeningDetailScreen> {
  late Future<Map<String, dynamic>> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture =
        HistoryService.getScreeningDetail(widget.screeningId);
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
        title: const Text('Screening Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load screening details',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data!;
          final decision = data['decision'];
          final referral = data['referral'];
          final doctorReview = data['doctor_review'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= BASIC INFO =================
                Text(
                  'Result',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  decision?['result'] ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _resultColor(decision?['result'] ?? ''),
                  ),
                ),
                
                const SizedBox(height: 10),

                Text(
                  'Confidence: ${(decision['confidence_score'] * 100).toStringAsFixed(1)}%'
                  ' (${decision['confidence_level']})',
                ),

                const SizedBox(height: 12),

                Text(decision['message'] ?? ''),

                const Divider(height: 30),

                // ================= PROBABILITIES =================
                Text(
                  'Probabilities',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Normal: ${(data['prob_normal'] * 100).toStringAsFixed(1)}%',
                ),
                Text(
                  'Cataract: ${(data['prob_cataract'] * 100).toStringAsFixed(1)}%',
                ),

                const Divider(height: 30),

                // ================= REFERRAL =================
                if (referral != null) ...[
                  Text(
                    'Referral',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text('Specialty: ${referral['specialty']}'),
                  Text('Urgency: ${referral['urgency']}'),
                  Text('Reason: ${referral['reason']}'),
                  const Divider(height: 30),
                ],

                // ================= DOCTOR REVIEW =================
                if (doctorReview != null) ...[
                  Text(
                    'Doctor Review',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text('Decision: ${doctorReview['decision']}'),
                  const SizedBox(height: 6),
                  Text('Notes: ${doctorReview['notes']}'),
                  const SizedBox(height: 6),
                  Text(
                    'Reviewed at: ${_formatDate(doctorReview['reviewed_at'])}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Divider(height: 30),
                ],

                // ================= META =================
                Text(
                  'Status: ${data['status']}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  'Created at: ${_formatDate(data['created_at'])}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _resultColor(String result) {
    final r = result.toLowerCase();

    if (r.contains('normal')) {
      return Colors.green;
    }

    if (r.contains('possible')) {
      return Colors.orange;
    }

    if (r.contains('cataract')) {
      return Colors.redAccent;
    }

    return Colors.grey;
  }

}
