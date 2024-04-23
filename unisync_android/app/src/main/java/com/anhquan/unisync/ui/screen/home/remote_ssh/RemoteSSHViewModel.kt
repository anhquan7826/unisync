package com.anhquan.unisync.ui.screen.home.remote_ssh

import androidx.lifecycle.ViewModel
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.ssh.SSHPlugin
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

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
        plugin.foo()
//        if (!plugin.sshConnected) {
//            plugin.setup().listenCancellable {
//                _state.update {
//                    it.copy(
//                        setup = true
//                    )
//                }
//                plugin.getUsername().listenCancellable { username ->
//                    _state.update {
//                        it.copy(
//                            username = username
//                        )
//                    }
//                    debugLog(username)
//                }
//            }
//        } else {
//            _state.update {
//                it.copy(
//                    ready = true
//                )
//            }
//        }
    }
}