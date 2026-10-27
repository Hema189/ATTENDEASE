package com.example.data.repository

import com.example.data.local.AppDatabase
import com.example.data.model.AttendanceDetail
import com.example.data.model.AttendanceRecord
import com.example.data.model.Branch
import com.example.data.model.Student
import com.example.data.model.User
import com.example.data.model.UserRole
import com.example.util.TimeUtil
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext
import java.util.UUID

class AttendanceRepository(private val db: AppDatabase) {

    private val userDao = db.userDao()
    private val studentDao = db.studentDao()
    private val branchDao = db.branchDao()
    private val attendanceDao = db.attendanceDao()

    suspend fun initializeDatabaseIfNeeded() = withContext(Dispatchers.IO) {
        // Bootstrap users (ensure I1 and F7 are always registered)
        userDao.insertUsers(InitialData.INITIAL_USERS)

        // Bootstrap branches
        if (branchDao.countBranches() == 0) {
            branchDao.insertBranches(InitialData.INITIAL_BRANCHES)
        }

        // Bootstrap students: ONLY 3rd Year -> IT -> Section C
        val itcCount = studentDao.countStudents("3rd Year", "IT", "Section C")
        if (itcCount == 0) {
            studentDao.insertStudents(InitialData.INITIAL_3RD_YEAR_IT_C_STUDENTS)
        }

        // Perform automatic cleanup of expired attendance records (> 7 days)
        performRetentionCleanup()
    }

    suspend fun performRetentionCleanup(): Int = withContext(Dispatchers.IO) {
        val now = System.currentTimeMillis()
        val cutoff = now - TimeUtil.RETENTION_MILLIS
        val deletedCount = attendanceDao.deleteExpiredRecords(now, cutoff)
        attendanceDao.deleteExpiredDetails(now)
        deletedCount
    }

    // --- Authentication ---
    suspend fun login(regNo: String, password: String):Result<User> = withContext(Dispatchers.IO) {
        val user = userDao.getUserByRegNo(regNo.trim())
            ?: return@withContext Result.failure(Exception("User with registration number '$regNo' not found."))

        val hashedInput = InitialData.hashPassword(password)
        if (user.passwordHash != hashedInput) {
            return@withContext Result.failure(Exception("Invalid password. Please check your credentials."))
        }

        if (!user.active) {
            return@withContext Result.failure(Exception("Account is disabled. Contact campus administrator."))
        }

        if (user.role == UserRole.CR && user.registrationNumber != "24B01A12I1" && user.registrationNumber != "24B01A12F7") {
            return@withContext Result.failure(Exception("Access denied: Only designated CRs (I1: 24B01A12I1 and F7: 24B01A12F7) have access to the CR page."))
        }

        Result.success(user)
    }

    suspend fun getAdminUser(): User? = withContext(Dispatchers.IO) {
        userDao.getUserByRegNo("ADMIN") ?: userDao.getUserById("admin_01")
    }

    suspend fun changePassword(
        userId: String,
        oldPass: String,
        newPass: String,
        confirmPass: String
    ): Result<Unit> = withContext(Dispatchers.IO) {
        val user = userDao.getUserById(userId)
            ?: return@withContext Result.failure(Exception("User not found."))

        val oldHashed = InitialData.hashPassword(oldPass)
        if (user.passwordHash != oldHashed) {
            return@withContext Result.failure(Exception("Current password is incorrect."))
        }

        if (newPass.length < 6) {
            return@withContext Result.failure(Exception("New password must be at least 6 characters long."))
        }

        if (newPass != confirmPass) {
            return@withContext Result.failure(Exception("New password and confirmation do not match."))
        }

        val newHashed = InitialData.hashPassword(newPass)
        userDao.updateUser(user.copy(passwordHash = newHashed))
        Result.success(Unit)
    }

    // --- User Management (Admin) ---
    fun getAllUsers(): Flow<List<User>> = userDao.getAllUsers()

    suspend fun createAccount(
        regNo: String,
        name: String,
        initialPass: String,
        role: UserRole,
        academicYear: String? = null,
        branch: String? = null,
        section: String? = null
    ): Result<User> = withContext(Dispatchers.IO) {
        val existing = userDao.getUserByRegNo(regNo.trim())
        if (existing != null) {
            return@withContext Result.failure(Exception("An account with Registration Number '$regNo' already exists."))
        }

        val newUser = User(
            userId = UUID.randomUUID().toString(),
            registrationNumber = regNo.trim(),
            name = name.trim(),
            passwordHash = InitialData.hashPassword(initialPass),
            role = role,
            academicYear = academicYear,
            branch = branch,
            section = section,
            active = true
        )
        userDao.insertUser(newUser)
        Result.success(newUser)
    }

