
import 'package:flutter/material.dart';
import 'branch_selection_screen.dart';

class ClassSelectionScreen extends StatefulWidget {
  const ClassSelectionScreen({super.key});

  @override
  State<ClassSelectionScreen> createState() =>
      _ClassSelectionScreenState();
}

class _ClassSelectionScreenState extends State<ClassSelectionScreen> {
  String _year = '3rd Year';

  final List<String> _years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Class'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'STEP 1: SELECT ACADEMIC YEAR',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            ..._years.map(
              (year) => RadioListTile<String>(
                title: Text(year),
                value: year,
                groupValue: _year,
                activeColor: const Color(0xFF1E3A8A),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _year = value);
                  }
                },
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BranchSelectionScreen(year: _year),
  ),
);
                },
                child: const Text('Next: Select Branch'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
