package com.example.ui.screens

import androidx.activity.compose.BackHandler
import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.AccessTime
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.CalendarToday
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.DoneAll
import androidx.compose.material.icons.filled.Save
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ElevatedCard
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.Student
import com.example.data.model.UserRole
import com.example.ui.theme.AbsentRed
import com.example.ui.theme.AbsentRedBg
import com.example.ui.theme.PresentGreen
import com.example.ui.theme.PresentGreenBg
import com.example.ui.viewmodel.AttendanceSubTab
import com.example.ui.viewmodel.AttendanceViewModel
import com.example.ui.viewmodel.Screen

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AttendanceScreen(
    viewModel: AttendanceViewModel,
    onBack: () -> Unit
) {
    BackHandler { onBack() }

    val liveTime by viewModel.liveTime.collectAsState()
    val currentUser by viewModel.currentUser.collectAsState()
    val selectedYear by viewModel.selectedYear.collectAsState()
    val selectedBranch by viewModel.selectedBranch.collectAsState()
    val selectedSection by viewModel.selectedSection.collectAsState()
    val selectedPeriods by viewModel.selectedPeriods.collectAsState()

    val students by viewModel.currentStudents.collectAsState()
    val studentStatuses by viewModel.studentStatuses.collectAsState()
    val activeSubTab by viewModel.activeSubTab.collectAsState()
    val searchQuery by viewModel.searchQuery.collectAsState()
    val showSaveConfirmDialog by viewModel.showSaveConfirmDialog.collectAsState()
    val isEditingExisting by viewModel.isEditingExistingRecord.collectAsState()

    val totalStudents = students.size
    val presentCount = students.count { studentStatuses[it.registrationNumber] == true }
    val absentCount = totalStudents - presentCount

    // Filter students by search and active sub-tab (Absentees vs Present)
    val filteredStudents = students
        .filter { student ->
            if (searchQuery.isBlank()) true
            else {
                student.name.contains(searchQuery, ignoreCase = true) ||
                        student.registrationNumber.contains(searchQuery, ignoreCase = true)
            }
        }
        .filter { student ->
            val isPresent = studentStatuses[student.registrationNumber] ?: true
            if (activeSubTab == AttendanceSubTab.ABSENTEES) {
                !isPresent // Absent students
            } else {
                isPresent // Present students
            }
        }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            text = if (isEditingExisting) "Edit Attendance" else "Mark Attendance",
                            fontWeight = FontWeight.Bold,
                            fontSize = 18.sp
                        )
                        Text(
                            text = "$selectedYear $selectedBranch-${selectedSection?.replace("Section ", "")} • ${selectedPeriods.joinToString(", ")}",
                            fontSize = 12.sp,
                            color = MaterialTheme.colorScheme.onPrimary.copy(alpha = 0.85f)
                        )
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(imageVector = Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    if (students.isNotEmpty()) {
                        Button(
                            onClick = { viewModel.openSaveConfirmation() },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = MaterialTheme.colorScheme.secondary
                            ),
                            shape = RoundedCornerShape(8.dp),
                            modifier = Modifier
                                .padding(end = 8.dp)
                                .testTag("button_save_attendance")
                        ) {
                            Icon(imageVector = Icons.Default.Save, contentDescription = null, modifier = Modifier.size(16.dp))
                            Spacer(modifier = Modifier.width(4.dp))
                            Text("Save", fontWeight = FontWeight.Bold)
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary,
                    navigationIconContentColor = MaterialTheme.colorScheme.onPrimary
                )
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // Live Date & Time Header (Asia/Kolkata)
            Surface(
                color = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.5f),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 8.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.CalendarToday,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.primary,
                            modifier = Modifier.size(14.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = "${liveTime.dayOfWeek}, ${liveTime.dateFormatted}",
                            style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.SemiBold),
                            color = MaterialTheme.colorScheme.onPrimaryContainer
                        )
                    }

                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.AccessTime,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.secondary,
                            modifier = Modifier.size(14.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = liveTime.timeFormatted,
                            style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.Bold),
                            color = MaterialTheme.colorScheme.primary
                        )
                    }
                }
            }

            // Real-time Counts Summary Bar
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Card(
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(10.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
                ) {
                    Column(
                        modifier = Modifier.padding(vertical = 8.dp, horizontal = 10.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text("TOTAL", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.onSurfaceVariant)
                        Text("$totalStudents", fontSize = 18.sp, fontWeight = FontWeight.ExtraBold, color = MaterialTheme.colorScheme.onSurface)
                    }
                }

                Card(
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(10.dp),
                    colors = CardDefaults.cardColors(containerColor = PresentGreenBg)
                ) {
                    Column(
                        modifier = Modifier.padding(vertical = 8.dp, horizontal = 10.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text("PRESENT", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = PresentGreen)
                        Text("$presentCount", fontSize = 18.sp, fontWeight = FontWeight.ExtraBold, color = PresentGreen)
                    }
                }

                Card(
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(10.dp),
                    colors = CardDefaults.cardColors(containerColor = AbsentRedBg)
                ) {
                    Column(
                        modifier = Modifier.padding(vertical = 8.dp, horizontal = 10.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text("ABSENT", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = AbsentRed)
                        Text("$absentCount", fontSize = 18.sp, fontWeight = FontWeight.ExtraBold, color = AbsentRed)
                    }
                }
            }

            // Search Bar
            OutlinedTextField(
                value = searchQuery,
                onValueChange = { viewModel.setSearchQuery(it) },
                placeholder = { Text("Search by name or registration number...") },
                leadingIcon = {
                    Icon(imageVector = Icons.Default.Search, contentDescription = "Search", modifier = Modifier.size(18.dp))
                },
                trailingIcon = {
                    if (searchQuery.isNotEmpty()) {
                        IconButton(onClick = { viewModel.setSearchQuery("") }) {
                            Icon(imageVector = Icons.Default.Clear, contentDescription = "Clear", modifier = Modifier.size(18.dp))
                        }
                    }
                },
                singleLine = true,
                shape = RoundedCornerShape(10.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 4.dp)
                    .testTag("search_student_field")
            )

            // Subtabs: ABSENTEES (Default) and PRESENT
            TabRow(
                selectedTabIndex = if (activeSubTab == AttendanceSubTab.ABSENTEES) 0 else 1,
                containerColor = MaterialTheme.colorScheme.surface,
                contentColor = MaterialTheme.colorScheme.primary,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 4.dp)
            ) {
                Tab(
                    selected = activeSubTab == AttendanceSubTab.ABSENTEES,
                    onClick = { viewModel.setSubTab(AttendanceSubTab.ABSENTEES) },
                    text = {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                text = "ABSENTEES ($absentCount)",
                                fontWeight = if (activeSubTab == AttendanceSubTab.ABSENTEES) FontWeight.Bold else FontWeight.Normal,
                                color = if (activeSubTab == AttendanceSubTab.ABSENTEES) AbsentRed else MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    },
                    modifier = Modifier.testTag("tab_absentees")
                )

                Tab(
                    selected = activeSubTab == AttendanceSubTab.PRESENT,
                    onClick = { viewModel.setSubTab(AttendanceSubTab.PRESENT) },
                    text = {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                text = "PRESENT ($presentCount)",
                                fontWeight = if (activeSubTab == AttendanceSubTab.PRESENT) FontWeight.Bold else FontWeight.Normal,
                                color = if (activeSubTab == AttendanceSubTab.PRESENT) PresentGreen else MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    },
                    modifier = Modifier.testTag("tab_present")
                )
            }

            // Fast classroom action bar
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 4.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = if (activeSubTab == AttendanceSubTab.ABSENTEES)
                        "Showing absentees (tap to mark present)"
                    else
                        "Showing present (tap to mark absent)",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    OutlinedButton(
                        onClick = { viewModel.markAllPresent() },
                        shape = RoundedCornerShape(6.dp),
                        modifier = Modifier.height(30.dp)
                    ) {
                        Text("All Present", fontSize = 11.sp)
                    }
                    OutlinedButton(
                        onClick = { viewModel.markAllAbsent() },
                        shape = RoundedCornerShape(6.dp),
                        modifier = Modifier.height(30.dp)
                    ) {
                        Text("All Absent", fontSize = 11.sp)
                    }
                }
            }

            // Empty Student Records State (Strict requirement: Empty for sections other than 3rd Year IT-C)
            if (students.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(32.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.outline,
                            modifier = Modifier.size(56.dp)
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = "No student records available for this section.",
                            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                            color = MaterialTheme.colorScheme.onSurface,
                            textAlign = androidx.compose.ui.text.style.TextAlign.Center
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "As per system data policy, only 3rd Year IT-C is initially loaded.",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            textAlign = androidx.compose.ui.text.style.TextAlign.Center
                        )

                        // Add Student button for authorized users (CR & Admin)
                        if (currentUser?.role == UserRole.CR || currentUser?.role == UserRole.ADMIN) {
                            Spacer(modifier = Modifier.height(20.dp))
                            Button(
                                onClick = { viewModel.navigateTo(Screen.STUDENT_MANAGEMENT) },
                                shape = RoundedCornerShape(8.dp)
                            ) {
                                Icon(imageVector = Icons.Default.Add, contentDescription = null)
                                Spacer(modifier = Modifier.width(6.dp))
                                Text("Add Student Record")
                            }
                        }
                    }
                }
            } else if (filteredStudents.isEmpty()) {
                // Empty in active tab (e.g. 0 absentees)
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(32.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            imageVector = if (activeSubTab == AttendanceSubTab.ABSENTEES) Icons.Default.DoneAll else Icons.Default.Close,
                            contentDescription = null,
                            tint = if (activeSubTab == AttendanceSubTab.ABSENTEES) PresentGreen else MaterialTheme.colorScheme.outline,
                            modifier = Modifier.size(48.dp)
                        )
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            text = if (activeSubTab == AttendanceSubTab.ABSENTEES) {
                                if (searchQuery.isNotEmpty()) "No absentees matching '$searchQuery'"
                                else "No Absentees! All students are currently marked Present."
                            } else {
                                if (searchQuery.isNotEmpty()) "No present students matching '$searchQuery'"
                                else "All students are currently marked Absent."
                            },
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            textAlign = androidx.compose.ui.text.style.TextAlign.Center
                        )
                    }
                }
            } else {
                // Student Attendance List (in exact provided order)
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(horizontal = 16.dp, vertical = 6.dp)
                ) {
                    items(
                        items = filteredStudents,
                        key = { it.registrationNumber }
                    ) { student ->
                        val isPresent = studentStatuses[student.registrationNumber] ?: true

                        StudentAttendanceItem(
                            student = student,
                            isPresent = isPresent,
                            onToggle = { viewModel.toggleStudentAttendance(student.registrationNumber) }
                        )
                    }
                }
            }
        }
    }

    // Save Confirmation Dialog
    if (showSaveConfirmDialog) {
        SaveConfirmDialog(
            liveTime = liveTime,
            academicYear = selectedYear ?: "",
            branch = selectedBranch ?: "",
            section = selectedSection ?: "",
            periods = selectedPeriods.toList(),
            totalStudents = totalStudents,
            presentCount = presentCount,
            absentCount = absentCount,
            onConfirm = { viewModel.confirmAndSaveAttendance() },
            onDismiss = { viewModel.dismissSaveConfirmation() }
        )
    }
}

