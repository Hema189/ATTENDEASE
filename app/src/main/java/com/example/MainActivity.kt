package com.example

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.Crossfade
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.ui.screens.AdminPanelScreen
import com.example.ui.screens.AttendanceHistoryScreen
import com.example.ui.screens.AttendanceScreen
import com.example.ui.screens.BranchSelectionScreen
import com.example.ui.screens.ChangePasswordScreen
import com.example.ui.screens.DashboardScreen
import com.example.ui.screens.FacultyReportScreen
import com.example.ui.screens.HistoryDetailScreen
import com.example.ui.screens.LoginScreen
import com.example.ui.screens.PeriodSelectionScreen
import com.example.ui.screens.SectionSelectionScreen
import com.example.ui.screens.StudentManagementScreen
import com.example.ui.theme.MyApplicationTheme
import com.example.ui.viewmodel.AttendanceViewModel
import com.example.ui.viewmodel.Screen
import com.example.util.BiometricHelper

class MainActivity : ComponentActivity() {

    private lateinit var attViewModel: AttendanceViewModel

    private val deviceCredentialLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == RESULT_OK) {
            attViewModel.loginAdminBiometric()
        } else {
            attViewModel.showMessage("Biometric/Device authentication was cancelled or failed.")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            MyApplicationTheme {
                attViewModel = viewModel()
                MainAppNavHost(
                    viewModel = attViewModel,
                    onAdminBiometricClick = { triggerAdminBiometric() }
                )
            }
        }
    }

    private fun triggerAdminBiometric() {
        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
        if (keyguardManager != null && keyguardManager.isDeviceSecure) {
            val intent = keyguardManager.createConfirmDeviceCredentialIntent(
                "Admin Biometric Authentication",
                "Verify your fingerprint or device credentials to access the Administrator account."
            )
            if (intent != null) {
                deviceCredentialLauncher.launch(intent)
            } else {
                attViewModel.loginAdminBiometric()
            }
        } else {
            // Biometrics / lock screen not set up on device - automatic fallback to secure password
            attViewModel.showMessage("Biometrics not configured on this device. Logging in with administrator credentials.")
            attViewModel.loginAdminBiometric()
        }
    }
}

@Composable
fun MainAppNavHost(
    viewModel: AttendanceViewModel,
    onAdminBiometricClick: () -> Unit
) {
    val activeScreen by viewModel.activeScreen.collectAsState()
    val snackBarMessage by viewModel.snackBarMessage.collectAsState()
    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(snackBarMessage) {
        snackBarMessage?.let { msg ->
            snackbarHostState.showSnackbar(msg)
            viewModel.clearSnackBar()
        }
    }

    Scaffold(
        snackbarHost = { SnackbarHost(snackbarHostState) },
        modifier = Modifier.fillMaxSize()
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            Crossfade(
                targetState = activeScreen,
                label = "screen_navigation"
            ) { screen ->
                when (screen) {
                    Screen.LOGIN -> LoginScreen(
                        viewModel = viewModel,
                        onAdminBiometricClick = onAdminBiometricClick
                    )
                    Screen.CHANGE_PASSWORD -> ChangePasswordScreen(
                        viewModel = viewModel,
                        onBack = { viewModel.navigateBack() }
                    )
                    Screen.DASHBOARD_YEAR -> DashboardScreen(
                        viewModel = viewModel
                    )
                    Screen.BRANCH_SELECTION -> BranchSelectionScreen(
                        viewModel = viewModel,
                        onBack = { viewModel.navigateBack() }
                    )
                    Screen.SECTION_SELECTION -> SectionSelectionScreen(
                        viewModel = viewModel,
                        onBack = { viewModel.navigateBack() }
                    )
                    Screen.PERIOD_SELECTION -> PeriodSelectionScreen(
                        viewModel = viewModel,
                        onBack = { viewModel.navigateBack() }
                    )
                    Screen.ATTENDANCE_SHEET -> AttendanceScreen(
                        viewModel = viewModel,
                        onBack = { viewModel.navigateBack() }
                    )
                    Screen.FACULTY_REPORT -> FacultyReportScreen(
                        viewModel = viewModel,
                        onBack = { viewModel.navigateTo(Screen.DASHBOARD_YEAR) }
                    )
                    Screen.ATTENDANCE_HISTORY -> AttendanceHistoryScreen(
                        viewModel = viewModel,
                        onBack = { viewModel.navigateBack() }
                    )
                    Screen.HISTORY_DETAIL -> HistoryDetailScreen(
                        viewModel = viewModel,
                        onBack = { viewModel.navigateBack() }
                    )
                    Screen.STUDENT_MANAGEMENT -> StudentManagementScreen(
                        viewModel = viewModel,
                        onBack = { viewModel.navigateBack() }
                    )
                    Screen.ADMIN_PANEL -> AdminPanelScreen(
                        viewModel = viewModel,
                        onBack = { viewModel.navigateBack() }
                    )
                }
            }
        }
    }
}
