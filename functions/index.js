/**
 * Student Attendance Management System - Scheduled Cleanup Cloud Function
 * Retention Policy: Keep attendance records and their associated details
 * for exactly seven days from the server-created timestamp.
 * 
 * Scheduled execution via Cloud Scheduler / Firebase Scheduled Functions:
 * Runs daily at 00:00 (Midnight) Asia/Kolkata timezone.
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// 7 days in milliseconds
const SEVEN_DAYS_MS = 7 * 24 * 60 * 60 * 1000;

exports.cleanupExpiredAttendance = functions
  .region("asia-south1")
  .pubsub.schedule("0 0 * * *") // Daily at 00:00 IST
  .timeZone("Asia/Kolkata")
  .onRun(async (context) => {
    const now = Date.now();
    const cutoffTimestamp = admin.firestore.Timestamp.fromMillis(now - SEVEN_DAYS_MS);

    console.log(`[Retention Job] Starting scheduled cleanup. Cutoff: ${cutoffTimestamp.toDate().toISOString()}`);

    try {
      // Query expired attendance records (older than 7 days)
      const expiredSnapshot = await db
        .collection("attendance")
        .where("createdAt", "<=", cutoffTimestamp)
        .get();

      if (expiredSnapshot.empty) {
        console.log("[Retention Job] No expired attendance records found.");
        return null;
      }

      console.log(`[Retention Job] Found ${expiredSnapshot.size} expired attendance records to purge.`);

      let deletedRecordsCount = 0;
      let deletedDetailsCount = 0;

      // Batched delete for consistency and efficiency
      const batch = db.batch();

      for (const doc of expiredSnapshot.docs) {
        const attendanceId = doc.id;

        // Delete associated attendanceDetails
        const detailsSnapshot = await db
          .collection("attendanceDetails")
          .where("attendanceId", "==", attendanceId)
          .get();

        detailsSnapshot.docs.forEach((detailDoc) => {
          batch.delete(detailDoc.ref);
          deletedDetailsCount++;
        });

        // Delete the parent attendance record
        batch.delete(doc.ref);
        deletedRecordsCount++;
      }

      await batch.commit();

      console.log(
        `[Retention Job] Retention cleanup completed successfully. Deleted ${deletedRecordsCount} records and ${deletedDetailsCount} details.`
      );
      return null;
    } catch (error) {
      console.error("[Retention Job] Error purging expired attendance records:", error);
      throw error;
    }
  });
