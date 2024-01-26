package com.anhquan.unisync.ui.screen.pair

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.viewModels
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.Divider
import androidx.compose.material3.ListItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import com.anhquan.unisync.R
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.ui.composables.UAppBar
import com.anhquan.unisync.ui.screen.home.HomeActivity
import com.anhquan.unisync.ui.theme.setView
import com.anhquan.unisync.utils.gson

class PairActivity : ComponentActivity() {
    private val viewModel: PairViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setView {
            PairScreen()
        }
    }

    @Composable
    private fun PairScreen() {
        val state by viewModel.state.collectAsState()
        var manualDialog by remember {
            mutableStateOf(false)
        }
        var currentDeviceDialog: DeviceInfo? by remember {
            mutableStateOf(null)
        }
        Scaffold(
            containerColor = Color.White,
            contentWindowInsets = WindowInsets(left = 16.dp, right = 16.dp),
            modifier = Modifier.systemBarsPadding(),
            topBar = {
                UAppBar(
                    title = {
                        Text(text = stringResource(R.string.pair_new_device))
                    },
                    leading = painterResource(id = R.drawable.arrow_back),
                    onLeadingPressed = {
                        val device = viewModel.getConnected()
                        if (intent.extras?.getBoolean("isInitial") == true && device != null) {
                            startActivity(
                                Intent(
                                    this@PairActivity,
                                    HomeActivity::class.java
                                ).apply {
                                    putExtra("device", gson.toJson(device))
                                })
                        }
                        finish()
                    },
                    actions = listOf(
                        painterResource(id = R.drawable.add)
                    ),
                    onActionPressed = listOf {
                        // TODO
                    },
                )
            }
        ) { padding ->
            Column(
                modifier = Modifier.padding(padding)
            ) {
                if (state.requestedDevices.isNotEmpty()) {
                    Text(stringResource(R.string.requested_devices))
                    state.requestedDevices.forEach {
                        DeviceTile(info = it) {

                        }
                    }
                }
                if (state.notPairedDevices.isNotEmpty()) {
                    Text(stringResource(R.string.available_devices))
                    state.notPairedDevices.forEach {
                        DeviceTile(info = it) {
                            currentDeviceDialog = it
                        }
                    }
                }
            }
        }

        if (currentDeviceDialog != null) {
            DeviceDialog(
                info = currentDeviceDialog!!,
                onDismiss = {
                    currentDeviceDialog = null
                }
            ) {
                viewModel.sendPairRequest(currentDeviceDialog!!)
            }
        }
    }

    @Composable
    fun DeviceTile(info: DeviceInfo, onTap: () -> Unit) {
        ListItem(
            modifier = Modifier.clickable(onClick = onTap),
            leadingContent = {
                Image(
                    painterResource(id = R.drawable.computer),
                    contentDescription = null,
                    modifier = Modifier.size(32.dp)
                )
            },
            headlineContent = {
                Text(info.name)
            },
            supportingContent = {
                Text(info.ip)
            }
        )
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