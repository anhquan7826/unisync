package com.anhquan.unisync.core.plugins.status

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager

class StatusReceiver : BroadcastReceiver() {
    interface StatusDataListener {
        fun onStatusChanged(batteryLevel: Int, isCharging: Boolean)
    }

    companion object {
        private val listeners = mutableListOf<StatusDataListener>()
        private var hasRegistered = false

        private var lastBatteryLevel: Int = -1
        private var lastChargingState: Boolean = false

        fun registerBroadcast(context: Context) {
            if (hasRegistered) return
            val receiver = StatusReceiver()
            val intentFilter = IntentFilter()
            intentFilter.addAction(Intent.ACTION_BATTERY_CHANGED)
            intentFilter.addAction(Intent.ACTION_BATTERY_LOW)
            intentFilter.addAction(Intent.ACTION_BATTERY_OKAY)
            val currentState = context.registerReceiver(receiver, intentFilter)
            hasRegistered = true
            receiver.onReceive(context, currentState)
        }

        fun addListener(listener: StatusDataListener) {
            if (!listeners.contains(listener)) listeners.add(listener)
            listener.onStatusChanged(lastBatteryLevel, lastChargingState)
        }

        fun removeListener(listener: StatusDataListener) {
            listeners.remove(listener)
        }
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        val isCharging = intent?.getIntExtra(
            BatteryManager.EXTRA_STATUS, -1
        ) == BatteryManager.BATTERY_STATUS_CHARGING
        val level = intent?.getIntExtra("level", -1) ?: -1
        if (lastBatteryLevel != level || lastChargingState != isCharging) {
            lastBatteryLevel = level
            lastChargingState = isCharging
            listeners.forEach { it.onStatusChanged(level, isCharging) }
        }
    }
}