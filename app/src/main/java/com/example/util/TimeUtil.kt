package com.example.util

import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime
import java.time.ZoneId
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.util.Locale

object TimeUtil {
    val KOLKATA_ZONE: ZoneId = ZoneId.of("Asia/Kolkata")
    private val DATE_FORMATTER = DateTimeFormatter.ofPattern("dd MMMM yyyy", Locale.ENGLISH)
    private val SHORT_DATE_FORMATTER = DateTimeFormatter.ofPattern("dd-MM-yyyy", Locale.ENGLISH)
    private val DAY_FORMATTER = DateTimeFormatter.ofPattern("EEEE", Locale.ENGLISH)
    private val TIME_FORMATTER = DateTimeFormatter.ofPattern("hh:mm:ss a", Locale.ENGLISH)
    private val SHORT_TIME_FORMATTER = DateTimeFormatter.ofPattern("hh:mm a", Locale.ENGLISH)

    data class LiveTimeState(
        val dateFormatted: String,
        val dayOfWeek: String,
        val timeFormatted: String,
        val shortTime: String,
        val dateKey: String,
        val epochMillis: Long
    )

    fun getCurrentKolkataZonedDateTime(): ZonedDateTime {
        return ZonedDateTime.now(KOLKATA_ZONE)
    }

    fun getLiveKolkataTime(): LiveTimeState {
        val now = getCurrentKolkataZonedDateTime()
        return LiveTimeState(
            dateFormatted = now.format(DATE_FORMATTER),
            dayOfWeek = now.format(DAY_FORMATTER),
            timeFormatted = "${now.format(TIME_FORMATTER)} IST",
            shortTime = now.format(SHORT_TIME_FORMATTER),
            dateKey = now.format(DateTimeFormatter.ISO_LOCAL_DATE),
            epochMillis = now.toInstant().toEpochMilli()
        )
    }

    /**
     * Requirement: Faculty can modify saved attendance only before 6:00 PM (18:00) on the same attendance date in Asia/Kolkata.
     * At or after 6:00 PM, saved attendance is permanently read-only.
     */
    fun canFacultyEditRecord(recordCreatedAtMillis: Long): Boolean {
        val recordZdt = Instant.ofEpochMilli(recordCreatedAtMillis).atZone(KOLKATA_ZONE)
        val nowZdt = getCurrentKolkataZonedDateTime()

        // Must be on the exact same calendar date in Asia/Kolkata
        val isSameDate = recordZdt.toLocalDate().isEqual(nowZdt.toLocalDate())
        if (!isSameDate) return false

        // Must be strictly before 18:00 (6:00 PM)
        val deadlineTime = LocalTime.of(18, 0, 0)
        return nowZdt.toLocalTime().isBefore(deadlineTime)
    }

    /**
     * Retention policy: 7 days from creation time
     */
    const val RETENTION_MILLIS: Long = 7L * 24L * 60L * 60L * 1000L

    fun isRecordExpired(createdAtMillis: Long): Boolean {
        val now = System.currentTimeMillis()
        return (now - createdAtMillis) >= RETENTION_MILLIS
    }
}
