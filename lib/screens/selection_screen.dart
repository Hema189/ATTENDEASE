import 'package:flutter/material.dart';
import '../services/attendance_service.dart';

class SelectionScreen extends StatefulWidget {
  final String year;
  final String branch;

  const SelectionScreen({
    Key? key,
    required this.year,
    required this.branch,
  }) : super(key: key);

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  final _service = AttendanceService();

  String? _selectedBranch;
  String? _selectedSection;

  bool _isMultiplePeriodMode = false; // False = Single Period, True = Multiple Periods
  final Set<String> _selectedPeriods = {"Period 1"};

  final List<String> _sections = ["Section A", "Section B", "Section C"];
  final List<String> _allPeriods = [
    "Period 1",
    "Period 2",
    "Period 3",
    "Period 4",
    "Period 5",
    "Period 6",
    "Period 7"
  ];

  @override
  void initState() {
    super.initState();
    final branches = _service.getBranches();
    _selectedBranch = branches.isNotEmpty ? branches.first : 'IT';
    _selectedSection = "Section C";
  }

  void _togglePeriod(String period) {
    setState(() {
      if (!_isMultiplePeriodMode) {
        _selectedPeriods.clear();
        _selectedPeriods.add(period);
      } else {
        if (_selectedPeriods.contains(period)) {
          if (_selectedPeriods.length > 2) {
            _selectedPeriods.remove(period);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Multiple Periods mode requires at least two periods.')),
            );
          }
        } else {
          _selectedPeriods.add(period);
        }
      }
    });
  }

  void _onModeChanged(bool multiple) {
    setState(() {
      _isMultiplePeriodMode = multiple;
      if (!multiple) {
        final first = _selectedPeriods.isNotEmpty ? _selectedPeriods.first : "Period 1";
        _selectedPeriods.clear();
        _selectedPeriods.add(first);
      } else {
        if (_selectedPeriods.length < 2) {
          _selectedPeriods.addAll({"Period 1", "Period 2"});
        }
      }
    });
  }

  void _proceedToAttendance() {
    if (_isMultiplePeriodMode && _selectedPeriods.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 2 periods in Multiple Periods mode.')),
      );
      return;
    }

    Navigator.pushNamed(context, '/attendance', arguments: {
      'year': widget.year,
      'branch': _selectedBranch!,
      'section': _selectedSection!,
      'periods': _selectedPeriods.toList()..sort(),
      'isMultiple': _isMultiplePeriodMode,
    });
  }

  @override
  Widget build(BuildContext context) {
    final branches = _service.getBranches();

    return Scaffold(
     
appBar: AppBar(
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Select Branch, Section & Period',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      Text(
        '${widget.year} Academic Year',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white70,
        ),
      ),
    ],
  ),
  backgroundColor: const Color(0xFF1E3A8A),
  foregroundColor: Colors.white,
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STEP 2: Branch Selection
            const Text(
              'STEP 2: SELECT BRANCH',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A), letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: branches.map((branch) {
                final isSelected = _selectedBranch == branch;
                return ChoiceChip(
                  label: Text(branch, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  selected: isSelected,
                  selectedColor: const Color(0xFF1E3A8A),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedBranch = branch);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // STEP 3: Section Selection
            const Text(
              'STEP 1: SELECT SECTION',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A), letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Row(
              children: _sections.map((section) {
                final isSelected = _selectedSection == section;
                final isPopulated = widget.year == "3rd Year" && _selectedBranch == "IT" && section == "Section C";

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          section.replaceAll('Section ', 'Sec '),
                          style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: isPopulated ? Colors.teal : const Color(0xFF1E3A8A),
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedSection = section);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // STEP 4: Period Mode
            const Text(
              'STEP 2: SELECT PERIOD MODE',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A), letterSpacing: 1.2),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _onModeChanged(false),
                    child: Card(
                      
color: _isMultiplePeriodMode ? Colors.blue.shade50 : Colors.white,
shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12),
  side: BorderSide(
    color: _isMultiplePeriodMode
        ? const Color(0xFF1E3A8A)
        : Colors.grey.shade300,
    width: 2,
  ),
),

                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Icon(Icons.looks_one, color: Color(0xFF1E3A8A)),
                            SizedBox(height: 4),
                            Text('Single Period', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Exactly 1 period', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _onModeChanged(true),
                    child: Card(
                  
color: !_isMultiplePeriodMode ? Colors.blue.shade50 : Colors.white,
shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12),
  side: BorderSide(
    color: !_isMultiplePeriodMode
        ? const Color(0xFF1E3A8A)
        : Colors.grey.shade300,
    width: 2,
  ),
),

                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Icon(Icons.filter_2, color: Color(0xFF1E3A8A)),
                            SizedBox(height: 4),
                            Text('Multiple Periods', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('At least 2 periods', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // STEP 5: Periods Selection
            Text(
              !_isMultiplePeriodMode ? 'SELECT 1 PERIOD:' : 'SELECT PERIODS (${_selectedPeriods.length} selected, min 2):',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allPeriods.map((period) {
                final isSelected = _selectedPeriods.contains(period);
                return FilterChip(
                  label: Text(period),
                  selected: isSelected,
                  selectedColor: Colors.teal.shade100,
                  checkmarkColor: Colors.teal,
                  onSelected: (_) => _togglePeriod(period),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Action Button
            ElevatedButton(
              onPressed: _proceedToAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12),
),
              ),
              child: const Text('Proceed to Attendance Sheet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
