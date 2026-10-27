package com.example.data.model

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "attendance_details",
    foreignKeys = [
        ForeignKey(
            entity = AttendanceRecord::class,
            parentColumns = ["attendanceId"],
            childColumns = ["attendanceId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [
        Index(value = ["attendanceId"]),
        Index(value = ["attendanceId", "studentRegNo"], unique = true)
    ]
)
data class AttendanceDetail(
    @PrimaryKey
    val detailId: String, // "${attendanceId}_${studentRegNo}"
    val attendanceId: String,
    val studentRegNo: String,
    val studentName: String,
    val serialNo: Int,
    val isPresent: Boolean, // true = Present, false = Absent
    val expiresAt: Long = System.currentTimeMillis() + (7L * 24L * 60L * 60L * 1000L)
)
