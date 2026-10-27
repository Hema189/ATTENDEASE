import 'dart:async';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;

  AttendanceService._internal() {
    _initializeData();
  }

  // Current logged in user
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Live Kolkata Time Stream
  final _timeController = StreamController<DateTime>.broadcast();
  Stream<DateTime> get timeStream => _timeController.stream;
  Timer? _clockTimer;

  // Master Lists
  final List<User> _users = [];
  final List<Student> _students = [];
  final List<String> _branches = ["IT", "CSE", "ECE", "EEE", "ME", "CIVIL"];

  // Shared History: both Faculty and Students/CR access the exact same records list!
  final List<AttendanceRecord> _sharedAttendanceRecords = [];
  final Map<String, List<AttendanceDetail>> _sharedAttendanceDetails = {};

  DateTime get nowKolkata => DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));

  void _initializeData() {
    // Start continuous live Kolkata clock
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _timeController.add(nowKolkata);
    });

    // Seed Users: Admin, Faculty, and the ONLY authorized CRs (I1 and F7)
    _users.addAll([
      User(
        userId: 'admin_01',
        registrationNumber: 'ADMIN',
        name: 'Campus Administrator',
        passwordHash: User.hashPassword('Admin@123'),
        role: UserRole.admin,
      ),
      User(
        userId: 'faculty_01',
        registrationNumber: 'FAC001',
        name: 'Dr. K. Ramesh (IT Dept)',
        passwordHash: User.hashPassword('Faculty@123'),
        role: UserRole.faculty,
        branch: 'IT',
      ),
      // CR 1: I1
      User(
        userId: 'cr_i1',
        registrationNumber: '24B01A12I1',
        name: 'VADAPARTHI HEMA LATHA (CR - I1)',
        passwordHash: User.hashPassword('Cr@123'),
        role: UserRole.cr,
        academicYear: '3rd Year',
        branch: 'IT',
        section: 'Section C',
      ),
      // CR 2: F7
      User(
        userId: 'cr_f7',
        registrationNumber: '24B01A12F7',
        name: 'SEELAM LOHITHA RANI (CR - F7)',
        passwordHash: User.hashPassword('Cr@123'),
        role: UserRole.cr,
        academicYear: '3rd Year',
        branch: 'IT',
        section: 'Section C',
      ),
    ]);

    // Seed ONLY 3rd Year IT-C students (Strict initial requirement: 64 students)
    _students.addAll(Student.initial3rdYearITC);

    // Automatic 7-day retention cleanup
    purgeExpiredRecords();
  }

  void purgeExpiredRecords() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _sharedAttendanceRecords.removeWhere((r) => r.isExpired);
  }

  // --- Authentication ---
  Future<User> login({
    required String regNo,
    required String password,
    required UserRole expectedRole,
  }) async {
    final cleanReg = regNo.trim().toUpperCase();

    // Check CR restriction: Only I1 (24B01A12I1) and F7 (24B01A12F7) have access to CR page!
    if (expectedRole == UserRole.cr) {
      if (!User.isAuthorizedCR(cleanReg)) {
        throw Exception(
          'Access Denied: The authorized CRs are I1 (24B01A12I1) and F7 (24B01A12F7) only. Other registration numbers cannot access the CR page.',
        );
      }
    }

    final user = _users.firstWhere(
      (u) => u.registrationNumber.toUpperCase() == cleanReg && u.role == expectedRole,
      orElse: () => throw Exception('User not found with registration number: $cleanReg for ${expectedRole.name.toUpperCase()} role.'),
    );

    final hashed = User.hashPassword(password);
    if (user.passwordHash != hashed) {
      throw Exception('Invalid password for user $cleanReg.');
    }

    if (!user.active) {
      throw Exception('This account is disabled. Contact administrator.');
    }

    _currentUser = user;
    return user;
  }

  void logout() {
    _currentUser = null;
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (_currentUser == null) throw Exception('No user logged in.');
    if (newPassword.length < 6) throw Exception('New password must be at least 6 characters.');
    if (newPassword != confirmPassword) throw Exception('New password and confirmation do not match.');

    final oldHashed = User.hashPassword(oldPassword);
    if (_currentUser!.passwordHash != oldHashed) {
      throw Exception('Current password does not match.');
    }

    final index = _users.indexWhere((u) => u.userId == _currentUser!.userId);
    if (index != -1) {
      final updated = _currentUser!.copyWith(passwordHash: User.hashPassword(newPassword));
      _users[index] = updated;
      _currentUser = updated;
    }
  }

  // --- Branches & Students ---
  List<String> getBranches() => List.unmodifiable(_branches);

  List<Student> getStudentsForClass({
    required String year,
    required String branch,
    required String section,
  }) {
    return _students.where((s) =>
      s.academicYear == year && s.branch == branch && s.section == section && s.active
    ).toList()..sort((a, b) => a.serialNo.compareTo(b.serialNo));
  }

  Future<void> addStudent({
    required String regNo,
    required String name,
    required String year,
    required String branch,
    required String section,
  }) async {
    final cleanReg = regNo.trim().toUpperCase();
    final cleanName = name.trim().toUpperCase();

    final existing = _students.any((s) =>
      s.academicYear == year && s.branch == branch && s.section == section && s.registrationNumber == cleanReg
    );
    if (existing) {
      throw Exception('Student with registration number $cleanReg already exists in $year $branch $section.');
    }

    final currentClassStudents = getStudentsForClass(year: year, branch: branch, section: section);
    final nextSerial = currentClassStudents.isEmpty ? 1 : currentClassStudents.map((e) => e.serialNo).reduce((a, b) => a > b ? a : b) + 1;

    final newStudent = Student(
      studentId: '${year}_${branch}_${section}_$cleanReg'.replaceAll(' ', '_'),
      serialNo: nextSerial,
      registrationNumber: cleanReg,
      name: cleanName,
      academicYear: year,
      branch: branch,
      section: section,
    );
    _students.add(newStudent);
  }

  Future<void> editStudent({required Student student, required String newName}) async {
    final index = _students.indexWhere((s) => s.studentId == student.studentId);
    if (index != -1) {
      _students[index] = student.copyWith(name: newName.trim().toUpperCase());
    }
  }

  Future<void> deleteStudent({required Student student}) async {
    _students.removeWhere((s) => s.studentId == student.studentId);
  }

  // --- Shared Attendance Operations ---
  /// Shared History: Returns all attendance records visible to both Faculty and Students/CR.
  List<AttendanceRecord> getSharedHistory({
    String? year,
    String? branch,
    String? section,
    String? period,
  }) {
    purgeExpiredRecords();
    return _sharedAttendanceRecords.where((r) {
      if (year != null && r.academicYear != year) return false;
      if (branch != null && r.branch != branch) return false;
      if (section != null && r.section != section) return false;
      if (period != null && r.period != period) return false;
      return true;
    }).toList()..sort((a, b) => b.createdAtMillis.compareTo(a.createdAtMillis));
  }

  List<AttendanceDetail> getAttendanceDetails(String attendanceId) {
    return _sharedAttendanceDetails[attendanceId] ?? [];
  }

  /// Save attendance: Generates independent records for each selected period.
  /// Saved to shared history so both student/CR and faculty can see it.
  Future<List<AttendanceRecord>> saveAttendance({
    required String academicYear,
    required String branch,
    required String section,
    required List<String> periods,
    required Map<String, bool> studentStatuses,
    required List<Student> students,
  }) async {
    final now = nowKolkata;
    final dateKey = DateFormat('yyyy-MM-dd').format(now);
    final dateFormatted = DateFormat('dd MMMM yyyy').format(now);
    final dayOfWeek = DateFormat('EEEE').format(now);
    final timeFormatted = "${DateFormat('hh:mm:ss a').format(now)} IST";
    final epoch = now.millisecondsSinceEpoch;

    final presentCount = students.where((s) => studentStatuses[s.registrationNumber] == true).length;
    final absentCount = students.length - presentCount;

    final createdList = <AttendanceRecord>[];

    for (final period in periods) {
      final attendanceId = "att_${dateKey}_${academicYear}_${branch}_${section}_$period".replaceAll(' ', '_');

      final record = AttendanceRecord(
        attendanceId: attendanceId,
        dateKey: dateKey,
        dateFormatted: dateFormatted,
        dayOfWeek: dayOfWeek,
        timeFormatted: timeFormatted,
        academicYear: academicYear,
        branch: branch,
        section: section,
        period: period,
        totalStudents: students.length,
        presentCount: presentCount,
        absentCount: absentCount,
        createdByRole: _currentUser?.role.name.toUpperCase() ?? 'UNKNOWN',
        createdByRegNo: _currentUser?.registrationNumber ?? '',
        createdAtMillis: epoch,
        updatedAtMillis: epoch,
        expiresAtMillis: epoch + (7 * 24 * 60 * 60 * 1000),
      );

      final details = students.map((s) => AttendanceDetail(
        detailId: "${attendanceId}_${s.registrationNumber}",
        attendanceId: attendanceId,
        studentRegNo: s.registrationNumber,
        studentName: s.name,
        serialNo: s.serialNo,
        isPresent: studentStatuses[s.registrationNumber] ?? false,
      )).toList();

      // Upsert into shared history
      _sharedAttendanceRecords.removeWhere((r) => r.attendanceId == attendanceId);
      _sharedAttendanceRecords.add(record);
      _sharedAttendanceDetails[attendanceId] = details;

      createdList.add(record);
    }

    return createdList;
  }

  /// Faculty modification: strictly allowed ONLY before 6:00 PM IST on same day.
  /// CR is strictly NOT allowed to edit.
  Future<AttendanceRecord> editSavedAttendance({
    required String attendanceId,
    required Map<String, bool> updatedStatuses,
    required List<Student> students,
  }) async {
    if (_currentUser?.role == UserRole.cr) {
      throw Exception('Access Denied: CR cannot modify saved attendance.');
    }

    final recordIndex = _sharedAttendanceRecords.indexWhere((r) => r.attendanceId == attendanceId);
    if (recordIndex == -1) {
      throw Exception('Attendance record not found.');
    }

    final record = _sharedAttendanceRecords[recordIndex];

    if (_currentUser?.role == UserRole.faculty && !record.canFacultyEdit) {
      throw Exception('Modification Deadline Expired: Faculty can only edit attendance by 6:00 PM on that day.');
    }

    final presentCount = students.where((s) => updatedStatuses[s.registrationNumber] == true).length;
    final absentCount = students.length - presentCount;
    final now = nowKolkata.millisecondsSinceEpoch;

    final updatedRecord = AttendanceRecord(
      attendanceId: record.attendanceId,
      dateKey: record.dateKey,
      dateFormatted: record.dateFormatted,
      dayOfWeek: record.dayOfWeek,
      timeFormatted: record.timeFormatted,
      academicYear: record.academicYear,
      branch: record.branch,
      section: record.section,
      period: record.period,
      totalStudents: students.length,
      presentCount: presentCount,
      absentCount: absentCount,
      createdByRole: record.createdByRole,
      createdByRegNo: record.createdByRegNo,
      createdAtMillis: record.createdAtMillis,
      updatedAtMillis: now,
      expiresAtMillis: record.expiresAtMillis,
    );

    final details = students.map((s) => AttendanceDetail(
      detailId: "${attendanceId}_${s.registrationNumber}",
      attendanceId: attendanceId,
      studentRegNo: s.registrationNumber,
      studentName: s.name,
      serialNo: s.serialNo,
      isPresent: updatedStatuses[s.registrationNumber] ?? false,
    )).toList();

    _sharedAttendanceRecords[recordIndex] = updatedRecord;
    _sharedAttendanceDetails[attendanceId] = details;

    return updatedRecord;
  }

  /// Official Formatted Read-Only Faculty Report
  String generateFacultyReport(AttendanceRecord record, List<AttendanceDetail> details) {
    final absentRegNos = details
        .where((d) => !d.isPresent)
        .toList()
      ..sort((a, b) => a.serialNo.compareTo(b.serialNo));

    final absentListStr = absentRegNos.isEmpty
        ? 'None (All Present)'
        : absentRegNos.map((d) => d.studentRegNo).join(', ');

    return '''
ATTENDANCE REPORT

Date: ${record.dateFormatted}
Day: ${record.dayOfWeek}
Time: ${record.timeFormatted}

Class: ${record.academicYear} ${record.branch}-${record.section.replaceAll('Section ', '')}
Period: ${record.period}

Total Students: ${record.totalStudents}
Number of Absentees: ${record.absentCount}

Absent Student Registration Numbers:
$absentListStr

Attendance has been recorded successfully.''';
  }
}
