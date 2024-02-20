package com.anhquan.unisync.core.plugins.run_command

import android.content.Context
import com.anhquan.unisync.core.device.dependencies.DeviceConnection
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class RunCommandPlugin(
    private val context: Context,
    private val emitter: DeviceConnection.ConnectionEmitter
) :
    UnisyncPlugin(context, emitter) {
    override fun onMessageReceived(message: DeviceMessage) {

    }

    override fun isPluginMessage(message: DeviceMessage): Boolean {
        return message.type == DeviceMessage.Type.RUN_COMMAND
    }

    override fun dispose() {

    }

    fun execute(command: String) {
        emitter.sendMessage(
            DeviceMessage(
                type = DeviceMessage.Type.RUN_COMMAND,
                body = mapOf(
                    "command" to command
                )
            )
        )
    }
}