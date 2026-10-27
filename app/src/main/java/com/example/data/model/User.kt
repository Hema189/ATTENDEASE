package com.example.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

enum class UserRole {
    ADMIN,
    FACULTY,
    CR
}

@Entity(tableName = "users")
data class User(
    @PrimaryKey
    val userId: String, // e.g. "admin", "FAC001", "24B01A12D2"
    val registrationNumber: String,
    val name: String,
    val passwordHash: String,
    val role: UserRole,
    val academicYear: String? = null, // for CR (e.g. "3rd Year")
    val branch: String? = null,       // for CR/Faculty (e.g. "IT")
    val section: String? = null,      // for CR (e.g. "Section C")
    val active: Boolean = true,
    val createdAt: Long = System.currentTimeMillis()
)
