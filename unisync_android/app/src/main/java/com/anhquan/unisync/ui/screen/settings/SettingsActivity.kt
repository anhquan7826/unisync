package com.anhquan.unisync.ui.screen.settings

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.material3.Card
import androidx.compose.material3.Divider
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ListItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.anhquan.unisync.R
import com.anhquan.unisync.ui.composables.UAppBar
import com.anhquan.unisync.ui.screen.pair.PairActivity
import com.anhquan.unisync.ui.theme.setView

class SettingsActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setView {
            SettingScreen()
        }
    }

    @Composable
    private fun SettingScreen() {
        Scaffold(
            containerColor = Color.White,
            contentWindowInsets = WindowInsets(left = 16.dp, right = 16.dp),
            modifier = Modifier.systemBarsPadding(),
            topBar = {
                UAppBar(
                    title = { Text(stringResource(R.strings.settings)) },
                    leading = painterResource(id = R.drawable.arrow_back),
                    onLeadingPressed = { finish() })
            }
        ) { padding ->
            Column(
                modifier = Modifier.padding(padding)
            ) {
                Card {
                    Column {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.padding(horizontal = 16.dp)
                        ) {
                            Text(
                                stringResource(R.strings.connected_devices),
                                modifier = Modifier.weight(1f),
                                fontSize = 12.sp
                            )
                            TextButton(
                                onClick = {
                                    startActivity(
                                        Intent(
                                            this@SettingsActivity,
                                            PairActivity::class.java
                                        )
                                    )
                                }
                            ) {
                                Text(stringResource(R.strings.find_new_device))
                            }
                        }
                        Divider(modifier = Modifier.fillMaxWidth())
                        DeviceTile()
                    }
                }
            }
        }
    }

    @Composable
    private fun DeviceTile() {
        ListItem(headlineContent = { Text("AnhQuan-Linux") })
    }
}