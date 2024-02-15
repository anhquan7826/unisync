package com.anhquan.unisync.ui.screen.home.run_command

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import com.anhquan.unisync.R
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.ui.composables.UDialog
import com.anhquan.unisync.ui.theme.setView
import com.anhquan.unisync.utils.gson

class RunCommandActivity : ComponentActivity() {
    private lateinit var deviceInfo: DeviceInfo

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        deviceInfo = gson.fromJson(intent.extras!!.getString("device"), DeviceInfo::class.java)
        setView {
            RunCommandScreen()
        }
    }

    @OptIn(ExperimentalMaterial3Api::class)
    @Composable
    private fun RunCommandScreen() {
        var showAddDialog by remember {
            mutableStateOf(false)
        }
        if (showAddDialog) {
            AddCommandDialog(onDismiss = {
                showAddDialog = false
            }) {
                // TODO: Add command
                showAddDialog = false
            }
        }
        Scaffold(topBar = {
            TopAppBar(title = {
                Text(text = "Run Command")
            }, actions = {
                IconButton(onClick = { showAddDialog = true }) {
                    Icon(painter = painterResource(id = R.drawable.add), contentDescription = null)
                }
            })
        }) { padding ->
            Column(
                modifier = Modifier.padding(padding)
            ) {

            }
        }
    }

    @Composable
    private fun AddCommandDialog(onDismiss: () -> Unit, onAdd: (String) -> Unit) {
        var command by remember {
            mutableStateOf("")
        }
        UDialog(title = "Add new command", content = {
            TextField(value = command, onValueChange = {
                command = it
            })
        }, cancelText = "Cancel", confirmText = "Add", onCancel = onDismiss) {
            onAdd(command)
        }
    }
}