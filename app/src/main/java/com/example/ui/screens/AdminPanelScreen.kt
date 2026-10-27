package com.example.ui.screens

import androidx.activity.compose.BackHandler
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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Key
import androidx.compose.material.icons.filled.LockReset
import androidx.compose.material.icons.filled.PersonAdd
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
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
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.Branch
import com.example.data.model.User
import com.example.data.model.UserRole
import com.example.ui.viewmodel.AttendanceViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AdminPanelScreen(
    viewModel: AttendanceViewModel,
    onBack: () -> Unit
) {
    BackHandler { onBack() }

    var selectedAdminTab by remember { mutableIntStateOf(0) } // 0: User Accounts, 1: Configure Branches

    val allUsers by viewModel.allUsers.collectAsState()
    val allBranches by viewModel.allBranches.collectAsState()

    var showCreateUserDialog by remember { mutableStateOf(false) }
    var showAddBranchDialog by remember { mutableStateOf(false) }
    var userToReset by remember { mutableStateOf<User?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Campus Administration", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(imageVector = Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
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
            TabRow(
                selectedTabIndex = selectedAdminTab,
                containerColor = MaterialTheme.colorScheme.surface
            ) {
                Tab(
                    selected = selectedAdminTab == 0,
                    onClick = { selectedAdminTab = 0 },
                    text = { Text("Faculty & CR Accounts (${allUsers.size})", fontWeight = FontWeight.Bold) }
                )
                Tab(
                    selected = selectedAdminTab == 1,
                    onClick = { selectedAdminTab = 1 },
                    text = { Text("Configured Branches (${allBranches.size})", fontWeight = FontWeight.Bold) }
                )
            }

            if (selectedAdminTab == 0) {
                // User Accounts Management
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(16.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "Manage User Credentials & Roles",
                            style = MaterialTheme.typography.titleSmall,
                            fontWeight = FontWeight.Bold
                        )
                        Button(
                            onClick = { showCreateUserDialog = true },
                            shape = RoundedCornerShape(8.dp)
                        ) {
                            Icon(imageVector = Icons.Default.PersonAdd, contentDescription = null, modifier = Modifier.size(16.dp))
                            Spacer(modifier = Modifier.width(6.dp))
                            Text("New Account")
                        }
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    LazyColumn(modifier = Modifier.fillMaxSize()) {
                        items(allUsers, key = { it.userId }) { user ->
                            Card(
                                shape = RoundedCornerShape(12.dp),
                                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                                elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(vertical = 4.dp)
                            ) {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(14.dp),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Column {
                                        Row(verticalAlignment = Alignment.CenterVertically) {
                                            Text(
                                                text = user.name,
                                                fontWeight = FontWeight.Bold,
                                                style = MaterialTheme.typography.bodyMedium
                                            )
                                            Spacer(modifier = Modifier.width(8.dp))
                                            Surface(
                                                shape = RoundedCornerShape(4.dp),
                                                color = MaterialTheme.colorScheme.primaryContainer
                                            ) {
                                                Text(
                                                    text = user.role.name,
                                                    fontSize = 10.sp,
                                                    fontWeight = FontWeight.Bold,
                                                    color = MaterialTheme.colorScheme.onPrimaryContainer,
                                                    modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                                                )
                                            }
                                        }
                                        Text(
                                            text = "Reg No: ${user.registrationNumber}",
                                            style = MaterialTheme.typography.bodySmall,
                                            color = MaterialTheme.colorScheme.onSurfaceVariant
                                        )
                                        if (user.role == UserRole.CR) {
                                            Text(
                                                text = "Assigned Class: ${user.academicYear} ${user.branch}-${user.section}",
                                                style = MaterialTheme.typography.labelSmall,
                                                color = MaterialTheme.colorScheme.secondary
                                            )
                                        }
                                    }

                                    IconButton(onClick = { userToReset = user }) {
                                        Icon(imageVector = Icons.Default.Key, contentDescription = "Reset Password")
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                // Branches Management
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(16.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "System Branches Configuration",
                            style = MaterialTheme.typography.titleSmall,
                            fontWeight = FontWeight.Bold
                        )
                        Button(
                            onClick = { showAddBranchDialog = true },
                            shape = RoundedCornerShape(8.dp)
                        ) {
                            Icon(imageVector = Icons.Default.Add, contentDescription = null, modifier = Modifier.size(16.dp))
                            Spacer(modifier = Modifier.width(6.dp))
                            Text("Add Branch")
                        }
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    LazyColumn(modifier = Modifier.fillMaxSize()) {
                        items(allBranches, key = { it.code }) { branch ->
                            Card(
                                shape = RoundedCornerShape(12.dp),
                                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                                elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(vertical = 4.dp)
                            ) {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(14.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Surface(
                                        shape = RoundedCornerShape(6.dp),
                                        color = MaterialTheme.colorScheme.primaryContainer,
                                        modifier = Modifier.size(40.dp)
                                    ) {
                                        Box(contentAlignment = Alignment.Center) {
                                            Text(
                                                text = branch.code,
                                                fontWeight = FontWeight.Bold,
                                                fontSize = 13.sp,
                                                color = MaterialTheme.colorScheme.onPrimaryContainer
                                            )
                                        }
                                    }
                                    Spacer(modifier = Modifier.width(14.dp))
                                    Column {
                                        Text(branch.name, fontWeight = FontWeight.Bold)
                                        Text("Status: Active", fontSize = 11.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Create User Dialog
    if (showCreateUserDialog) {
        var newRegNo by remember { mutableStateOf("") }
        var newName by remember { mutableStateOf("") }
        var newPass by remember { mutableStateOf("Welcome@123") }
        var role by remember { mutableStateOf(UserRole.FACULTY) }
        var roleMenuExpanded by remember { mutableStateOf(false) }

        var assignedYear by remember { mutableStateOf("3rd Year") }
        var assignedBranch by remember { mutableStateOf("IT") }
        var assignedSection by remember { mutableStateOf("Section C") }

        AlertDialog(
            onDismissRequest = { showCreateUserDialog = false },
            title = { Text("Create Faculty or CR Account", fontWeight = FontWeight.Bold) },
            text = {
                Column {
                    OutlinedTextField(
                        value = newRegNo,
                        onValueChange = { newRegNo = it },
                        label = { Text("Registration Number") },
                        placeholder = { Text("e.g. FAC002 or 24B01A12...") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedTextField(
                        value = newName,
                        onValueChange = { newName = it },
                        label = { Text("User Full Name") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedTextField(
                        value = newPass,
                        onValueChange = { newPass = it },
                        label = { Text("Initial Assigned Password") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))

                    // Role Picker
                    ExposedDropdownMenuBox(
                        expanded = roleMenuExpanded,
                        onExpandedChange = { roleMenuExpanded = !roleMenuExpanded }
                    ) {
                        OutlinedTextField(
                            value = role.name,
                            onValueChange = {},
                            readOnly = true,
                            label = { Text("Assigned Role") },
                            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = roleMenuExpanded) },
                            modifier = Modifier.fillMaxWidth().menuAnchor()
                        )
                        ExposedDropdownMenu(
                            expanded = roleMenuExpanded,
                            onDismissRequest = { roleMenuExpanded = false }
                        ) {
                            DropdownMenuItem(
                                text = { Text("FACULTY") },
                                onClick = {
                                    role = UserRole.FACULTY
                                    roleMenuExpanded = false
                                }
                            )
                            DropdownMenuItem(
                                text = { Text("CR (Class Representative)") },
                                onClick = {
                                    role = UserRole.CR
                                    roleMenuExpanded = false
                                }
                            )
                        }
                    }

                    if (role == UserRole.CR) {
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "CR Default Assigned Class: 3rd Year IT Section C",
                            fontSize = 11.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            },
            confirmButton = {
                Button(
                    onClick = {
                        viewModel.createAccount(
                            regNo = newRegNo,
                            name = newName,
                            initialPass = newPass,
                            role = role,
                            academicYear = if (role == UserRole.CR) assignedYear else null,
                            branch = if (role == UserRole.CR) assignedBranch else null,
                            section = if (role == UserRole.CR) assignedSection else null,
                            onSuccess = { showCreateUserDialog = false }
                        )
                    },
                    enabled = newRegNo.isNotBlank() && newName.isNotBlank() && newPass.isNotBlank()
                ) {
                    Text("Create Account")
                }
            },
            dismissButton = {
                OutlinedButton(onClick = { showCreateUserDialog = false }) {
                    Text("Cancel")
                }
            }
        )
    }

    // Add Branch Dialog
    if (showAddBranchDialog) {
        var branchCode by remember { mutableStateOf("") }
        var branchName by remember { mutableStateOf("") }

        AlertDialog(
            onDismissRequest = { showAddBranchDialog = false },
            title = { Text("Add New Academic Branch", fontWeight = FontWeight.Bold) },
            text = {
                Column {
                    OutlinedTextField(
                        value = branchCode,
                        onValueChange = { branchCode = it },
                        label = { Text("Branch Code") },
                        placeholder = { Text("e.g. AI-DS, CHEM") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedTextField(
                        value = branchName,
                        onValueChange = { branchName = it },
                        label = { Text("Branch Full Name") },
                        placeholder = { Text("e.g. Artificial Intelligence & Data Science") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            },
            confirmButton = {
                Button(
                    onClick = {
                        viewModel.addBranch(branchCode, branchName) {
                            showAddBranchDialog = false
                        }
                    },
                    enabled = branchCode.isNotBlank() && branchName.isNotBlank()
                ) {
                    Text("Save Branch")
                }
            },
            dismissButton = {
                OutlinedButton(onClick = { showAddBranchDialog = false }) {
                    Text("Cancel")
                }
            }
        )
    }

    // Reset Password Dialog
    if (userToReset != null) {
        val user = userToReset!!
        var resetPass by remember { mutableStateOf("NewPass@123") }

        AlertDialog(
            onDismissRequest = { userToReset = null },
            title = { Text("Reset User Password", fontWeight = FontWeight.Bold) },
            text = {
                Column {
                    Text("User: ${user.name} (${user.registrationNumber})")
                    Spacer(modifier = Modifier.height(10.dp))
                    OutlinedTextField(
                        value = resetPass,
                        onValueChange = { resetPass = it },
                        label = { Text("New Assigned Password") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            },
            confirmButton = {
                Button(
                    onClick = {
                        viewModel.resetPassword(user.userId, resetPass) {
                            userToReset = null
                        }
                    },
                    enabled = resetPass.isNotBlank()
                ) {
                    Text("Reset Password")
                }
            },
            dismissButton = {
                OutlinedButton(onClick = { userToReset = null }) {
                    Text("Cancel")
                }
            }
        )
    }
}
