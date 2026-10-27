import 'package:intl/intl.dart';

class AttendanceRecord {
  final String attendanceId;
  final String dateKey; // e.g. "2026-10-10"
  final String dateFormatted; // e.g. "10 October 2026"
  final String dayOfWeek; // e.g. "Saturday"
  final String timeFormatted; // e.g. "10:30 AM IST"
  final String academicYear;
  final String branch;
  final String section;
  final String period;
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final String createdByRole; // "FACULTY", "CR", "ADMIN"
  final String createdByRegNo;
  final int createdAtMillis;
  final int updatedAtMillis;
  final int expiresAtMillis;

  AttendanceRecord({
    required this.attendanceId,
    required this.dateKey,
    required this.dateFormatted,
    required this.dayOfWeek,
    required this.timeFormatted,
    required this.academicYear,
    required this.branch,
    required this.section,
    required this.period,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.createdByRole,
    required this.createdByRegNo,
    required this.createdAtMillis,
    required this.updatedAtMillis,
    required this.expiresAtMillis,
  });

  /// Faculty can modify saved attendance only before 6:00 PM (18:00) IST on the same attendance date.
  /// At or after 6:00 PM, the saved attendance becomes permanently read-only.
  bool get canFacultyEdit {
    final recordDate = DateTime.fromMillisecondsSinceEpoch(createdAtMillis).toUtc().add(const Duration(hours: 5, minutes: 30));
    final nowKolkata = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));

    final isSameDay = recordDate.year == nowKolkata.year &&
        recordDate.month == nowKolkata.month &&
        recordDate.day == nowKolkata.day;

    if (!isSameDay) return false;
    return nowKolkata.hour < 18;
  }

  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - createdAtMillis) >= (7 * 24 * 60 * 60 * 1000);
  }

  Map<String, dynamic> toMap() {
    return {
      'attendanceId': attendanceId,
      'dateKey': dateKey,
      'dateFormatted': dateFormatted,
      'dayOfWeek': dayOfWeek,
      'timeFormatted': timeFormatted,
      'academicYear': academicYear,
      'branch': branch,
      'section': section,
      'period': period,
      'totalStudents': totalStudents,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'createdByRole': createdByRole,
      'createdByRegNo': createdByRegNo,
      'createdAtMillis': createdAtMillis,
      'updatedAtMillis': updatedAtMillis,
      'expiresAtMillis': expiresAtMillis,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      attendanceId: map['attendanceId'] ?? '',
      dateKey: map['dateKey'] ?? '',
      dateFormatted: map['dateFormatted'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? '',
      timeFormatted: map['timeFormatted'] ?? '',
      academicYear: map['academicYear'] ?? '',
      branch: map['branch'] ?? '',
      section: map['section'] ?? '',
      period: map['period'] ?? '',
      totalStudents: map['totalStudents'] ?? 0,
      presentCount: map['presentCount'] ?? 0,
      absentCount: map['absentCount'] ?? 0,
      createdByRole: map['createdByRole'] ?? '',
      createdByRegNo: map['createdByRegNo'] ?? '',
      createdAtMillis: map['createdAtMillis'] ?? 0,
      updatedAtMillis: map['updatedAtMillis'] ?? 0,
      expiresAtMillis: map['expiresAtMillis'] ?? 0,
    );
  }
}

class AttendanceDetail {
  final String detailId;
  final String attendanceId;
  final String studentRegNo;
  final String studentName;
  final int serialNo;
  final bool isPresent;

  AttendanceDetail({
    required this.detailId,
    required this.attendanceId,
    required this.studentRegNo,
    required this.studentName,
    required this.serialNo,
    required this.isPresent,
  });

  Map<String, dynamic> toMap() {
    return {
      'detailId': detailId,
      'attendanceId': attendanceId,
      'studentRegNo': studentRegNo,
      'studentName': studentName,
      'serialNo': serialNo,
      'isPresent': isPresent,
    };
  }

  factory AttendanceDetail.fromMap(Map<String, dynamic> map) {
    return AttendanceDetail(
      detailId: map['detailId'] ?? '',
      attendanceId: map['attendanceId'] ?? '',
      studentRegNo: map['studentRegNo'] ?? '',
      studentName: map['studentName'] ?? '',
      serialNo: map['serialNo'] ?? 0,
      isPresent: map['isPresent'] ?? true,
    );
  }
}
