package com.example.ui.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.data.local.AppDatabase
import com.example.data.model.AttendanceDetail
import com.example.data.model.AttendanceRecord
import com.example.data.model.Branch
import com.example.data.model.Student
import com.example.data.model.User
import com.example.data.model.UserRole
import com.example.data.repository.AttendanceRepository
import com.example.util.TimeUtil
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

enum class Screen {
    LOGIN,
    CHANGE_PASSWORD,
    DASHBOARD_YEAR,
    BRANCH_SELECTION,
    SECTION_SELECTION,
    PERIOD_SELECTION,
    ATTENDANCE_SHEET,
    FACULTY_REPORT,
    ATTENDANCE_HISTORY,
    HISTORY_DETAIL,
    STUDENT_MANAGEMENT,
    ADMIN_PANEL
}

enum class PeriodMode {
    SINGLE,
    MULTIPLE
}

enum class AttendanceSubTab {
    ABSENTEES, // Default
    PRESENT
}

class AttendanceViewModel(application: Application) : AndroidViewModel(application) {

    private val db = AppDatabase.getDatabase(application)
    val repository = AttendanceRepository(db)

    // Navigation state with back stack
    private val _screenStack = MutableStateFlow(listOf(Screen.LOGIN))
    val currentScreen: StateFlow<Screen> = MutableStateFlow(Screen.LOGIN)

    private val _activeScreen = MutableStateFlow(Screen.LOGIN)
    val activeScreen: StateFlow<Screen> = _activeScreen.asStateFlow()

    // Real-time live date and time in Asia/Kolkata
    private val _liveTime = MutableStateFlow(TimeUtil.getLiveKolkataTime())
    val liveTime: StateFlow<TimeUtil.LiveTimeState> = _liveTime.asStateFlow()

    // Auth
    private val _currentUser = MutableStateFlow<User?>(null)
    val currentUser: StateFlow<User?> = _currentUser.asStateFlow()

    private val _loginError = MutableStateFlow<String?>(null)
    val loginError: StateFlow<String?> = _loginError.asStateFlow()

    private val _snackBarMessage = MutableStateFlow<String?>(null)
    val snackBarMessage: StateFlow<String?> = _snackBarMessage.asStateFlow()

    // Navigation Class Selections
    private val _selectedYear = MutableStateFlow<String?>("3rd Year")
    val selectedYear: StateFlow<String?> = _selectedYear.asStateFlow()

    private val _selectedBranch = MutableStateFlow<String?>("IT")
    val selectedBranch: StateFlow<String?> = _selectedBranch.asStateFlow()

    private val _selectedSection = MutableStateFlow<String?>("Section C")
    val selectedSection: StateFlow<String?> = _selectedSection.asStateFlow()

    // Period Mode
    private val _periodMode = MutableStateFlow(PeriodMode.SINGLE)
    val periodMode: StateFlow<PeriodMode> = _periodMode.asStateFlow()

    private val _selectedPeriods = MutableStateFlow(setOf("Period 1"))
    val selectedPeriods: StateFlow<Set<String>> = _selectedPeriods.asStateFlow()

    // Students for current class
    private val _currentStudents = MutableStateFlow<List<Student>>(emptyList())
    val currentStudents: StateFlow<List<Student>> = _currentStudents.asStateFlow()

    // Attendance Taking State
    // Map: studentRegNo -> Boolean (true = Present, false = Absent)
    private val _studentStatuses = MutableStateFlow<Map<String, Boolean>>(emptyMap())
    val studentStatuses: StateFlow<Map<String, Boolean>> = _studentStatuses.asStateFlow()

    private val _activeSubTab = MutableStateFlow(AttendanceSubTab.ABSENTEES)
    val activeSubTab: StateFlow<AttendanceSubTab> = _activeSubTab.asStateFlow()

    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    // Save Confirmation Dialog
    private val _showSaveConfirmDialog = MutableStateFlow(false)
    val showSaveConfirmDialog: StateFlow<Boolean> = _showSaveConfirmDialog.asStateFlow()

    private val _isSaving = MutableStateFlow(false)
    val isSaving: StateFlow<Boolean> = _isSaving.asStateFlow()

    // Generated Report
    private val _generatedReportText = MutableStateFlow("")
    val generatedReportText: StateFlow<String> = _generatedReportText.asStateFlow()

    private val _lastSavedRecord = MutableStateFlow<AttendanceRecord?>(null)
    val lastSavedRecord: StateFlow<AttendanceRecord?> = _lastSavedRecord.asStateFlow()

    // History and Details
    private val _selectedHistoryRecord = MutableStateFlow<AttendanceRecord?>(null)
    val selectedHistoryRecord: StateFlow<AttendanceRecord?> = _selectedHistoryRecord.asStateFlow()

