package com.anhquan.unisync.ui.screen.sharing

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import com.anhquan.unisync.R
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.PairingHandler
import com.anhquan.unisync.core.plugins.sharing.SharingPlugin
import com.anhquan.unisync.ui.theme.setView
import com.anhquan.unisync.utils.debugLog

class SharingActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        debugLog(intent.getStringExtra(Intent.EXTRA_TEXT))
        val devices = Device.getConnectedDevices().filter {
            it.pairState == PairingHandler.PairState.PAIRED
        }
        if (devices.size == 1) {
            devices.first().getPlugin(SharingPlugin::class.java).handleExtras(intent.extras!!)
            finish()
        } else {
            setView {
                ShareView(devices)
            }
        }
    }

    @OptIn(ExperimentalMaterial3Api::class)
    @Composable
    fun ShareView(devices: List<Device>) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = {
                        Text(
                            text = stringResource(R.string.choose_destination_device)
                        )
                    }
                )
            }
        ) { padding ->
            LazyColumn(modifier = Modifier.padding(padding)) {
                items(devices) {
                    Text(text = it.info.name)
                }
            }
        }
    }
}