    suspend fun resetUserPassword(userId: String, newPass: String): Result<Unit> = withContext(Dispatchers.IO) {
        val user = userDao.getUserById(userId) ?: return@withContext Result.failure(Exception("User not found."))
        userDao.updateUser(user.copy(passwordHash = InitialData.hashPassword(newPass)))
        Result.success(Unit)
    }

    // --- Branches ---
    fun getActiveBranches(): Flow<List<Branch>> = branchDao.getAllActiveBranches()
    fun getAllBranches(): Flow<List<Branch>> = branchDao.getAllBranches()

    suspend fun addBranch(code: String, name: String): Result<Unit> = withContext(Dispatchers.IO) {
        val cleanCode = code.trim().uppercase()
        if (cleanCode.isBlank() || name.isBlank()) {
            return@withContext Result.failure(Exception("Branch code and name cannot be empty."))
        }
        branchDao.insertBranch(Branch(code = cleanCode, name = name.trim(), displayOrder = 99))
        Result.success(Unit)
    }

    // --- Students ---
    fun getStudents(academicYear: String, branch: String, section: String): Flow<List<Student>> {
        return studentDao.getStudents(academicYear, branch, section)
    }

    suspend fun getStudentsSync(academicYear: String, branch: String, section: String): List<Student> =
        withContext(Dispatchers.IO) {
            studentDao.getStudentsSync(academicYear, branch, section)
        }

    suspend fun addStudent(
        regNo: String,
        name: String,
        academicYear: String,
        branch: String,
        section: String
    ): Result<Student> = withContext(Dispatchers.IO) {
        val cleanReg = regNo.trim().uppercase()
        val cleanName = name.trim()

        if (cleanReg.isBlank()) return@withContext Result.failure(Exception("Registration number is required."))
        if (cleanName.isBlank()) return@withContext Result.failure(Exception("Student name is required."))

        val existing = studentDao.findByRegNo(cleanReg, academicYear, branch, section)
        if (existing != null) {
            return@withContext Result.failure(Exception("Student with registration number '$cleanReg' already exists in $academicYear $branch $section."))
        }

        val currentMaxSerial = studentDao.getMaxSerialNo(academicYear, branch, section) ?: 0
        val newStudent = Student(
            studentId = "${academicYear}_${branch}_${section}_$cleanReg".replace(" ", "_"),
            serialNo = currentMaxSerial + 1,
            registrationNumber = cleanReg,
            name = cleanName,
            academicYear = academicYear,
            branch = branch,
            section = section
        )
        studentDao.insertStudent(newStudent)
        Result.success(newStudent)
    }

    suspend fun updateStudent(student: Student): Result<Unit> = withContext(Dispatchers.IO) {
        studentDao.updateStudent(student.copy(updatedAt = System.currentTimeMillis()))
        Result.success(Unit)
    }

    suspend fun deleteStudent(student: Student): Result<Unit> = withContext(Dispatchers.IO) {
        studentDao.deleteStudent(student)
        Result.success(Unit)
    }

    // --- Attendance Operations ---
    suspend fun findExistingRecord(
        dateKey: String,
        academicYear: String,
        branch: String,
        section: String,
        period: String
    ): AttendanceRecord? = withContext(Dispatchers.IO) {
        attendanceDao.findExistingRecord(dateKey, academicYear, branch, section, period)
    }

