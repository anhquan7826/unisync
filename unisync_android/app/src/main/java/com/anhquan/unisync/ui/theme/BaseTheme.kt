package com.anhquan.unisync.ui.theme

import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Shapes
import androidx.compose.material3.Surface
import androidx.compose.material3.Typography
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.view.WindowCompat

val Typography = Typography(
    bodyLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.5.sp
    )
)

fun ComponentActivity.setView(content: @Composable () -> Unit) {
    WindowCompat.setDecorFitsSystemWindows(window, false)
    setContent {
        MaterialTheme(
            colorScheme = lightColorScheme(),
            shapes = Shapes(
                extraSmall = RoundedCornerShape(12.dp),
                extraLarge = RoundedCornerShape(12.dp),
                large = RoundedCornerShape(12.dp),
                medium = RoundedCornerShape(12.dp),
                small = RoundedCornerShape(12.dp),
            ),
            typography = Typography,
        ) {
            Surface(
                modifier = Modifier.fillMaxSize(),
                color = Color.White
            ) {
                content()
            }
        }
    }
}