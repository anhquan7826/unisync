package com.anhquan.unisync.ui.screen.home.remote_ssh

import androidx.lifecycle.ViewModel
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.ssh.SSHPlugin
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.listenCancellable

class RemoteSSHViewModel : ViewModel() {
    private lateinit var device: Device

    private val plugin: SSHPlugin get() = device.getPlugin(SSHPlugin::class.java)

    fun initialize(device: Device) {
        this.device = device
        plugin.setup().listenCancellable {
            plugin.getUsername().listenCancellable {
                debugLog(it)
            }
        }
    }
}