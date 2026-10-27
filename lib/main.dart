import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/selection_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/report_screen.dart';
import 'screens/history_screen.dart';
import 'screens/student_mgmt_screen.dart';
import 'screens/change_password_screen.dart';
import 'models/attendance_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1E3A8A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFF1E3A8A),
          secondary: Colors.teal,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        if (settings.name == '/login') {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        if (settings.name == '/dashboard') {
          return MaterialPageRoute(builder: (_) => const DashboardScreen());
        }
        
if (settings.name == '/selection') {
  final args = settings.arguments as Map<String, dynamic>;
  return MaterialPageRoute(
    builder: (_) => SelectionScreen(
      year: args['year'] as String,
      branch: args['branch'] as String,
    ),
  );
}

        if (settings.name == '/attendance') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => AttendanceScreen(
              year: args['year'] as String,
              branch: args['branch'] as String,
              section: args['section'] as String,
              periods: (args['periods'] as List<String>),
              isMultiple: args['isMultiple'] as bool? ?? false,
              editRecordId: args['editRecordId'] as String?,
            ),
          );
        }
        if (settings.name == '/report') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ReportScreen(
              reportText: args['report'] as String,
              record: args['record'] as AttendanceRecord,
            ),
          );
        }
        if (settings.name == '/history') {
          return MaterialPageRoute(builder: (_) => const HistoryScreen());
        }
        if (settings.name == '/student_mgmt') {
          return MaterialPageRoute(builder: (_) => const StudentMgmtScreen());
        }
        if (settings.name == '/change_password') {
          return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
        }
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      },
    );
  }
}
