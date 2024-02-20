package com.anhquan.unisync.ui.screen.home.file_transfer

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Scaffold
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.anhquan.unisync.ui.theme.setView

class FileTransferActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setView {
            FileTransferScreen()
        }
    }

    @OptIn(ExperimentalMaterial3Api::class)
    @Composable
    private fun FileTransferScreen() {
        Scaffold(
            topBar = {
                TopAppBar(title = { /*TODO*/ })
            }
        ) { padding ->
            Column(
                modifier = Modifier.padding(padding)
            ) {

            }
        }
    }
}