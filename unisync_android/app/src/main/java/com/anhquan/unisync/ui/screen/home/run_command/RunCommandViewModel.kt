package com.anhquan.unisync.ui.screen.home.run_command

import androidx.lifecycle.ViewModel
import com.anhquan.unisync.constants.Status
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.run_command.RunCommandPlugin
import com.anhquan.unisync.utils.ConfigUtil
import com.anhquan.unisync.utils.execute
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class RunCommandViewModel : ViewModel() {
    data class RunCommandState(
        val status: Status = Status.Loading, val commands: Set<String> = setOf()
    )

    lateinit var deviceId: String

    private var _state = MutableStateFlow(RunCommandState())
    val state = _state.asStateFlow()

    fun getAll() {
        ConfigUtil.Command.getAllCommands(deviceId).execute { commands ->
            _state.update {
                it.copy(
                    status = Status.Loaded, commands = commands.toSet()
                )
            }
        }
    }

    fun add(command: String) {
        ConfigUtil.Command.addCommand(deviceId, command).execute()
        _state.update {
            it.copy(
                commands = it.commands.plus(command)
            )
        }
    }

    fun execute(command: String) {
        Device.of(deviceId).getPlugin(RunCommandPlugin::class.java).execute(command)
    }

    fun delete(command: String) {
        ConfigUtil.Command.removeCommand(deviceId, command).execute()
        _state.update {
            it.copy(
                commands = it.commands.minus(command)
            )
        }
    }
}