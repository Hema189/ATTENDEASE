import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/attendance_service.dart';

class StudentMgmtScreen extends StatefulWidget {
  const StudentMgmtScreen({Key? key}) : super(key: key);

  @override
  State<StudentMgmtScreen> createState() => _StudentMgmtScreenState();
}

class _StudentMgmtScreenState extends State<StudentMgmtScreen> {
  final _service = AttendanceService();

  String _selectedYear = "3rd Year";
  String _selectedBranch = "IT";
  String _selectedSection = "Section C";

  String _searchQuery = '';

  void _showAddStudentDialog() {
    final regNoController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Student ($_selectedYear $_selectedBranch $_selectedSection)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: regNoController,
              decoration: const InputDecoration(labelText: 'Registration Number', hintText: 'e.g. 24B01A12K1'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Student Name', hintText: 'e.g. VENKAT REDDY'),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (regNoController.text.trim().isEmpty || nameController.text.trim().isEmpty) return;
              try {
                await _service.addStudent(
                  regNo: regNoController.text.trim(),
                  name: nameController.text.trim(),
                  year: _selectedYear,
                  branch: _selectedBranch,
                  section: _selectedSection,
                );
                if (mounted) {
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Student added successfully.')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                );
              }
            },
            child: const Text('Add Student'),
          ),
        ],
      ),
    );
  }

  void _showEditStudentDialog(Student student) {
    final nameController = TextEditingController(text: student.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Student (${student.registrationNumber})'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Student Full Name'),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              await _service.editStudent(student: student, newName: nameController.text.trim());
              if (mounted) {
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Student name updated.')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStudent(Student student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${student.name} (${student.registrationNumber}) from master records? (Past attendance history remains intact).'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await _service.deleteStudent(student: student);
              if (mounted) {
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted student ${student.name}')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final students = _service.getStudentsForClass(
      year: _selectedYear,
      branch: _selectedBranch,
      section: _selectedSection,
    );

    final filtered = students.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.name.contains(_searchQuery.toUpperCase()) || s.registrationNumber.contains(_searchQuery.toUpperCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management (CR/Admin)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _showAddStudentDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Class Filters
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12),
),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedYear,
                        items: ["1st Year", "2nd Year", "3rd Year", "4th Year"]
                            .map((y) => DropdownMenuItem(value: y, child: Text(y, style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedYear = val!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedBranch,
                        items: _service.getBranches()
                            .map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedBranch = val!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedSection,
                        items: ["Section A", "Section B", "Section C"]
                            .map((s) => DropdownMenuItem(value: s, child: Text(s.replaceAll("Section ", "Sec "), style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedSection = val!),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Search student name or reg number...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Students: ${filtered.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                TextButton.icon(
                  onPressed: _showAddStudentDialog,
                  icon: const Icon(Icons.person_add, size: 16),
                  label: const Text('Add Student', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text('No student records available for $_selectedYear $_selectedBranch $_selectedSection.', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _showAddStudentDialog, child: const Text('Add Student')),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemBuilder: (context, index) {
                      final student = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(10),
),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue.shade100,
                            child: Text('${student.serialNo}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                          ),
                          title: Text(student.registrationNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(student.name, style: const TextStyle(fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                onPressed: () => _showEditStudentDialog(student),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                onPressed: () => _confirmDeleteStudent(student),
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
}
