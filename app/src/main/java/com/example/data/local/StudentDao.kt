package com.example.data.local

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.example.data.model.Student
import kotlinx.coroutines.flow.Flow

@Dao
interface StudentDao {
    @Query("""
        SELECT * FROM students 
        WHERE academicYear = :academicYear 
          AND branch = :branch 
          AND section = :section 
          AND active = 1 
        ORDER BY serialNo ASC
    """)
    fun getStudents(academicYear: String, branch: String, section: String): Flow<List<Student>>

    @Query("""
        SELECT * FROM students 
        WHERE academicYear = :academicYear 
          AND branch = :branch 
          AND section = :section 
          AND active = 1 
        ORDER BY serialNo ASC
    """)
    suspend fun getStudentsSync(academicYear: String, branch: String, section: String): List<Student>

    @Query("""
        SELECT * FROM students 
        WHERE registrationNumber = :regNo 
          AND academicYear = :academicYear 
          AND branch = :branch 
          AND section = :section 
        LIMIT 1
    """)
    suspend fun findByRegNo(regNo: String, academicYear: String, branch: String, section: String): Student?

    @Query("SELECT * FROM students WHERE studentId = :id LIMIT 1")
    suspend fun getStudentById(id: String): Student?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertStudent(student: Student)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertStudents(students: List<Student>)

    @Update
    suspend fun updateStudent(student: Student)

    @Delete
    suspend fun deleteStudent(student: Student)

    @Query("""
        SELECT COUNT(*) FROM students 
        WHERE academicYear = :academicYear 
          AND branch = :branch 
          AND section = :section 
          AND active = 1
    """)
    suspend fun countStudents(academicYear: String, branch: String, section: String): Int

    @Query("SELECT MAX(serialNo) FROM students WHERE academicYear = :academicYear AND branch = :branch AND section = :section")
    suspend fun getMaxSerialNo(academicYear: String, branch: String, section: String): Int?
}
