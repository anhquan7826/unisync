package com.anhquan.unisync.ui.screen.find_my_phone

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.anhquan.unisync.ui.theme.setView


class FindMyPhoneActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setShowWhenLocked(true)
        setTurnScreenOn(true)
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                     or WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
        )
        setView {
            FindMyPhoneScreen()
        }
    }

    @Composable
    private fun FindMyPhoneScreen() {
        Scaffold {
            Box(
                modifier = Modifier.padding(it)
            ) {
                Text("Found it")
            }
        }
    }
}