    private val _selectedHistoryDetails = MutableStateFlow<List<AttendanceDetail>>(emptyList())
    val selectedHistoryDetails: StateFlow<List<AttendanceDetail>> = _selectedHistoryDetails.asStateFlow()

    val branches: StateFlow<List<Branch>> = repository.getActiveBranches()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val allBranches: StateFlow<List<Branch>> = repository.getAllBranches()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val allUsers: StateFlow<List<User>> = repository.getAllUsers()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    // Editing existing attendance (Faculty only, before 6 PM IST)
    private val _isEditingExistingRecord = MutableStateFlow(false)
    val isEditingExistingRecord: StateFlow<Boolean> = _isEditingExistingRecord.asStateFlow()

    private val _editingRecordId = MutableStateFlow<String?>(null)
    val editingRecordId: StateFlow<String?> = _editingRecordId.asStateFlow()

    init {
        // Continuous live time ticker
        viewModelScope.launch {
            while (true) {
                _liveTime.value = TimeUtil.getLiveKolkataTime()
                delay(1000)
            }
        }

        // Initialize database with initial users and exact 64 students of 3rd Year IT-C
        viewModelScope.launch {
            repository.initializeDatabaseIfNeeded()
        }
    }

    fun navigateTo(screen: Screen) {
        val stack = _screenStack.value.toMutableList()
        stack.add(screen)
        _screenStack.value = stack
        _activeScreen.value = screen
    }

    fun navigateBack(): Boolean {
        val stack = _screenStack.value.toMutableList()
        if (stack.size > 1) {
            stack.removeAt(stack.size - 1)
            _screenStack.value = stack
            _activeScreen.value = stack.last()
            return true
        }
        return false
    }

    fun clearSnackBar() {
        _snackBarMessage.value = null
    }

    fun showMessage(msg: String) {
        _snackBarMessage.value = msg
    }

    // --- Authentication ---
    fun login(regNo: String, pass: String) {
        viewModelScope.launch {
            _loginError.value = null
            val result = repository.login(regNo, pass)
            result.onSuccess { user ->
                _currentUser.value = user
                _loginError.value = null
                // Set default class if CR
                if (user.role == UserRole.CR) {
                    user.academicYear?.let { _selectedYear.value = it }
                    user.branch?.let { _selectedBranch.value = it }
                    user.section?.let { _selectedSection.value = it }
                }
                _screenStack.value = listOf(Screen.DASHBOARD_YEAR)
                _activeScreen.value = Screen.DASHBOARD_YEAR
            }.onFailure { err ->
                _loginError.value = err.message ?: "Authentication failed"
            }
        }
    }

    fun loginAdminBiometric() {
        viewModelScope.launch {
            val admin = repository.getAdminUser()
            if (admin != null) {
                _currentUser.value = admin
                _loginError.value = null
                _screenStack.value = listOf(Screen.DASHBOARD_YEAR)
                _activeScreen.value = Screen.DASHBOARD_YEAR
                showMessage("Biometric login verified. Welcome, Administrator.")
            } else {
                _loginError.value = "Admin account not found."
            }
        }
    }

    fun logout() {
        _currentUser.value = null
        _loginError.value = null
        _screenStack.value = listOf(Screen.LOGIN)
        _activeScreen.value = Screen.LOGIN
    }

    fun changePassword(oldPass: String, newPass: String, confirmPass: String, onSuccess: () -> Unit) {
        val user = _currentUser.value ?: return
        viewModelScope.launch {
            val result = repository.changePassword(user.userId, oldPass, newPass, confirmPass)
            result.onSuccess {
                showMessage("Password updated successfully.")
                onSuccess()
            }.onFailure { err ->
                showMessage(err.message ?: "Password change failed.")
            }
        }
    }

    // --- Navigation Flow Selections ---
    fun selectYear(year: String) {
        _selectedYear.value = year
        navigateTo(Screen.BRANCH_SELECTION)
    }

    fun selectBranch(branch: String) {
        _selectedBranch.value = branch
        navigateTo(Screen.SECTION_SELECTION)
    }

    fun selectSection(section: String) {
        _selectedSection.value = section
        loadStudentsForCurrentClass()
        navigateTo(Screen.PERIOD_SELECTION)
    }

    fun setPeriodMode(mode: PeriodMode) {
        _periodMode.value = mode
        if (mode == PeriodMode.SINGLE) {
            _selectedPeriods.value = setOf(_selectedPeriods.value.firstOrNull() ?: "Period 1")
        } else {
            // Multiple periods mode requires at least 2 periods
            if (_selectedPeriods.value.size < 2) {
                _selectedPeriods.value = setOf("Period 1", "Period 2")
            }
        }
    }

