package com.example.data.model

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "attendance_records",
    indices = [
        Index(value = ["dateKey", "academicYear", "branch", "section", "period"], unique = true)
    ]
)
data class AttendanceRecord(
    @PrimaryKey
    val attendanceId: String, // e.g. "att_2026-10-10_3rdYear_IT_SecC_P1"
    val dateKey: String,       // "2026-10-10"
    val dateFormatted: String, // "10 October 2026"
    val dayOfWeek: String,     // "Saturday"
    val timeFormatted: String, // "10:30 AM IST"
    val academicYear: String,  // "3rd Year"
    val branch: String,        // "IT"
    val section: String,       // "Section C"
    val period: String,        // "Period 1"
    val totalStudents: Int,
    val presentCount: Int,
    val absentCount: Int,
    val createdByRole: UserRole,
    val createdByRegNo: String,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis(),
    val expiresAt: Long = System.currentTimeMillis() + (7L * 24L * 60L * 60L * 1000L)
)
