package com.anhquan.unisync.utils

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat

object PermissionUtil {
    fun requiredPermissions(): List<String> {
        return listOf(
            Manifest.permission.READ_CONTACTS,
            Manifest.permission.READ_SMS,
            Manifest.permission.SEND_SMS,
            Manifest.permission.RECEIVE_SMS,
        ).let {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                it.plus(Manifest.permission.POST_NOTIFICATIONS)
            } else
            it
        }
    }

    fun requestPermission(context: Context, permission: String, onGranted: () -> Unit, onDenied: () -> Unit) {
        when (permission) {
            Manifest.permission.READ_CONTACTS -> {
                val result = ContextCompat.checkSelfPermission(context, permission)
                if (result == PackageManager.PERMISSION_GRANTED) {
                    onGranted()
                } else {

                }
            }
        }
    }
}