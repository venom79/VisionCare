import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../services/auth_service.dart';
import '../services/doctor_service.dart';

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
  bool _isDoctor = false;

  static const String _baseUrl = 'https://visioncare.onrender.com';

  @override
  void initState() {
    super.initState();
    _detailFuture =
        HistoryService.getScreeningDetail(widget.screeningId);
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await AuthService.getUserRole();
    if (!mounted) return;
    setState(() {
      _isDoctor = role == 'DOCTOR';
    });
  }

  String _formatDate(String iso) {
    final dt = DateTime.parse(iso);
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showReviewDialog() {
    final decisionController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Review Screening'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: decisionController,
                  decoration: const InputDecoration(
                    labelText: 'Decision',
                    hintText: 'e.g. Cataract Confirmed',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Clinical notes...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final decision = decisionController.text.trim();
                final notes = notesController.text.trim();

                if (decision.isEmpty || notes.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Decision and notes are required'),
                    ),
                  );
                  return;
                }

                final success = await DoctorService.submitReview(
                  screeningId: widget.screeningId,
                  decision: decision,
                  notes: notes,
                );

                if (!mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Review submitted successfully'
                          : 'Failed to submit review',
                    ),
                  ),
                );

                if (success) {
                  setState(() {
                    _detailFuture =
                        HistoryService.getScreeningDetail(
                          widget.screeningId,
                        );
                  });
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
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

          if (snapshot.hasError || !snapshot.hasData) {
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
          final rawImagePath = data['image_url'];

          String? imageUrl;
          if (rawImagePath != null && rawImagePath is String) {
            imageUrl =
                '$_baseUrl/${rawImagePath.replaceAll('\\', '/')}';
                debugPrint('IMAGE URL => $imageUrl');
          }



          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= IMAGE =================
                if (imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Center(
                          child: Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ================= RESULT =================
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

                // ================= DOCTOR ACTION =================
                if (_isDoctor) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showReviewDialog,
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Review Screening'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Color _resultColor(String result) {
    final r = result.toLowerCase();
    if (r.contains('normal')) return Colors.green;
    if (r.contains('possible')) return Colors.orange;
    if (r.contains('cataract')) return Colors.redAccent;
    return Colors.grey;
  }
}
