package com.example.data.model

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "students",
    indices = [
        Index(value = ["academicYear", "branch", "section", "registrationNumber"], unique = true)
    ]
)
data class Student(
    @PrimaryKey
    val studentId: String, // e.g. "3rd_Year_IT_Section_C_24B01A12D2"
    val serialNo: Int,
    val registrationNumber: String,
    val name: String,
    val academicYear: String,
    val branch: String,
    val section: String,
    val active: Boolean = true,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
)