    fun togglePeriodSelection(period: String) {
        val current = _selectedPeriods.value.toMutableSet()
        if (_periodMode.value == PeriodMode.SINGLE) {
            _selectedPeriods.value = setOf(period)
        } else {
            if (current.contains(period)) {
                if (current.size > 2) { // Keep at least 2 in multiple mode
                    current.remove(period)
                    _selectedPeriods.value = current
                } else {
                    showMessage("Multiple Periods mode requires at least two periods.")
                }
            } else {
                current.add(period)
                _selectedPeriods.value = current
            }
        }
    }

    fun proceedToAttendanceSheet() {
        val mode = _periodMode.value
        val periods = _selectedPeriods.value
        if (mode == PeriodMode.MULTIPLE && periods.size < 2) {
            showMessage("Multiple Periods mode requires at least two periods to be selected.")
            return
        }
        _isEditingExistingRecord.value = false
        _editingRecordId.value = null
        loadStudentsForCurrentClass()
        navigateTo(Screen.ATTENDANCE_SHEET)
    }

    fun loadStudentsForCurrentClass() {
        val year = _selectedYear.value ?: return
        val branch = _selectedBranch.value ?: return
        val section = _selectedSection.value ?: return

        viewModelScope.launch {
            val list = repository.getStudentsSync(year, branch, section)
            _currentStudents.value = list

            // Default: All students marked Present initially, so absentees tab is empty or populated when toggled
            val statuses = mutableMapOf<String, Boolean>()
            list.forEach { s ->
                statuses[s.registrationNumber] = true // default present
            }
            _studentStatuses.value = statuses
            _activeSubTab.value = AttendanceSubTab.ABSENTEES // Mandatory default subtab
        }
    }

    // --- Attendance Marking ---
    fun toggleStudentAttendance(studentRegNo: String) {
        val current = _studentStatuses.value.toMutableMap()
        val currentStatus = current[studentRegNo] ?: true
        current[studentRegNo] = !currentStatus
        _studentStatuses.value = current
    }

    fun markAllPresent() {
        val current = _studentStatuses.value.toMutableMap()
        _currentStudents.value.forEach { s ->
            current[s.registrationNumber] = true
        }
        _studentStatuses.value = current
        showMessage("All students marked Present.")
    }

    fun markAllAbsent() {
        val current = _studentStatuses.value.toMutableMap()
        _currentStudents.value.forEach { s ->
            current[s.registrationNumber] = false
        }
        _studentStatuses.value = current
        showMessage("All students marked Absent.")
    }

    fun setSubTab(tab: AttendanceSubTab) {
        _activeSubTab.value = tab
    }

    fun setSearchQuery(query: String) {
        _searchQuery.value = query
    }

    fun openSaveConfirmation() {
        if (_currentStudents.value.isEmpty()) {
            showMessage("No student records available for this section to mark attendance.")
            return
        }
        _showSaveConfirmDialog.value = true
    }

    fun dismissSaveConfirmation() {
        _showSaveConfirmDialog.value = false
    }

    fun confirmAndSaveAttendance() {
        _showSaveConfirmDialog.value = false
        val user = _currentUser.value ?: return
        val year = _selectedYear.value ?: return
        val branch = _selectedBranch.value ?: return
        val section = _selectedSection.value ?: return
        val periods = _selectedPeriods.value.toList()
        val students = _currentStudents.value
        val statuses = _studentStatuses.value

        viewModelScope.launch {
            _isSaving.value = true
            if (_isEditingExistingRecord.value && _editingRecordId.value != null) {
                // Updating existing record
                val result = repository.updateSavedAttendance(
                    attendanceId = _editingRecordId.value!!,
                    studentStatuses = statuses,
                    students = students,
                    user = user
                )
                _isSaving.value = false
                result.onSuccess { updatedRecord ->
                    _lastSavedRecord.value = updatedRecord
                    val details = repository.getAttendanceDetailsSync(updatedRecord.attendanceId)
                    _generatedReportText.value = repository.formatFacultyReport(updatedRecord, details)
                    showMessage("Attendance record successfully updated before 6:00 PM deadline.")
                    navigateTo(Screen.FACULTY_REPORT)
                }.onFailure { err ->
                    showMessage(err.message ?: "Failed to update attendance.")
                }
            } else {
                // New Save (Single or Multiple periods)
                val result = repository.saveAttendance(
                    academicYear = year,
                    branch = branch,
                    section = section,
                    periods = periods,
                    studentStatuses = statuses,
                    students = students,
                    user = user
                )
                _isSaving.value = false
                result.onSuccess { savedList ->
                    if (savedList.isNotEmpty()) {
                        val firstRecord = savedList.first()
                        _lastSavedRecord.value = firstRecord
                        val details = repository.getAttendanceDetailsSync(firstRecord.attendanceId)
                        _generatedReportText.value = repository.formatFacultyReport(firstRecord, details)
                        showMessage("Attendance saved successfully (${savedList.size} record${if (savedList.size > 1) "s" else ""}).")
                        navigateTo(Screen.FACULTY_REPORT)
                    }
                }.onFailure { err ->
                    showMessage(err.message ?: "Failed to save attendance.")
                }
            }
        }
    }

