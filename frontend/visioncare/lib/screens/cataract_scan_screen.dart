import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/screening_service.dart';


class CataractScanScreen extends StatefulWidget {
  const CataractScanScreen({super.key});

  @override
  State<CataractScanScreen> createState() => _CataractScanScreenState();
}

class _CataractScanScreenState extends State<CataractScanScreen> {
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  final ImagePicker _picker = ImagePicker();

  // ================= PICK SOURCE =================
  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= IMAGE PICKER =================
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _result = null;
      });
    }
  }

  // ================= ANALYZE (DUMMY) =================
  Future<void> _analyzeImage() async {
    if (_selectedImageBytes == null) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final result = await ScreeningService.createScreening(
        imageBytes: _selectedImageBytes!,
      );

      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Screening is taking longer than expected. Please try again in a moment.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cataract Scan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= IMAGE INPUT =================
            GestureDetector(
              onTap: _showImageSourcePicker,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey),
                ),
                child: _selectedImageBytes == null
                    ? const Center(
                        child: Text(
                          'Tap to capture or upload eye image',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          _selectedImageBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // ================= ANALYZE BUTTON =================
            ElevatedButton(
              onPressed:
                  _selectedImageBytes == null || _isLoading ? null : _analyzeImage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Analyze'),
            ),

            const SizedBox(height: 30),

            // ================= RESULT =================
            if (_result != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }

  // ================= RESULT CARD =================
  Widget _buildResultCard() {
    final decision = _result?['decision'];
    final referral = _result?['referral'];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Screening Result',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // ================= DECISION =================
            if (decision != null) ...[
              Text(
                decision['result'] ?? 'Result unavailable',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 8),
              if (decision['confidence_score'] != null)
                Text(
                  'Confidence: ${(decision['confidence_score'] * 100).toStringAsFixed(1)}%',
                ),
              const SizedBox(height: 12),
              Text(
                decision['message'] ?? 'No additional message',
              ),
            ] else ...[
              const Text(
                'Screening is still being processed.',
                style: TextStyle(color: Colors.orange),
              ),
            ],

            const Divider(height: 30),

            // ================= REFERRAL =================
            if (referral != null) ...[
              Text(
                'Referral: ${referral['specialty'] ?? 'N/A'}'
                ' (${referral['urgency'] ?? 'N/A'})',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ] else ...[
              const Text(
                'Referral information not available yet.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

}
