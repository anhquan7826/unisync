package com.anhquan.unisync.ui.screen.home.run_command

import androidx.lifecycle.ViewModel
import com.anhquan.unisync.constants.Status
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.run_command.RunCommandPlugin
import com.anhquan.unisync.database.entity.DeviceCommandEntity
import com.anhquan.unisync.utils.Database
import com.anhquan.unisync.utils.listen
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class RunCommandViewModel : ViewModel() {
    data class RunCommandState(
        val state: Status = Status.Loading,
        val commands: Set<String> = setOf()
    )

    lateinit var deviceId: String

    private var _state = MutableStateFlow(RunCommandState())
    val state = _state.asStateFlow()

    fun getAll() {
        Database.deviceCommand.get(deviceId).listen {
            _state.update { s ->
                s.copy(
                    state = Status.Loaded,
                    commands = it.map { c -> c.command }.toSet()
                )
            }
        }
    }

    fun add(command: String) {
        Database.deviceCommand.add(
            DeviceCommandEntity(
                deviceId = deviceId,
                command = command
            )
        ).listen {
            _state.update {
                it.copy(
                    commands = it.commands.plus(command)
                )
            }
        }
    }

    fun execute(command: String) {
        Device.of(deviceId).getPlugin(RunCommandPlugin::class.java).execute(command)
    }
}