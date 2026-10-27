package com.example.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Update
import com.example.data.model.AttendanceDetail
import com.example.data.model.AttendanceRecord
import kotlinx.coroutines.flow.Flow

@Dao
interface AttendanceDao {
    @Query("SELECT * FROM attendance_records ORDER BY createdAt DESC")
    fun getAllRecords(): Flow<List<AttendanceRecord>>

    @Query("""
        SELECT * FROM attendance_records 
        WHERE (:academicYear IS NULL OR academicYear = :academicYear)
          AND (:branch IS NULL OR branch = :branch)
          AND (:section IS NULL OR section = :section)
          AND (:period IS NULL OR period = :period)
          AND (:dateKey IS NULL OR dateKey = :dateKey)
        ORDER BY createdAt DESC
    """)
    fun getFilteredRecords(
        academicYear: String?,
        branch: String?,
        section: String?,
        period: String?,
        dateKey: String?
    ): Flow<List<AttendanceRecord>>

    @Query("SELECT * FROM attendance_records WHERE attendanceId = :id LIMIT 1")
    suspend fun getRecordById(id: String): AttendanceRecord?

    @Query("""
        SELECT * FROM attendance_records 
        WHERE dateKey = :dateKey 
          AND academicYear = :academicYear 
          AND branch = :branch 
          AND section = :section 
          AND period = :period 
        LIMIT 1
    """)
    suspend fun findExistingRecord(
        dateKey: String,
        academicYear: String,
        branch: String,
        section: String,
        period: String
    ): AttendanceRecord?

    @Query("SELECT * FROM attendance_details WHERE attendanceId = :attendanceId ORDER BY serialNo ASC")
    fun getDetailsForRecord(attendanceId: String): Flow<List<AttendanceDetail>>

    @Query("SELECT * FROM attendance_details WHERE attendanceId = :attendanceId ORDER BY serialNo ASC")
    suspend fun getDetailsForRecordSync(attendanceId: String): List<AttendanceDetail>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertRecord(record: AttendanceRecord)

    @Update
    suspend fun updateRecord(record: AttendanceRecord)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertDetails(details: List<AttendanceDetail>)

    @Query("DELETE FROM attendance_details WHERE attendanceId = :attendanceId")
    suspend fun deleteDetailsForRecord(attendanceId: String)

    @Transaction
    suspend fun saveAttendanceWithDetails(
        record: AttendanceRecord,
        details: List<AttendanceDetail>
    ) {
        insertRecord(record)
        deleteDetailsForRecord(record.attendanceId)
        insertDetails(details)
    }

    /**
     * Automatic cleanup: delete records and associated details older than 7 days
     */
    @Query("DELETE FROM attendance_records WHERE expiresAt <= :currentTimeMillis OR createdAt <= :cutoffMillis")
    suspend fun deleteExpiredRecords(currentTimeMillis: Long, cutoffMillis: Long): Int

    @Query("DELETE FROM attendance_details WHERE expiresAt <= :currentTimeMillis")
    suspend fun deleteExpiredDetails(currentTimeMillis: Long): Int
}