@Composable
private fun StudentAttendanceItem(
    student: Student,
    isPresent: Boolean,
    onToggle: () -> Unit
) {
    val bgColor by animateColorAsState(
        targetValue = if (isPresent) PresentGreenBg.copy(alpha = 0.35f) else AbsentRedBg.copy(alpha = 0.45f),
        label = "bgColor"
    )

    Card(
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = bgColor),
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp)
            .clip(RoundedCornerShape(12.dp))
            .clickable { onToggle() }
            .testTag("student_item_${student.registrationNumber}")
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 14.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.weight(1f)
            ) {
                // Serial Number Badge
                Surface(
                    shape = CircleShape,
                    color = MaterialTheme.colorScheme.surfaceVariant,
                    modifier = Modifier.size(32.dp)
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Text(
                            text = "${student.serialNo}",
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }

                Spacer(modifier = Modifier.width(12.dp))

                Column {
                    Text(
                        text = student.registrationNumber,
                        style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.Bold),
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Text(
                        text = student.name,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            // Attendance Toggle Action Button
            Surface(
                shape = RoundedCornerShape(8.dp),
                color = if (isPresent) PresentGreen else AbsentRed,
                modifier = Modifier
                    .clip(RoundedCornerShape(8.dp))
                    .clickable { onToggle() }
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = if (isPresent) Icons.Default.Check else Icons.Default.Close,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.onPrimary,
                        modifier = Modifier.size(14.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = if (isPresent) "PRESENT" else "ABSENT",
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onPrimary
                    )
                }
            }
        }
    }
}
