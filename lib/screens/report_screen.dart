import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/attendance_model.dart';

class ReportScreen extends StatelessWidget {
  final String reportText;
  final AttendanceRecord record;

  const ReportScreen({
    Key? key,
    required this.reportText,
    required this.record,
  }) : super(key: key);

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: reportText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance report copied to clipboard.')),
    );
  }

  void _forwardReport() {
    Share.share(reportText, subject: 'Faculty Attendance Report - ${record.academicYear} ${record.branch}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Attendance Report', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Return to Dashboard',
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (r) => false),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Confirmation Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.teal, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Attendance Saved to Shared History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Authoritative server timestamp. Both Faculty and Students can see this record.', style: TextStyle(fontSize: 11, color: Colors.black87)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Read-Only Badge
            const Row(
              children: [
                Icon(Icons.lock, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('Official Attendance Message (Read-Only)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),

            // Strictly Read-Only Formatted Report Box
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(16),
),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  reportText,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13.5,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions: Copy & Forward (WhatsApp)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12),
),
                    ),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy Report', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _copyToClipboard(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                     shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12),
),
                    ),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Forward', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _forwardReport,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12),
),
              ),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (r) => false),
              child: const Text('Return to Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
