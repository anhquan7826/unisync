package com.anhquan.unisync.ui.theme

import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.WindowInsets
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

fun ComponentActivity.typography() = Typography(
    bodyLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.Normal,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.5.sp
    )
)

fun ComponentActivity.shapes() = Shapes(
    extraSmall = RoundedCornerShape(8.dp),
    extraLarge = RoundedCornerShape(8.dp),
    large = RoundedCornerShape(8.dp),
    medium = RoundedCornerShape(8.dp),
    small = RoundedCornerShape(8.dp),
)

fun ComponentActivity.colorSchemes() = lightColorScheme(
//    primary = Color.Blue,
//    onPrimary = Color.White,
//    primaryContainer = Color.Blue.copy(alpha = 0.15f),
//    onPrimaryContainer = Color.Blue,
//    secondary = Color.DarkGray,
//    onSecondary = Color.White,
//    secondaryContainer = Color.Gray.copy(alpha = 0.25f),
//    onSecondaryContainer = Color.DarkGray,
//    surface = Color.Blue.copy(alpha = 0.1f),
//    surfaceTint = Color.Transparent,
)

fun ComponentActivity.setView(content: @Composable () -> Unit) {
    WindowCompat.setDecorFitsSystemWindows(window, false)
    setContent {
        MaterialTheme(
            colorScheme = colorSchemes(),
            shapes = shapes(),
            typography = typography(),
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

fun ComponentActivity.defaultWindowInsets() =
    WindowInsets(
        left = 16.dp,
        right = 16.dp,
        top = 16.dp,
        bottom = 16.dp
    )