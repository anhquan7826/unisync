package com.anhquan.unisync.ui.screen.home.remote_ssh

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.viewModels
import androidx.compose.runtime.Composable
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.models.DeviceInfo
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

    }
}