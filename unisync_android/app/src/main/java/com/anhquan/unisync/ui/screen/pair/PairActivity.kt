package com.anhquan.unisync.ui.screen.pair

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.viewModels
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.Divider
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.ColorMatrix
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import com.anhquan.unisync.R
import com.anhquan.unisync.UnisyncActivity
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.ui.theme.setView

class PairActivity : ComponentActivity() {
    private val viewModel: PairViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        viewModel.initialize(this)
        setView {
            PairScreen()
        }
    }

    @OptIn(ExperimentalMaterial3Api::class)
    @Composable
    private fun PairScreen() {
        val state by viewModel.state.collectAsState()
        var manualDialog by remember {
            mutableStateOf(false)
        }
        Scaffold(contentWindowInsets = WindowInsets(left = 16.dp, right = 16.dp), topBar = {
            TopAppBar(
                title = {
                    Text(text = stringResource(R.string.manage_devices))
                },
                navigationIcon = {
                    IconButton(onClick = {
//                            if (intent.extras?.getBoolean("isInitial") == true) {
//                                ConfigUtil.Device.getLastUsedDevice(this@PairActivity) {
//                                    if (it == null) return@getLastUsedDevice
//                                    startActivity(Intent(
//                                        this@PairActivity, HomeActivity::class.java
//                                    ).apply {
//                                        putExtra("device", gson.toJson(it))
//                                    })
//                                }
//                            }
                        startActivity(Intent(this@PairActivity, UnisyncActivity::class.java))
                        finish()
                    }) {
                        Icon(painterResource(id = R.drawable.arrow_back), contentDescription = null)
                    }
                },
            )
        }) { padding ->
            Column(
                modifier = Modifier.padding(padding)
            ) {
                if (state.pairedDevices.isNotEmpty()) {
                    Text(stringResource(R.string.paired_devices))
                    state.pairedDevices.forEach {
                        PairedDeviceTile(device = it)
                    }
                }
                if (state.requestedDevices.isNotEmpty()) {
                    Text(stringResource(R.string.requested_devices))
                    state.requestedDevices.forEach {
                        RequestedDeviceTile(device = it)
                    }
                }
                if (state.availableDevices.isNotEmpty()) {
                    Text(text = stringResource(id = R.string.available_devices))
                    state.availableDevices.forEach {
                        AvailableDeviceTile(device = it)
                    }
                }
            }
        }
    }

    @Composable
    private fun AvailableDeviceTile(device: Device) {
        ListItem(leadingContent = {
            Image(
                painterResource(id = R.drawable.computer),
                contentDescription = null,
                modifier = Modifier.size(32.dp)
            )
        }, headlineContent = {
            Text(device.info.name)
        }, supportingContent = {
            device.ipAddress?.let { Text(it) }
        }, trailingContent = {
            TextButton(onClick = {
                viewModel.sendPairRequest(device)
            }) {
                Icon(
                    painterResource(id = R.drawable.link),
                    contentDescription = null,
                    modifier = Modifier
                        .align(Alignment.CenterVertically)
                        .padding(end = 8.dp)
                )
                Text(
                    stringResource(id = R.string.request_pair),
                    modifier = Modifier.align(Alignment.CenterVertically)
                )
            }
        })
    }

    @Composable
    private fun RequestedDeviceTile(device: Device) {
        ListItem(leadingContent = {
            Image(
                painterResource(id = R.drawable.computer),
                contentDescription = null,
                modifier = Modifier.size(32.dp)
            )
        }, headlineContent = {
            Text(device.info.name)
        }, supportingContent = {
            device.ipAddress?.let { Text(it) }
        }, trailingContent = {
            Icon(
                painterResource(id = R.drawable.pending), contentDescription = null
            )
        })
    }

    @Composable
    private fun PairedDeviceTile(device: Device) {
        ListItem(leadingContent = {
            Image(
                painterResource(id = R.drawable.computer),
                contentDescription = null,
                colorFilter = if (device.isOnline) null else ColorFilter.colorMatrix(ColorMatrix().apply {
                    setToSaturation(0f)
                }),
                modifier = Modifier.size(32.dp)
            )
        }, headlineContent = {
            Text(device.info.name)
        }, supportingContent = {
            if (device.isOnline) {
                if (device.ipAddress != null) {
                    Text(stringResource(R.string.connected_at, device.ipAddress ?: ""))
                } else {
                    Text(stringResource(id = R.string.connected))
                }
            } else {
                Text(stringResource(id = R.string.disconnected))
            }
        }, trailingContent = {
            IconButton(onClick = {
                viewModel.unpair(device)
            }) {
                Icon(
                    painterResource(id = R.drawable.unlink), contentDescription = null
                )
            }
        })
    }

    @Composable
    fun DeviceDialog(info: DeviceInfo, onDismiss: () -> Unit, onAccept: () -> Unit) {
        Dialog(
            onDismissRequest = onDismiss
        ) {
            Card(
                shape = RoundedCornerShape(12.dp)
            ) {
                Column {
                    Text(info.name)
                    Divider(modifier = Modifier.fillMaxWidth())
                    Row {
                        TextButton(onClick = onAccept) {
                            Text(stringResource(R.string.request_pair))
                        }
                    }
                }
            }
        }
    }
}