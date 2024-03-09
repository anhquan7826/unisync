package com.anhquan.unisync.ui.screen.home

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.viewModels
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.surfaceColorAtElevation
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.anhquan.unisync.R
import com.anhquan.unisync.constants.Status.*
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.ui.composables.UAppBar
import com.anhquan.unisync.ui.screen.home.run_command.RunCommandActivity
import com.anhquan.unisync.ui.screen.settings.SettingsActivity
import com.anhquan.unisync.ui.theme.setView
import com.anhquan.unisync.utils.gson
import kotlin.math.roundToInt

class HomeActivity : ComponentActivity() {
    private lateinit var deviceInfo: DeviceInfo

    private val viewModel: HomeViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        deviceInfo = gson.fromJson(intent.extras!!.getString("device"), DeviceInfo::class.java)
        viewModel.setDevice(deviceInfo)
        viewModel.load()
        setView {
            HomeScreen()
        }
    }

    @SuppressLint("NewApi")
    @Composable
    private fun HomeScreen() {
        val state by viewModel.state.collectAsState()
        Scaffold(containerColor = Color.White,
            contentWindowInsets = WindowInsets(left = 16.dp, right = 16.dp),
            modifier = Modifier.systemBarsPadding(),
            topBar = {
                BuildAppBar()
            }) { padding ->
            when (state.status) {
                Loading, Error -> {}
                Loaded -> {
                    BuildBody(state = state, modifier = Modifier.padding(padding))
                }
            }
        }
    }

    @Composable
    fun BuildAppBar() {
        UAppBar(title = {
            Row(
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Image(
                    painterResource(id = R.drawable.computer),
                    contentDescription = null,
                    modifier = Modifier
                        .size(42.dp)
                        .padding(end = 8.dp)
                )
                Column {
                    Text(
                        deviceInfo.name, fontSize = 14.sp, fontWeight = FontWeight.SemiBold
                    )
                    Text(stringResource(R.string.connected), fontSize = 10.sp)
                }
            }
        }, actions = listOf(
            painterResource(id = R.drawable.settings),
        ), onActionPressed = listOf {
            startActivity(Intent(this@HomeActivity, SettingsActivity::class.java))
        })
    }

    @Composable
    fun BuildBody(modifier: Modifier = Modifier, state: HomeViewModel.HomeState) {
        LazyVerticalGrid(
            columns = GridCells.Fixed(2), modifier = modifier
        ) {
            item {
                FeatureTile(
                    icon = painterResource(id = R.drawable.data_transfer),
                    title = "Send files",
                ) {
//                    if (Environment.isExternalStorageManager()) {
//                        startActivity(Intent(this@HomeActivity, FileTransferActivity::class.java))
//                    }
//                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
//                        startActivity(
//                            Intent(
//                                Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION,
//                                Uri.parse("package:$packageName")
//                            )
//                        )
//                    }
                }
            }
            item {
                FeatureTile(
                    icon = painterResource(id = R.drawable.clipboards),
                    title = "Send clipboard",
                ) {
                    viewModel.sendClipboard()
                }
            }
            item {
                VolumeControl(
                    volume = state.volume
                ) {
                    viewModel.setVolume(it)
                }
            }
            item {
                FeatureTile(
                    icon = painterResource(id = R.drawable.command_line),
                    title = "Run command",
                ) {
                    startActivity(Intent(
                        this@HomeActivity, RunCommandActivity::class.java
                    ).apply {
                        putExtra("device", gson.toJson(deviceInfo))
                    })
                }
            }
            item {
                FeatureTile(
                    icon = painterResource(id = R.drawable.ssh),
                    title = "SSH",
                ) {

                }
            }
            item {
                FeatureTile(
                    icon = painterResource(id = R.drawable.remote_control),
                    title = "Remote desktop",
                ) {

                }
            }
        }
    }

    @Composable
    private fun FeatureTile(
        modifier: Modifier = Modifier, icon: Painter, title: String, onTap: () -> Unit
    ) {
        Card(
            modifier = modifier
                .padding(8.dp)
                .fillMaxWidth()
                .height(128.dp)
                .clip(RoundedCornerShape(12.dp))
                .clickable(
                    onClick = onTap
                )
        ) {
            Column(
                verticalArrangement = Arrangement.Center,
                modifier = Modifier
                    .fillMaxHeight()
                    .padding(16.dp)
            ) {
                Image(
                    icon,
                    contentDescription = null,
                    modifier = Modifier
                        .size(48.dp)
                        .padding(bottom = 8.dp)
                )
                Text(title)
            }
        }
    }

    @Composable
    private fun VolumeControl(
        modifier: Modifier = Modifier, volume: Float, onChange: (Float) -> Unit
    ) {
        val mainColor = MaterialTheme.colorScheme.surfaceColorAtElevation(10.dp)

        fun bound(value: Float, max: Float, min: Float): Float {
            return if (value > max) max else if (value < min) min else value
        }
        Card(colors = CardDefaults.cardColors(
            containerColor = Color.Unspecified
        ),
            modifier = modifier
                .padding(8.dp)
                .fillMaxWidth()
                .height(128.dp)
                .clip(RoundedCornerShape(12.dp))
                .drawBehind {
                    drawRect(
                        color = Color.Unspecified, size = size
                    )
                    drawRect(
                        color = mainColor, size = size.copy(width = size.width * volume)
                    )
                }
                .pointerInput(true) {
                    detectDragGestures { _, dragAmount ->
                        val value = bound(volume + dragAmount.x / 1000F, 1F, 0F)
                        onChange((value * 100).roundToInt() / 100F)
                    }
                }) {
            Column(
                verticalArrangement = Arrangement.Center,
                modifier = Modifier
                    .fillMaxHeight()
                    .padding(16.dp)
            ) {
                Image(
                    painterResource(id = R.drawable.volume_up),
                    contentDescription = null,
                    modifier = Modifier
                        .size(48.dp)
                        .padding(bottom = 8.dp)
                )
                Text("Volume: ${(volume * 100).roundToInt()}%")
            }
        }
    }
}