    // --- History & Report Inspection ---
    fun openHistoryRecord(record: AttendanceRecord) {
        _selectedHistoryRecord.value = record
        viewModelScope.launch {
            val details = repository.getAttendanceDetailsSync(record.attendanceId)
            _selectedHistoryDetails.value = details
            _generatedReportText.value = repository.formatFacultyReport(record, details)
            navigateTo(Screen.HISTORY_DETAIL)
        }
    }

    fun startEditingHistoryRecord(record: AttendanceRecord) {
        val user = _currentUser.value ?: return
        if (user.role == UserRole.CR) {
            showMessage("CR is strictly not allowed to modify saved attendance.")
            return
        }
        if (user.role == UserRole.FACULTY && !TimeUtil.canFacultyEditRecord(record.createdAt)) {
            showMessage("Editing deadline (6:00 PM IST on attendance date) has passed. Record is permanently locked.")
            return
        }

        viewModelScope.launch {
            val details = repository.getAttendanceDetailsSync(record.attendanceId)
            val students = repository.getStudentsSync(record.academicYear, record.branch, record.section)
            _selectedYear.value = record.academicYear
            _selectedBranch.value = record.branch
            _selectedSection.value = record.section
            _selectedPeriods.value = setOf(record.period)
            _periodMode.value = PeriodMode.SINGLE
            _currentStudents.value = students

            val statusMap = mutableMapOf<String, Boolean>()
            details.forEach { d ->
                statusMap[d.studentRegNo] = d.isPresent
            }
            _studentStatuses.value = statusMap
            _isEditingExistingRecord.value = true
            _editingRecordId.value = record.attendanceId
            _activeSubTab.value = AttendanceSubTab.ABSENTEES

            navigateTo(Screen.ATTENDANCE_SHEET)
        }
    }

    // --- Student Management (CR & Admin) ---
    fun addStudent(regNo: String, name: String, onSuccess: () -> Unit) {
        val year = _selectedYear.value ?: return
        val branch = _selectedBranch.value ?: return
        val section = _selectedSection.value ?: return

        viewModelScope.launch {
            val result = repository.addStudent(regNo, name, year, branch, section)
            result.onSuccess {
                showMessage("Student $name ($regNo) added successfully.")
                loadStudentsForCurrentClass()
                onSuccess()
            }.onFailure { err ->
                showMessage(err.message ?: "Failed to add student.")
            }
        }
    }

    fun updateStudent(student: Student, newName: String, onSuccess: () -> Unit) {
        viewModelScope.launch {
            val result = repository.updateStudent(student.copy(name = newName.trim()))
            result.onSuccess {
                showMessage("Student record updated.")
                loadStudentsForCurrentClass()
                onSuccess()
            }.onFailure { err ->
                showMessage(err.message ?: "Failed to update student.")
            }
        }
    }

    fun deleteStudent(student: Student) {
        viewModelScope.launch {
            val result = repository.deleteStudent(student)
            result.onSuccess {
                showMessage("Student ${student.name} deleted.")
                loadStudentsForCurrentClass()
            }.onFailure { err ->
                showMessage(err.message ?: "Failed to delete student.")
            }
        }
    }

    // --- Admin Functions ---
    fun addBranch(code: String, name: String, onSuccess: () -> Unit) {
        viewModelScope.launch {
            val result = repository.addBranch(code, name)
            result.onSuccess {
                showMessage("Branch $code ($name) added successfully.")
                onSuccess()
            }.onFailure { err ->
                showMessage(err.message ?: "Failed to add branch.")
            }
        }
    }

    fun createAccount(
        regNo: String,
        name: String,
        initialPass: String,
        role: UserRole,
        academicYear: String?,
        branch: String?,
        section: String?,
        onSuccess: () -> Unit
    ) {
        viewModelScope.launch {
            val result = repository.createAccount(regNo, name, initialPass, role, academicYear, branch, section)
            result.onSuccess {
                showMessage("Account for $name ($regNo) created successfully.")
                onSuccess()
            }.onFailure { err ->
                showMessage(err.message ?: "Failed to create account.")
            }
        }
    }

    fun resetPassword(userId: String, newPass: String, onSuccess: () -> Unit) {
        viewModelScope.launch {
            val result = repository.resetUserPassword(userId, newPass)
            result.onSuccess {
                showMessage("Password has been reset.")
                onSuccess()
            }.onFailure { err ->
                showMessage(err.message ?: "Failed to reset password.")
            }
        }
    }
}
