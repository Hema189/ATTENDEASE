
import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import 'selection_screen.dart';

class BranchSelectionScreen extends StatefulWidget {
  final String year;

  const BranchSelectionScreen({
    super.key,
    required this.year,
  });

  @override
  State<BranchSelectionScreen> createState() =>
      _BranchSelectionScreenState();
}

class _BranchSelectionScreenState
    extends State<BranchSelectionScreen> {
  final AttendanceService _service = AttendanceService();
  String? _selectedBranch;

  @override
  void initState() {
    super.initState();
    final branches = _service.getBranches();

    if (branches.isNotEmpty) {
      _selectedBranch = branches.first;
    } else {
      _selectedBranch = 'IT';
    }
  }

  @override
  Widget build(BuildContext context) {
    final branches = _service.getBranches();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.year} - Select Branch'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'STEP 2: SELECT BRANCH',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            if (branches.isEmpty)
              const Text('No branches available.')
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: branches.map((branch) {
                  final selected = _selectedBranch == branch;

                  return ChoiceChip(
                    label: Text(branch),
                    selected: selected,
                    selectedColor: const Color(0xFF1E3A8A),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (value) {
                      if (value) {
                        setState(() => _selectedBranch = branch);
                      }
                    },
                  );
                }).toList(),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedBranch == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                           builder: (_) => SelectionScreen(
  year: widget.year,
  branch: _selectedBranch!,
),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Next: Select Section & Period'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