    /**
     * Saves attendance for one or more periods.
     * When multiple periods are selected, an independent record is created for each period.
     */
    suspend fun saveAttendance(
        academicYear: String,
        branch: String,
        section: String,
        periods: List<String>,
        studentStatuses: Map<String, Boolean>, // studentRegNo -> isPresent
        students: List<Student>,
        user: User
    ): Result<List<AttendanceRecord>> = withContext(Dispatchers.IO) {
        try {
            val liveTime = TimeUtil.getLiveKolkataTime()
            val total = students.size
            val presentCount = students.count { studentStatuses[it.registrationNumber] == true }
            val absentCount = total - presentCount

            val savedRecords = mutableListOf<AttendanceRecord>()

            for (period in periods) {
                val recordId = "att_${liveTime.dateKey}_${academicYear}_${branch}_${section}_${period}"
                    .replace(" ", "_")
                    .replace("-", "_")

                val record = AttendanceRecord(
                    attendanceId = recordId,
                    dateKey = liveTime.dateKey,
                    dateFormatted = liveTime.dateFormatted,
                    dayOfWeek = liveTime.dayOfWeek,
                    timeFormatted = liveTime.shortTime,
                    academicYear = academicYear,
                    branch = branch,
                    section = section,
                    period = period,
                    totalStudents = total,
                    presentCount = presentCount,
                    absentCount = absentCount,
                    createdByRole = user.role,
                    createdByRegNo = user.registrationNumber,
                    createdAt = liveTime.epochMillis,
                    updatedAt = liveTime.epochMillis,
                    expiresAt = liveTime.epochMillis + TimeUtil.RETENTION_MILLIS
                )

                val details = students.map { student ->
                    val isPresent = studentStatuses[student.registrationNumber] ?: false
                    AttendanceDetail(
                        detailId = "${recordId}_${student.registrationNumber}",
                        attendanceId = recordId,
                        studentRegNo = student.registrationNumber,
                        studentName = student.name,
                        serialNo = student.serialNo,
                        isPresent = isPresent,
                        expiresAt = record.expiresAt
                    )
                }

                attendanceDao.saveAttendanceWithDetails(record, details)
                savedRecords.add(record)
            }

            Result.success(savedRecords)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    /**
     * Modification Rules:
     * - CR cannot modify saved attendance.
     * - Faculty can modify ONLY before 6:00 PM on same day in Asia/Kolkata.
     */
    suspend fun updateSavedAttendance(
        attendanceId: String,
        studentStatuses: Map<String, Boolean>,
        students: List<Student>,
        user: User
    ): Result<AttendanceRecord> = withContext(Dispatchers.IO) {
        val record = attendanceDao.getRecordById(attendanceId)
            ?: return@withContext Result.failure(Exception("Attendance record not found."))

        if (user.role == UserRole.CR) {
            return@withContext Result.failure(Exception("CR is strictly not permitted to edit saved attendance records."))
        }

        if (user.role == UserRole.FACULTY) {
            if (!TimeUtil.canFacultyEditRecord(record.createdAt)) {
                return@withContext Result.failure(Exception("Attendance editing deadline (6:00 PM IST on attendance date) has passed. This record is permanently read-only."))
            }
        }

        val total = students.size
        val presentCount = students.count { studentStatuses[it.registrationNumber] == true }
        val absentCount = total - presentCount
        val now = System.currentTimeMillis()

        val updatedRecord = record.copy(
            presentCount = presentCount,
            absentCount = absentCount,
            updatedAt = now
        )

        val updatedDetails = students.map { student ->
            val isPresent = studentStatuses[student.registrationNumber] ?: false
            AttendanceDetail(
                detailId = "${attendanceId}_${student.registrationNumber}",
                attendanceId = attendanceId,
                studentRegNo = student.registrationNumber,
                studentName = student.name,
                serialNo = student.serialNo,
                isPresent = isPresent,
                expiresAt = record.expiresAt
            )
        }

        attendanceDao.saveAttendanceWithDetails(updatedRecord, updatedDetails)
        Result.success(updatedRecord)
    }

    fun getFilteredHistory(
        academicYear: String?,
        branch: String?,
        section: String?,
        period: String?,
        dateKey: String?
    ): Flow<List<AttendanceRecord>> {
        return attendanceDao.getFilteredRecords(academicYear, branch, section, period, dateKey)
    }

    fun getAttendanceDetails(attendanceId: String): Flow<List<AttendanceDetail>> {
        return attendanceDao.getDetailsForRecord(attendanceId)
    }

    suspend fun getAttendanceDetailsSync(attendanceId: String): List<AttendanceDetail> =
        withContext(Dispatchers.IO) {
            attendanceDao.getDetailsForRecordSync(attendanceId)
        }

    suspend fun getRecordById(attendanceId: String): AttendanceRecord? =
        withContext(Dispatchers.IO) {
            attendanceDao.getRecordById(attendanceId)
        }

    /**
     * Requirement: Generate the exact formatted Faculty Attendance Message
     */
    fun formatFacultyReport(
        record: AttendanceRecord,
        details: List<AttendanceDetail>
    ): String {
        val absentRegNos = details
            .filter { !it.isPresent }
            .sortedBy { it.serialNo }
            .map { it.studentRegNo }

        val absentText = if (absentRegNos.isEmpty()) {
            "None (All Present)"
        } else {
            absentRegNos.joinToString(", ")
        }

        return """
ATTENDANCE REPORT

Date: ${record.dateFormatted}
Day: ${record.dayOfWeek}
Time: ${record.timeFormatted}

Class: ${record.academicYear} ${record.branch}-${record.section.replace("Section ", "")}
Period: ${record.period}

Total Students: ${record.totalStudents}
Number of Absentees: ${record.absentCount}

Absent Student Registration Numbers:
$absentText

Attendance has been recorded successfully.
""".trimIndent()
    }
}
