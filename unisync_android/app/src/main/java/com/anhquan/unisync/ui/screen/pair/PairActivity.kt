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
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.Divider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
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
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.ui.composables.UAppBar
import com.anhquan.unisync.ui.screen.home.HomeActivity
import com.anhquan.unisync.ui.theme.setView
import com.anhquan.unisync.utils.gson
import com.anhquan.unisync.utils.listen

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
        Scaffold(containerColor = Color.White,
            contentWindowInsets = WindowInsets(left = 16.dp, right = 16.dp),
            modifier = Modifier.systemBarsPadding(),
            topBar = {
                BuildAppBar()
            }) { padding ->
            BuildBody(modifier = Modifier.padding(padding), state)
        }
    }

    @Composable
    private fun BuildAppBar() {
        UAppBar(
            title = {
                Text(text = stringResource(R.string.pair_new_device))
            },
            leading = painterResource(id = R.drawable.arrow_back),
            onLeadingPressed = {
                if (intent.extras?.getBoolean("isInitial") == true) {
                    viewModel.getLastConnected().listen(onError = {}) {
                        startActivity(Intent(
                            this@PairActivity, HomeActivity::class.java
                        ).apply {
                            putExtra("device", gson.toJson(it))
                        })
                    }
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

    @Composable
    fun BuildBody(modifier: Modifier = Modifier, state: PairViewModel.PairViewState) {
        Column(
            modifier = modifier
        ) {
            if (state.requestedDevices.isNotEmpty()) {
                Text(stringResource(R.string.requested_devices))
                state.requestedDevices.forEach {
                    DeviceTile(device = it)
                }
            }
            if (state.availableDevices.isNotEmpty()) {
                Text(text = stringResource(id = R.string.available_devices))
                state.availableDevices.forEach {
                    DeviceTile(device = it) {
                        viewModel.sendPairRequest(it)
                    }
                }
            }
        }
    }

    @Composable
    fun DeviceTile(device: Device, onPair: (() -> Unit)? = null) {
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
            if (onPair != null) IconButton(onClick = onPair) {
                Icon(
                    painterResource(id = R.drawable.link), contentDescription = null
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