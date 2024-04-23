package com.anhquan.unisync.ui.screen.home.remote_ssh

import androidx.lifecycle.ViewModel
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.ssh.SSHPlugin
import com.anhquan.unisync.utils.debugLog
import com.anhquan.unisync.utils.listenCancellable
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class RemoteSSHViewModel : ViewModel() {
    data class RemoteSSHState(
        val ready: Boolean = false,
        val setup: Boolean = false,
        val username: String? = null,
        val port: Int = 22,
    )

    private lateinit var device: Device

    private val plugin: SSHPlugin get() = device.getPlugin(SSHPlugin::class.java)

    private var _state = MutableStateFlow(RemoteSSHState())
    val state = _state.asStateFlow()

    fun initialize(device: Device) {
        this.device = device
        if (!plugin.sshConnected) {
            plugin.setup().listenCancellable {
                _state.update {
                    it.copy(
                        setup = true
                    )
                }
                plugin.getUsername().listenCancellable { username ->
                    _state.update {
                        it.copy(
                            username = username
                        )
                    }
                    debugLog(username)
                }
            }
        } else {
            _state.update {
                it.copy(
                    ready = true
                )
            }
        }
    }
}