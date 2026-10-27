package com.example

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import com.example.data.model.UserRole
import com.example.data.repository.InitialData
import com.example.util.TimeUtil
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [36])
class ExampleRobolectricTest {

    @Test
    fun `read string from context`() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        val appName = context.getString(R.string.app_name)
        assertEquals("Attendance Manager", appName)
    }

    @Test
    fun `verify exact 64 initial students in 3rd Year IT-C dataset`() {
        val students = InitialData.INITIAL_3RD_YEAR_IT_C_STUDENTS
        assertEquals(64, students.size)
        assertEquals("24B01A12D2", students.first().registrationNumber)
        assertEquals("PERURU KOUSALYA", students.first().name)
        assertEquals("24B01A12J5", students.last().registrationNumber)
        assertEquals("YERUVA PRANATHI", students.last().name)
    }

    @Test
    fun `verify CRs are strictly I1 and F7 only`() {
        val crUsers = InitialData.INITIAL_USERS.filter { it.role == UserRole.CR }
        assertEquals(2, crUsers.size)
        val regNos = crUsers.map { it.registrationNumber }.toSet()
        assertTrue(regNos.contains("24B01A12I1")) // I1
        assertTrue(regNos.contains("24B01A12F7")) // F7
    }

    @Test
    fun `verify password hashing and matching`() {
        val hash = InitialData.hashPassword("Faculty@123")
        assertEquals(hash, InitialData.hashPassword("Faculty@123"))
        assertTrue(hash != InitialData.hashPassword("WrongPassword"))
    }

    @Test
    fun `verify 7-day retention expiry calculation`() {
        val now = System.currentTimeMillis()
        val sixDaysAgo = now - (6L * 24L * 60L * 60L * 1000L)
        val eightDaysAgo = now - (8L * 24L * 60L * 60L * 1000L)

        assertFalse(TimeUtil.isRecordExpired(sixDaysAgo))
        assertTrue(TimeUtil.isRecordExpired(eightDaysAgo))
    }
}
