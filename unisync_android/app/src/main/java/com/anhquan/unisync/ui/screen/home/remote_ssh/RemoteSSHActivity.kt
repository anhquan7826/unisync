package com.anhquan.unisync.ui.screen.home.remote_ssh

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.viewModels
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.ui.theme.defaultWindowInsets
import com.anhquan.unisync.ui.theme.setView
import com.anhquan.unisync.utils.gson

class RemoteSSHActivity : ComponentActivity() {
    private val viewModel: RemoteSSHViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val deviceInfo = gson.fromJson(intent.extras!!.getString("device"), DeviceInfo::class.java)
        viewModel.initialize(Device.of(this, deviceInfo))
        setView {
            SSHView()
        }
    }

    @Composable
    fun SSHView() {
        Scaffold(
            contentWindowInsets = defaultWindowInsets()
        ) { padding ->
            val state by viewModel.state.collectAsState()
            if (!state.setup || state.username == null || !state.ready) {
                Box(
                    modifier = Modifier.padding(padding)
                ) {
                    CircularProgressIndicator(
                        modifier = Modifier.align(Alignment.Center)
                    )
                }
            }
        }
    }
}