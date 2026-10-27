package com.example.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "branches")
data class Branch(
    @PrimaryKey
    val code: String, // e.g., "IT", "CSE", "ECE"
    val name: String, // e.g., "Information Technology"
    val active: Boolean = true,
    val displayOrder: Int = 0
)
