import 'package:flutter/material.dart';
import '../services/metrics_service.dart';

class DoctorMetricsScreen extends StatefulWidget {
  const DoctorMetricsScreen({super.key});

  @override
  State<DoctorMetricsScreen> createState() => _DoctorMetricsScreenState();
}

class _DoctorMetricsScreenState extends State<DoctorMetricsScreen> {
  late Future<Map<String, dynamic>> _metricsFuture;

  @override
  void initState() {
    super.initState();
    _metricsFuture = MetricsService.getOverview();
  }

  Widget _metricCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Overview'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _metricsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text(
                'Failed to load metrics',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _metricCard(
                  title: 'Total Screenings',
                  value: data['total_screenings'],
                  icon: Icons.remove_red_eye,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),

                _metricCard(
                  title: 'Cataract Detected',
                  value: data['cataract_detected'],
                  icon: Icons.warning_amber,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 12),

                _metricCard(
                  title: 'Referrals Generated',
                  value: data['referrals_generated'],
                  icon: Icons.local_hospital,
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),

                _metricCard(
                  title: 'Doctor Reviewed',
                  value: data['doctor_reviewed'],
                  icon: Icons.verified,
                  color: Colors.green,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
