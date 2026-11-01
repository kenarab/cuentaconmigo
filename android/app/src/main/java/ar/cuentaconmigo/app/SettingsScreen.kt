package ar.cuentaconmigo.app

import android.content.Context
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import uniffi.cc_core.Core

/** The three presentations of the same capture flow (#2, app-architecture). */
enum class Presentation(val key: String, val title: String, val detail: String) {
    WIZARD("f1", "F-1 · Asistente paso a paso", "Una sección por pantalla, con Anterior y Siguiente."),
    SPLIT("f2", "F-2 · Imagen y campos", "Todo en una pantalla, con la imagen y las lecturas a mano."),
    DOUBLE("f3", "F-3 · Con doble carga a ciegas", "Como F-2, y otra persona vuelve a cargar votantes y totales sin ver la primera carga."),
}

fun presentation(context: Context): Presentation {
    val key = context.getSharedPreferences("settings", Context.MODE_PRIVATE).getString("presentation", "f2")
    return Presentation.entries.firstOrNull { it.key == key } ?: Presentation.SPLIT
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(core: Core, onBack: () -> Unit) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var selected by remember { mutableStateOf(presentation(context)) }
    var url by remember { mutableStateOf(core.serverUrl() ?: "https://") }
    var code by remember { mutableStateOf("") }
    var status by remember { mutableStateOf(if (core.isConnected()) "Conectado" else "Sin conectar") }

    Scaffold(topBar = {
        TopAppBar(title = { Text("Ajustes") },
            navigationIcon = { IconButton(onClick = onBack) { Icon(Icons.AutoMirrored.Filled.ArrowBack, "Volver") } })
    }) { padding ->
        Column(Modifier.fillMaxSize().padding(padding).padding(16.dp).verticalScroll(rememberScrollState())) {
            Text("Diseño de la carga", style = MaterialTheme.typography.titleMedium)
            Presentation.entries.forEach { option ->
                Row(Modifier.fillMaxWidth().selectable(selected == option) {
                    selected = option
                    context.getSharedPreferences("settings", Context.MODE_PRIVATE).edit().putString("presentation", option.key).apply()
                }.padding(vertical = 8.dp)) {
                    RadioButton(selected = selected == option, onClick = null)
                    Column(Modifier.padding(start = 8.dp)) {
                        Text(option.title)
                        Text(option.detail, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }
            }
            Text("Los tres usan el mismo flujo y las mismas validaciones. Probalos y contanos cuál funciona mejor.",
                style = MaterialTheme.typography.bodySmall)
            Spacer(Modifier.height(24.dp))
            Text("Servidor de lectura", style = MaterialTheme.typography.titleMedium)
            Text("Estado: $status")
            OutlinedTextField(url, { url = it }, Modifier.fillMaxWidth(), label = { Text("Dirección") }, singleLine = true)
            OutlinedTextField(code, { code = it }, Modifier.fillMaxWidth(), label = { Text("Código de alta") }, singleLine = true)
            Button(onClick = {
                scope.launch {
                    status = "Conectando…"
                    status = withContext(Dispatchers.IO) {
                        runCatching { core.connect(url.trim(), code.trim()); "Conectado" }
                            .getOrElse { it.message ?: "No se pudo conectar" }
                    }
                }
            }, enabled = code.isNotBlank()) { Text("Conectar") }
            Text("No se envían datos personales; las fotos viajan al servidor para leer los números.",
                style = MaterialTheme.typography.bodySmall)
        }
    }
}
