package com.anhquan.unisync.ui.screen.sharing

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.anhquan.unisync.R
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.PairingHandler
import com.anhquan.unisync.core.plugins.sharing.SharingPlugin
import com.anhquan.unisync.ui.theme.setView
import com.anhquan.unisync.ui.theme.shapes
import com.anhquan.unisync.ui.theme.typography
import com.anhquan.unisync.utils.debugLog

class SharingActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        debugLog(intent.getStringExtra(Intent.EXTRA_TEXT))
        val devices = Device.getConnectedDevices().filter {
            it.pairState == PairingHandler.PairState.PAIRED
        }
        if (devices.size == 1 && false) {
            sendContent(devices.first())
            finish()
        } else {
            setView {
                ShareView(devices)
            }
        }
    }

    private fun sendContent(device: Device) {
        device.getPlugin(SharingPlugin::class.java).handleExtras(intent.extras!!)
        Toast.makeText(
            this,
            "Sending content to device ${device.info.name}...",
            Toast.LENGTH_SHORT
        ).show()
    }

    @OptIn(ExperimentalMaterial3Api::class)
    @Composable
    fun ShareView(devices: List<Device>) {
        Scaffold(
            topBar = {
                TopAppBar(
                    navigationIcon = {
                        IconButton(
                            onClick = {
                                finish()
                            }
                        ) {
                            Icon(
                                painterResource(id = R.drawable.close),
                                contentDescription = null,
                            )
                        }
                    },
                    title = {
                        Text(
                            text = stringResource(R.string.choose_destination_device)
                        )
                    }
                )
            },
            contentWindowInsets = WindowInsets(
                top = 16.dp,
                bottom = 16.dp,
                left = 16.dp,
                right = 16.dp
            )
        ) { padding ->
            LazyColumn(modifier = Modifier.padding(padding)) {
                items(devices) {
                    DeviceTile(
                        device = it,
                        modifier = Modifier.padding(bottom = 16.dp)
                    )
                }
            }
        }
    }

    @Composable
    fun DeviceTile(modifier: Modifier = Modifier, device: Device) {
        Card(
            modifier = modifier
                .fillMaxWidth()
                .height(100.dp)
                .clickable {
                    sendContent(device)
                }
                .clip(shapes().medium)
        ) {
            Row(
                modifier = Modifier
                    .padding(16.dp)
                    .fillMaxHeight(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Image(
                    painterResource(id = R.drawable.computer),
                    contentDescription = null,
                    modifier = Modifier.size(42.dp)
                )
                Text(
                    text = device.info.name,
                    style = typography().bodyLarge,
                    modifier = Modifier
                        .weight(1f)
                        .padding(start = 16.dp)
                )
            }
        }
    }
}