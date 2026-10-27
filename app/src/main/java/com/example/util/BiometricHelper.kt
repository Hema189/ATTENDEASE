package com.example.util

import android.app.KeyguardManager
import android.content.Context
import android.os.Build

object BiometricHelper {
    fun isDeviceSecure(context: Context): Boolean {
        val km = context.getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
        return km?.isDeviceSecure == true
    }
}
