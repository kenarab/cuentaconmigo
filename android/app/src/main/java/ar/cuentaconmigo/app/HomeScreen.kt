package ar.cuentaconmigo.app

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExtendedFloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import uniffi.cc_core.CaptureSummary
import uniffi.cc_core.Core

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(core: Core, onOpen: (String) -> Unit, onSettings: () -> Unit) {
    var captures by remember { mutableStateOf(core.listCaptures()) }
    var pendingDelete by remember { mutableStateOf<CaptureSummary?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Cuenta Conmigo") },
                actions = { IconButton(onClick = onSettings) { Icon(Icons.Default.Settings, "Ajustes") } },
            )
        },
        floatingActionButton = {
            ExtendedFloatingActionButton(
                onClick = { onOpen(core.newCapture("telegrama", null)) },
                icon = { Icon(Icons.Default.Add, null) },
                text = { Text("Nueva captura") },
            )
        },
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding).padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            if (captures.isEmpty()) {
                item {
                    Text("Todavía no hay capturas. Tocá “Nueva captura” al terminar el escrutinio de tu mesa.",
                        color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
            items(captures, key = { it.id }) { c ->
                Card(Modifier.fillMaxWidth().clickable { onOpen(c.id) }) {
                    Row(Modifier.padding(16.dp)) {
                        Column(Modifier.weight(1f)) {
                            Text(if (c.mesa.mesa.isEmpty()) "Mesa sin número" else "Mesa ${c.mesa.mesa}",
                                style = MaterialTheme.typography.titleMedium)
                            val state = when {
                                c.sent -> "Enviada"
                                c.locked -> "Confirmada"
                                else -> "Borrador"
                            }
                            Text("$state · ${c.documentLabel} · ${c.pageCount} pág.",
                                color = if (c.locked || c.sent) Color(0xFF2E7D32) else Color(0xFFE65100))
                        }
                        // Sent captures are proof of what was submitted: they cannot be deleted.
                        if (!c.sent) {
                            IconButton(onClick = { pendingDelete = c }) { Icon(Icons.Default.Delete, "Borrar") }
                        }
                    }
                }
            }
        }
    }

    pendingDelete?.let { c ->
        AlertDialog(
            onDismissRequest = { pendingDelete = null },
            title = { Text(if (c.locked) "Esta evidencia no se envió" else "Borrar borrador") },
            text = {
                Text(if (c.locked) "Si la borrás, se pierde." else "Se borran la captura y sus imágenes de este teléfono.")
            },
            confirmButton = {
                TextButton(onClick = {
                    runCatching { core.deleteCapture(c.id) }
                    captures = core.listCaptures()
                    pendingDelete = null
                }) { Text(if (c.locked) "Borrar igual" else "Borrar") }
            },
            dismissButton = { TextButton(onClick = { pendingDelete = null }) { Text("Cancelar") } },
        )
    }
}
