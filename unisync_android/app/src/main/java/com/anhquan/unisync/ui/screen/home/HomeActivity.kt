package com.anhquan.unisync.ui.screen.home

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
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
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.anhquan.unisync.R
import com.anhquan.unisync.models.DeviceInfo
import com.anhquan.unisync.ui.composables.UAppBar
import com.anhquan.unisync.ui.screen.settings.SettingsActivity
import com.anhquan.unisync.ui.theme.setView
import com.anhquan.unisync.utils.gson

class HomeActivity : ComponentActivity() {
    private lateinit var deviceInfo: DeviceInfo

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        deviceInfo = gson.fromJson(intent.extras!!.getString("device"), DeviceInfo::class.java)
        setView {
            HomeScreen()
        }
    }

    @Composable
    private fun HomeScreen() {
        Scaffold(
            containerColor = Color.White,
            contentWindowInsets = WindowInsets(left = 16.dp, right = 16.dp),
            modifier = Modifier.systemBarsPadding(),
            topBar = {
                UAppBar(
                    title = {
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
                                    deviceInfo.name,
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.SemiBold
                                )
                                Text(stringResource(R.string.connected), fontSize = 10.sp)
                            }
                        }
                    },
                    actions = listOf(
                        painterResource(id = R.drawable.settings),
                    ),
                    onActionPressed = listOf {
                        startActivity(Intent(this@HomeActivity, SettingsActivity::class.java))
                    }
                )
            }
        ) { padding ->
            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                contentPadding = padding,
            ) {
                item {
                    FeatureTile(
                        icon = painterResource(id = R.drawable.computer),
                        title = "Send files",
                    ) {}
                }
                item {
                    FeatureTile(
                        icon = painterResource(id = R.drawable.computer),
                        title = "Send clipboard",
                    ) {}
                }
                item {
                    FeatureTile(
                        icon = painterResource(id = R.drawable.computer),
                        title = "Control multimedia",
                    ) {}
                }
                item {
                    FeatureTile(
                        icon = painterResource(id = R.drawable.computer),
                        title = "Run command",
                    ) {

                    }
                }
                item {
                    FeatureTile(
                        icon = painterResource(id = R.drawable.computer),
                        title = "SSH",
                    ) {

                    }
                }
                item {
                    FeatureTile(
                        icon = painterResource(id = R.drawable.computer),
                        title = "Remote desktop",
                    ) {

                    }
                }
            }
        }
    }

    @Composable
    private fun FeatureTile(
        modifier: Modifier = Modifier,
        icon: Painter,
        title: String,
        onTap: () -> Unit
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
}