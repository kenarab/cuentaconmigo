package ar.cuentaconmigo.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

sealed interface Screen {
    data object Home : Screen
    data class Editor(val id: String) : Screen
    data object Settings : Screen
}

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme(colorScheme = lightColorScheme(primary = Color(0xFF2B59C3))) { App() }
        }
    }
}

@Composable
fun App() {
    val context = LocalContext.current
    val core = remember { CoreHolder.get(context) }
    var screen by remember { mutableStateOf<Screen>(Screen.Home) }
    // Team builds enroll silently with the bundled server (sdd/specs/server-location).
    LaunchedEffect(Unit) { withContext(Dispatchers.IO) { core.connectIfNeeded() } }
    BackHandler(enabled = screen != Screen.Home) { screen = Screen.Home }
    when (val s = screen) {
        Screen.Home -> HomeScreen(core, onOpen = { screen = Screen.Editor(it) }, onSettings = { screen = Screen.Settings })
        is Screen.Editor -> EditorScreen(core, s.id, onBack = { screen = Screen.Home })
        Screen.Settings -> SettingsScreen(core, onBack = { screen = Screen.Home })
    }
}
