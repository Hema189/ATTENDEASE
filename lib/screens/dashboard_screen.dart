import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../services/attendance_service.dart';
import 'class_selection_screen.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = AttendanceService();
    final user = service.currentUser;

    final academicYears = ["1st Year", "2nd Year", "3rd Year", "4th Year"];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Campus Attendance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              '${user?.role.name.toUpperCase()} • ${user?.registrationNumber}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          // Shared Attendance History Action
          IconButton(
            tooltip: 'Shared Attendance History',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
          // Student Management for CR (I1 & F7) and Admin
          if (user?.role == UserRole.cr || user?.role == UserRole.admin)
            IconButton(
              tooltip: 'Manage Students',
              icon: const Icon(Icons.people),
              onPressed: () => Navigator.pushNamed(context, '/student_mgmt'),
            ),
          IconButton(
            tooltip: 'Change Password',
            icon: const Icon(Icons.lock_reset),
            onPressed: () => Navigator.pushNamed(context, '/change_password'),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              service.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Date & Day Header Card
            StreamBuilder<DateTime>(
              stream: service.timeStream,
              initialData: service.nowKolkata,
              builder: (context, snapshot) {
                final time = snapshot.data ?? service.nowKolkata;
                final dayStr = DateFormat('EEEE').format(time);
                final dateStr = DateFormat('dd MMMM yyyy').format(time);
                final timeStr = DateFormat('hh:mm:ss a').format(time);

                return Card(
                  color: Colors.blue.shade50,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(16),
),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF1E3A8A)),
                                const SizedBox(width: 6),
                                Text('$dayStr, $dateStr', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('$timeStr (Asia/Kolkata)', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                          ],
                        ),
                        Chip(
                          label: Text(
                            user?.role.name.toUpperCase() ?? 'USER',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                          ),
                          backgroundColor: const Color(0xFF1E3A8A),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'STEP 1: SELECT ACADEMIC YEAR',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E3A8A), letterSpacing: 1.2),
            ),
            const Text(
              'Choose academic year to proceed with attendance marking',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),

            ...academicYears.map((year) {
              final is3rdYear = year == "3rd Year";
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(14),
),
                color: is3rdYear ? Colors.teal.shade50 : Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: is3rdYear ? Colors.teal : Colors.blue.shade100,
                    child: Icon(Icons.school, color: is3rdYear ? Colors.white : const Color(0xFF1E3A8A)),
                  ),
                  title: Text(year, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(
                    is3rdYear ? 'Includes 3rd Year IT-C dataset (Active)' : 'Standard Academic Batch',
                    style: TextStyle(color: is3rdYear ? Colors.teal.shade800 : Colors.grey),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF1E3A8A)),
                  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ClassSelectionScreen(),
    ),
  );
},
                ),
              );
            }).toList(),

            const SizedBox(height: 16),

            // Shared History Quick Access Banner
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(14),
),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE0F2FE),
                  child: Icon(Icons.history, color: Color(0xFF0369A1)),
                ),
                title: const Text('Shared Attendance History', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Accessible to both Faculty and Students/CR. Past 7 days.'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => Navigator.pushNamed(context, '/history'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
