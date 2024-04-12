package com.anhquan.unisync.ui.composables

import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.surfaceColorAtElevation
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.unit.dp
import kotlin.math.roundToInt

@Composable
fun SliderTile(
    modifier: Modifier = Modifier,
    value: Float,
    onChanged: (Float) -> Unit,
    content: @Composable () -> Unit
) {
    val mainColor = MaterialTheme.colorScheme.surfaceColorAtElevation(10.dp)

    fun bound(value: Float, max: Float, min: Float): Float {
        return if (value > max) max else if (value < min) min else value
    }

    var v by remember {
        mutableFloatStateOf(value)
    }

    var dragging by remember {
        mutableStateOf(false)
    }

    LaunchedEffect(value) {
        if (!dragging) {
            v = value
        }
    }

    Box(
        modifier = modifier
            .fillMaxWidth()
            .drawBehind {
                drawRect(
                    color = Color.Unspecified, size = size
                )
                drawRect(
                    color = mainColor, size = size.copy(width = size.width * v)
                )
            }
            .pointerInput(true) {
                detectDragGestures(
                    onDragStart = {
                        dragging = true
                    },
                    onDragEnd = {
                        dragging = false
                    }
                ) { _, dragAmount ->
                    v = bound(v + dragAmount.x / 1000F, 1F, 0F)
                    onChanged((v * 100).roundToInt() / 100F)
                }
            }
    ) {
        content()
    }
}