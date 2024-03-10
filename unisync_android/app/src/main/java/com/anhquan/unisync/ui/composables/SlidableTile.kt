package com.anhquan.unisync.ui.composables

import androidx.compose.foundation.Image
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.surfaceColorAtElevation
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.anhquan.unisync.R
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlin.math.roundToInt

@Composable
fun SliderTile(
    modifier: Modifier = Modifier,
    controller: SliderTileController? = null,
    onChanged: (Float) -> Unit
) {
    val mainColor = MaterialTheme.colorScheme.surfaceColorAtElevation(10.dp)

    var value by rememberSaveable {
        mutableFloatStateOf(0F)
    }

    controller?.state?.collectAsState()?.apply {
        value = this.value
    }

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
                    color = mainColor, size = size.copy(width = size.width * value)
                )
            }
            .pointerInput(true) {
                detectDragGestures { _, dragAmount ->
                    value = bound(value + dragAmount.x / 1000F, 1F, 0F)
                    onChanged((value * 100).roundToInt() / 100F)
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
            Text("Volume: ${(value * 100).roundToInt()}%")
        }
    }
}

class SliderTileController(value: Float = 0F) {
    private var _state = MutableStateFlow(value)
    val state = _state.asStateFlow()

    var value: Float
        get() = state.value
        set(v) {
            _state.update {
                v
            }
        }
}