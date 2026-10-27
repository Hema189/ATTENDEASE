import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = AttendanceService();

  String? _filterYear;
  String? _filterBranch;
  String? _filterSection;
  String? _filterPeriod;

  @override
  Widget build(BuildContext context) {
    final user = _service.currentUser;
    final records = _service.getSharedHistory(
      year: _filterYear,
      branch: _filterBranch,
      section: _filterSection,
      period: _filterPeriod,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Attendance History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Shared History Explanation Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.blue.shade50,
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Color(0xFF1E3A8A)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Shared History: Records taken by either Faculty or CR are saved and visible to both. 7-day retention policy (no manual delete).',
                    style: TextStyle(fontSize: 11.5, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

          // Filters Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filters:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                if (_filterYear != null || _filterBranch != null || _filterSection != null || _filterPeriod != null)
                  TextButton(
                    onPressed: () => setState(() {
                      _filterYear = null;
                      _filterBranch = null;
                      _filterSection = null;
                      _filterPeriod = null;
                    }),
                    child: const Text('Clear Filters', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: Text(_filterYear ?? 'Year'),
                  selected: _filterYear != null,
                  onSelected: (val) => setState(() => _filterYear = val ? '3rd Year' : null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(_filterBranch ?? 'Branch'),
                  selected: _filterBranch != null,
                  onSelected: (val) => setState(() => _filterBranch = val ? 'IT' : null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(_filterSection ?? 'Section'),
                  selected: _filterSection != null,
                  onSelected: (val) => setState(() => _filterSection = val ? 'Section C' : null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(_filterPeriod ?? 'Period'),
                  selected: _filterPeriod != null,
                  onSelected: (val) => setState(() => _filterPeriod = val ? 'Period 1' : null),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Records List
          Expanded(
            child: records.isEmpty
                ? const Center(
                    child: Text('No attendance records found in shared history.', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: records.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final canEdit = (user?.role == UserRole.faculty || user?.role == UserRole.admin) && record.canFacultyEdit;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(14),
),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${record.dateFormatted} (${record.dayOfWeek})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Chip(
                                    label: Text(record.period, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                    backgroundColor: const Color(0xFF1E3A8A),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Class: ${record.academicYear} ${record.branch}-${record.section.replaceAll("Section ", "")}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              Text(
                                'Recorded: ${record.timeFormatted} by ${record.createdByRole} (${record.createdByRegNo})',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              const SizedBox(height: 10),

                              // Counts Row
                              Row(
                                children: [
                                  _countTag('Total: ${record.totalStudents}', Colors.grey.shade100, Colors.black87),
                                  const SizedBox(width: 8),
                                  _countTag('Present: ${record.presentCount}', Colors.green.shade50, Colors.green.shade800),
                                  const SizedBox(width: 8),
                                  _countTag('Absent: ${record.absentCount}', Colors.red.shade50, Colors.red.shade800),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Edit permission vs Read-only state
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (canEdit)
                                    const Row(
                                      children: [
                                        Icon(Icons.edit, size: 14, color: Colors.teal),
                                        SizedBox(width: 4),
                                        Text('Editable before 6:00 PM IST', style: TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold)),
                                      ],
                                    )
                                  else
                                    const Row(
                                      children: [
                                        Icon(Icons.lock, size: 14, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text('Read-Only Locked', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),

                                  Row(
                                    children: [
                                      if (canEdit)
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                                          onPressed: () {
                                            Navigator.pushNamed(context, '/attendance', arguments: {
                                              'year': record.academicYear,
                                              'branch': record.branch,
                                              'section': record.section,
                                              'periods': [record.period],
                                              'isMultiple': false,
                                              'editRecordId': record.attendanceId,
                                            });
                                          },
                                          child: const Text('Edit'),
                                        ),
                                      const SizedBox(width: 6),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1E3A8A),
                                          foregroundColor: Colors.white,
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        onPressed: () => _openRecordDetails(record),
                                        child: const Text('View Report'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openRecordDetails(AttendanceRecord record) {
    final details = _service.getAttendanceDetails(record.attendanceId);
    final reportText = _service.generateFacultyReport(record, details);

    Navigator.pushNamed(context, '/report', arguments: {
      'report': reportText,
      'record': record,
    });
  }

  Widget _countTag(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
