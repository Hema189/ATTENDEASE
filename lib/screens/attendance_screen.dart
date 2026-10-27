import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/student_model.dart';
import '../services/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  final String year;
  final String branch;
  final String section;
  final List<String> periods;
  final bool isMultiple;
  final String? editRecordId;

  const AttendanceScreen({
    Key? key,
    required this.year,
    required this.branch,
    required this.section,
    required this.periods,
    this.isMultiple = false,
    this.editRecordId,
  }) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = AttendanceService();

  List<Student> _students = [];
  // Key: studentRegNo, Value: isPresent (true = Present, false = Absent)
  final Map<String, bool> _studentStatuses = {};

  String _searchQuery = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Two subtabs: 0 = ABSENTEES (Default!), 1 = PRESENT
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);

    _loadClassStudents();
  }

  void _loadClassStudents() {
    final list = _service.getStudentsForClass(
      year: widget.year,
      branch: widget.branch,
      section: widget.section,
    );

    setState(() {
      _students = list;
      _studentStatuses.clear();

      if (widget.editRecordId != null) {
        // Editing existing saved attendance
        final existingDetails = _service.getAttendanceDetails(widget.editRecordId!);
        for (final d in existingDetails) {
          _studentStatuses[d.studentRegNo] = d.isPresent;
        }
        for (final s in _students) {
          _studentStatuses.putIfAbsent(s.registrationNumber, () => true);
        }
      } else {
        // Default initial state: all students are marked Present, so Absentees list is populated when toggled
        for (final s in _students) {
          _studentStatuses[s.registrationNumber] = true;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleAttendance(String regNo) {
    setState(() {
      final current = _studentStatuses[regNo] ?? true;
      _studentStatuses[regNo] = !current;
    });
  }

  void _markAll(bool isPresent) {
    setState(() {
      for (final s in _students) {
        _studentStatuses[s.registrationNumber] = isPresent;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isPresent ? 'All students marked Present' : 'All students marked Absent')),
    );
  }

  void _showSaveConfirmationDialog() {
    if (_students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No student records available to mark attendance.')),
      );
      return;
    }

    final now = _service.nowKolkata;
    final dateStr = DateFormat('dd MMMM yyyy').format(now);
    final dayStr = DateFormat('EEEE').format(now);

    final presentCount = _students.where((s) => _studentStatuses[s.registrationNumber] == true).length;
    final absentCount = _students.length - presentCount;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Color(0xFF1E3A8A)),
            SizedBox(width: 8),
            Text('Confirm Attendance Save', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please verify the attendance summary before saving:', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  _summaryRow('Date', dateStr),
                  _summaryRow('Day', dayStr),
                  _summaryRow('Class', '${widget.year} ${widget.branch}-${widget.section.replaceAll("Section ", "")}'),
                  _summaryRow('Period(s)', widget.periods.join(', ')),
                  const Divider(),
                  _summaryRow('Total Students', '${_students.length}'),
                  _summaryRow('Present Count', '$presentCount', color: Colors.green),
                  _summaryRow('Absent Count', '$absentCount', color: Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Policy: Once saved, record is shared in history. Faculty can edit only before 6:00 PM IST on attendance date. CR cannot modify saved records.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _saveAttendance();
            },
            child: const Text('Confirm & Save'),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color ?? Colors.black87)),
        ],
      ),
    );
  }

  Future<void> _saveAttendance() async {
    setState(() => _isSaving = true);

    try {
      if (widget.editRecordId != null) {
        // Faculty updating existing attendance before 6 PM
        final updatedRecord = await _service.editSavedAttendance(
          attendanceId: widget.editRecordId!,
          updatedStatuses: _studentStatuses,
          students: _students,
        );
        final details = _service.getAttendanceDetails(updatedRecord.attendanceId);
        final reportText = _service.generateFacultyReport(updatedRecord, details);

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/report', arguments: {'report': reportText, 'record': updatedRecord});
        }
      } else {
        // New attendance save (Single or Multiple periods)
        final savedList = await _service.saveAttendance(
          academicYear: widget.year,
          branch: widget.branch,
          section: widget.section,
          periods: widget.periods,
          studentStatuses: _studentStatuses,
          students: _students,
        );

        if (savedList.isNotEmpty && mounted) {
          final first = savedList.first;
          final details = _service.getAttendanceDetails(first.attendanceId);
          final reportText = _service.generateFacultyReport(first, details);

          Navigator.pushReplacementNamed(context, '/report', arguments: {'report': reportText, 'record': first});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = _students.where((s) => _studentStatuses[s.registrationNumber] == true).length;
    final absentCount = _students.length - presentCount;

    // Filter students by active search and subtab
    final isAbsenteesTab = _tabController.index == 0;
    final filtered = _students.where((s) {
      final matchesSearch = _searchQuery.isEmpty ||
          s.name.contains(_searchQuery.toUpperCase()) ||
          s.registrationNumber.contains(_searchQuery.toUpperCase());
      if (!matchesSearch) return false;

      final isPresent = _studentStatuses[s.registrationNumber] ?? true;
      return isAbsenteesTab ? !isPresent : isPresent;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.editRecordId != null ? 'Edit Attendance' : 'Mark Attendance', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('${widget.year} ${widget.branch}-${widget.section.replaceAll("Section ", "")} • ${widget.periods.join(", ")}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          if (_students.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _showSaveConfirmationDialog,
                icon: const Icon(Icons.save, size: 16),
                label: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Live Clock Header (Asia/Kolkata)
          StreamBuilder<DateTime>(
            stream: _service.timeStream,
            initialData: _service.nowKolkata,
            builder: (context, snapshot) {
              final time = snapshot.data ?? _service.nowKolkata;
              final dayStr = DateFormat('EEEE').format(time);
              final dateStr = DateFormat('dd MMM yyyy').format(time);
              final timeStr = DateFormat('hh:mm:ss a').format(time);

              return Container(
                color: Colors.blue.shade50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$dayStr, $dateStr', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('$timeStr IST', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  ],
                ),
              );
            },
          ),

          // Real-Time Attendance Counts Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _countBadge('TOTAL', '${_students.length}', Colors.grey.shade200, Colors.black87),
                const SizedBox(width: 8),
                _countBadge('PRESENT', '$presentCount', Colors.green.shade50, Colors.green.shade800),
                const SizedBox(width: 8),
                _countBadge('ABSENT', '$absentCount', Colors.red.shade50, Colors.red.shade800),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Search by name or registration number...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Subtabs: ABSENTEES (Default Tab!) and PRESENT
          TabBar(
            controller: _tabController,
            onTap: (_) => setState(() {}),
            labelColor: const Color(0xFF1E3A8A),
            indicatorColor: const Color(0xFF1E3A8A),
            tabs: [
              Tab(text: 'ABSENTEES ($absentCount)'),
              Tab(text: 'PRESENT ($presentCount)'),
            ],
          ),

          // Fast Action Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _tabController.index == 0 ? 'Showing absentees (tap to mark present)' : 'Showing present (tap to mark absent)',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), visualDensity: VisualDensity.compact),
                      onPressed: () => _markAll(true),
                      child: const Text('All Present', style: TextStyle(fontSize: 11)),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), visualDensity: VisualDensity.compact),
                      onPressed: () => _markAll(false),
                      child: const Text('All Absent', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Student List or Empty State
          Expanded(
            child: _students.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.folder_open, size: 54, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          'No student records available for this section.',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        const Text('Data policy: Only 3rd Year IT-C is initially loaded with 64 students.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/student_mgmt'),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Student Record'),
                        ),
                      ],
                    ),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          _tabController.index == 0
                              ? (_searchQuery.isNotEmpty ? 'No absentees match "$_searchQuery"' : 'No Absentees! All students are currently marked Present.')
                              : (_searchQuery.isNotEmpty ? 'No present students match "$_searchQuery"' : 'All students are marked Absent.'),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemBuilder: (context, index) {
                          final student = filtered[index];
                          final isPresent = _studentStatuses[student.registrationNumber] ?? true;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 6),
                            shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(10),
),
                            color: isPresent ? Colors.green.shade50 : Colors.red.shade50,
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white,
                                child: Text('${student.serialNo}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ),
                              title: Text(student.registrationNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text(student.name, style: const TextStyle(fontSize: 12)),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isPresent ? Colors.green : Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () => _toggleAttendance(student.registrationNumber),
                                child: Text(isPresent ? 'PRESENT' : 'ABSENT', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              onTap: () => _toggleAttendance(student.registrationNumber),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _countBadge(String label, String value, Color bg, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }
}
