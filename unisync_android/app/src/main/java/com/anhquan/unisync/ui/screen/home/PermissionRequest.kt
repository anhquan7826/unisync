package com.anhquan.unisync.ui.screen.home

import android.Manifest
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.ListItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import com.anhquan.unisync.R
import com.anhquan.unisync.core.Device
import com.google.accompanist.permissions.ExperimentalPermissionsApi
import com.google.accompanist.permissions.rememberPermissionState

@OptIn(ExperimentalPermissionsApi::class)
@Composable
fun PermissionRequest(
    modifier: Modifier = Modifier,
    controller: PermissionRequestController,
    context: Context,
    device: Device
) {
    LaunchedEffect(controller.state.value) {}
    val notGrantedPlugins = device.plugins.filter { !it.hasPermission }
    if (notGrantedPlugins.isNotEmpty()) {
        Column(
            modifier = modifier.verticalScroll(rememberScrollState())
        ) {
            Text(text = stringResource(R.string.permission_need_granted))
            val permissions = notGrantedPlugins.map {
                it.requiredPermission
            }.flatten()
            val permissionStates = permissions.map {
                rememberPermissionState(permission = it)
            }
            for (i in permissions.indices) {
                val permission = permissions[i]
                val state = permissionStates[i]
                ListItem(
                    headlineContent = {
                        Text(
                            text = when (permission) {
                                Manifest.permission.READ_CONTACTS -> stringResource(R.string.read_contacts)
                                Manifest.permission.SEND_SMS -> stringResource(R.string.send_sms)
                                Manifest.permission.READ_SMS -> stringResource(R.string.read_sms)
                                Manifest.permission.RECEIVE_SMS -> stringResource(R.string.receive_sms)
                                Manifest.permission.POST_NOTIFICATIONS -> stringResource(R.string.post_notifications)
                                "enabled_notification_listeners" -> stringResource(R.string.read_notifications)
                                Manifest.permission.READ_MEDIA_IMAGES -> stringResource(R.string.read_all_images)
                                Manifest.permission.MANAGE_EXTERNAL_STORAGE -> stringResource(R.string.access_all_files)
                                Manifest.permission.READ_EXTERNAL_STORAGE -> stringResource(R.string.read_all_files)
                                else -> stringResource(R.string.other_permission, permission)
                            }
                        )
                    },
                    modifier = Modifier.clickable {
                        when (permission) {
                            Manifest.permission.MANAGE_EXTERNAL_STORAGE -> {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                    context.startActivity(
                                        Intent(
                                            Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION,
                                            Uri.parse("package:${context.packageName}")
                                        )
                                    )
                                } else {
                                    state.launchPermissionRequest()
                                }
                            }
                            "enabled_notification_listeners" -> {
                                context.startActivity(
                                    Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).apply {
                                        setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                    }
                                )
                            }
                            else -> {
                                state.launchPermissionRequest()
                            }
                        }
                    }
                )
            }
        }
    }
}

class PermissionRequestController {
    var state = mutableStateOf(false)

    fun update() {
        state.value = !state.value
    }
}