package com.anhquan.unisync.core.plugins.run_command

import android.widget.Toast
import com.anhquan.unisync.core.Device
import com.anhquan.unisync.core.plugins.UnisyncPlugin
import com.anhquan.unisync.models.DeviceMessage

class RunCommandPlugin(
    private val device: Device,
) : UnisyncPlugin(device, DeviceMessage.Type.RUN_COMMAND) {
    private object Method {
        const val EXECUTE = "execute"
    }

    fun execute(command: String) {
        sendRequest(
            Method.EXECUTE,
            mapOf(
                "command" to command
            )
        )
        Toast.makeText(
            context,
            "Executing command '$command'...",
            Toast.LENGTH_SHORT
        ).show()
    }
}