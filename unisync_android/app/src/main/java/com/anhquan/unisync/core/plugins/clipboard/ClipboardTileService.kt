package com.anhquan.unisync.core.plugins.clipboard

import android.app.PendingIntent
import android.content.Intent
import android.service.quicksettings.TileService
import androidx.core.service.quicksettings.PendingIntentActivityWrapper
import androidx.core.service.quicksettings.TileServiceCompat

class ClipboardTileService : TileService() {
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    override fun onClick() {
        TileServiceCompat.startActivityAndCollapse(
            this, PendingIntentActivityWrapper(
                this, 0, Intent(this, ClipboardTransparentActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK
                }, PendingIntent.FLAG_ONE_SHOT, true
            )
        )
    }
}