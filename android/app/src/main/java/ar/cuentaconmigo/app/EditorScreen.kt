package ar.cuentaconmigo.app

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.core.content.FileProvider
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import uniffi.cc_core.CaptureDetail
import uniffi.cc_core.Core
import uniffi.cc_core.MesaRecord
import uniffi.cc_core.ReadingRecord
import java.io.ByteArrayOutputStream
import java.io.File

/** Re-encodes an image as JPEG, which drops EXIF/GPS before the hash (telegram-capture). */
private fun reencode(bytes: ByteArray): ByteArray? {
    val bmp = BitmapFactory.decodeByteArray(bytes, 0, bytes.size) ?: return null
    return ByteArrayOutputStream().also { bmp.compress(Bitmap.CompressFormat.JPEG, 90, it) }.toByteArray()
}

private fun thumbnail(path: String): Bitmap? {
    val opts = BitmapFactory.Options().apply { inSampleSize = 8 }
    return BitmapFactory.decodeFile(path, opts)
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EditorScreen(core: Core, id: String, onBack: () -> Unit) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val presentation = remember { presentation(context) }
    val template = remember { core.template(null) }
    var detail by remember { mutableStateOf(core.capture(id)) }
    var readings by remember { mutableStateOf<Map<String, ReadingRecord>>(emptyMap()) }
    var readingTemplate by remember { mutableStateOf<String?>(null) }
    var busy by remember { mutableStateOf<String?>(null) }
    var step by remember { mutableStateOf(0) }
    var showSamples by remember { mutableStateOf(false) }
    var showJustification by remember { mutableStateOf(false) }
    var showDouble by remember { mutableStateOf(false) }
    val samples = remember { loadSamples(context) }
    val locked = detail.summary.locked

    fun refresh() { detail = core.capture(id) }
    fun toast(text: String) = Toast.makeText(context, text, Toast.LENGTH_LONG).show()
    fun addPage(bytes: ByteArray?, source: String) {
        val jpeg = bytes?.let(::reencode) ?: return toast("No se pudo leer la imagen.")
        runCatching { core.addPage(id, jpeg, source) }.onFailure { toast(it.message ?: "No se pudo guardar la imagen.") }
        refresh()
    }

    val cameraFile = remember { File(context.cacheDir, "camera").apply { mkdirs() }.resolve("shot.jpg") }
    val cameraUri: Uri = remember { FileProvider.getUriForFile(context, "ar.cuentaconmigo.app.files", cameraFile) }
    val takePicture = rememberLauncherForActivityResult(ActivityResultContracts.TakePicture()) { ok ->
        if (ok) addPage(cameraFile.readBytes(), "scanner")
    }
    val pickPhoto = rememberLauncherForActivityResult(ActivityResultContracts.PickVisualMedia()) { uri ->
        uri?.let { addPage(context.contentResolver.openInputStream(it)?.use { s -> s.readBytes() }, "photos") }
    }

    fun readWithServer() = scope.launch {
        busy = "Leyendo los números en el servidor…"
        val result = withContext(Dispatchers.IO) {
            runCatching {
                val r = core.readCells(id, 0u, readingTemplate)
                r to core.applyReadings(id, r)
            }
        }
        busy = null
        result.onSuccess { (r, filled) ->
            readings = r.fields.associateBy { it.path }
            refresh()
            val unreadable = r.fields.count { it.status == "unreadable" }
            toast(if (r.aligned) "Se completaron $filled campos. $unreadable quedaron con “?” para cargar a mano." else "No se pudo alinear el formulario. Cargá los valores a mano.")
        }.onFailure { toast(it.message ?: "No se pudo leer.") }
    }

    fun send() = scope.launch {
        busy = "Enviando al servidor…"
        val result = withContext(Dispatchers.IO) { runCatching { core.sendCapture(id) } }
        busy = null
        result.onSuccess { refresh(); toast("Enviada. El comprobante quedó guardado con la captura.") }
            .onFailure { toast(it.message ?: "No se pudo enviar.") }
    }

    // Sections, also used as the steps of F-1.
    val sections: List<Pair<String, @Composable () -> Unit>> = buildList {
        add("Documento" to @Composable {
            DocumentSection(detail, locked, onType = { runCatching { core.setDocumentType(id, it) }; refresh() },
                onCamera = { takePicture.launch(cameraUri) },
                onGallery = { pickPhoto.launch(PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly)) },
                onSamples = { showSamples = true }, hasSamples = samples.isNotEmpty(),
                onRead = { readWithServer() })
        })
        add("Mesa" to @Composable {
            MesaPicker(core, detail.summary.mesa, !locked) { m -> runCatching { core.setMesa(id, m) }; refresh() }
            Text("Mesa ${detail.summary.mesa.mesa.ifEmpty { "—" }} · circuito ${detail.summary.mesa.circuito.ifEmpty { "—" }}",
                style = MaterialTheme.typography.bodySmall)
        })
        add("Totales de la mesa" to @Composable {
            template.headerFields.forEach { f -> ValueField(f.label, "header.${f.id}", detail, readings, locked) { p, v -> core.setValue(id, p, v, false); refresh() } }
        })
        template.categories.forEach { cat ->
            add(cat.label to @Composable {
                template.rows.forEach { r -> ValueField(r.label, "cells.${cat.id}.${r.id}", detail, readings, locked) { p, v -> core.setValue(id, p, v, false); refresh() } }
            })
        }
        add("Revisión" to @Composable {
            IssuesSection(detail)
            ActionsSection(detail, presentation, onConfirm = {
                val warnings = detail.issues.any { !it.isError }
                if (warnings) showJustification = true else runCatching { core.confirm(id, null) }.onFailure { toast(it.message ?: "") }
                refresh()
            }, onSend = { send() }, onDouble = { showDouble = true }, onExport = { share(context, core.exportPaths(id)) })
        })
    }

    Scaffold(topBar = {
        TopAppBar(title = { Text(if (detail.summary.mesa.mesa.isEmpty()) "Nueva captura" else "Mesa ${detail.summary.mesa.mesa}") },
            navigationIcon = { IconButton(onClick = onBack) { Icon(Icons.AutoMirrored.Filled.ArrowBack, "Volver") } })
    }) { padding ->
        Column(Modifier.fillMaxSize().padding(padding).padding(horizontal = 16.dp).verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(12.dp)) {
            busy?.let { Text(it); LinearProgressIndicator(Modifier.fillMaxWidth()) }
            if (locked) Text(if (detail.summary.sent) "Enviada: es prueba de lo que se mandó y no se puede borrar." else "Confirmada: ya no se puede editar.",
                color = Color(0xFF2E7D32))
            if (presentation == Presentation.WIZARD && !locked) {
                val current = step.coerceIn(0, sections.lastIndex)
                LinearProgressIndicator(progress = { (current + 1f) / sections.size }, modifier = Modifier.fillMaxWidth())
                Text("Paso ${current + 1} de ${sections.size} · ${sections[current].first}", style = MaterialTheme.typography.titleMedium)
                sections[current].second()
                Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                    OutlinedButton(onClick = { step = current - 1 }, enabled = current > 0) { Text("Anterior") }
                    Button(onClick = { step = current + 1 }, enabled = current < sections.lastIndex) { Text("Siguiente") }
                }
            } else {
                sections.forEach { (title, body) ->
                    Card(Modifier.fillMaxWidth()) {
                        Column(Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                            Text(title, style = MaterialTheme.typography.titleMedium)
                            body()
                        }
                    }
                }
            }
            Spacer(Modifier.height(24.dp))
        }
    }

    if (showSamples) {
        AlertDialog(onDismissRequest = { showSamples = false }, title = { Text("Telegramas de ejemplo") },
            text = {
                Column(Modifier.verticalScroll(rememberScrollState())) {
                    samples.forEach { s ->
                        Text(s.label, Modifier.fillMaxWidth().clickable {
                            showSamples = false
                            addPage(context.assets.open("samples/${s.file}").use { it.readBytes() }, "sample")
                            runCatching { core.setMesa(id, MesaRecord(s.distrito, s.seccion, s.circuito, s.mesa)) }
                            readingTemplate = s.templateId()
                            refresh()
                        }.padding(vertical = 10.dp))
                    }
                }
            }, confirmButton = { TextButton(onClick = { showSamples = false }) { Text("Cerrar") } })
    }
    if (showJustification) {
        var text by remember { mutableStateOf("") }
        AlertDialog(onDismissRequest = { showJustification = false }, title = { Text("Hay avisos") },
            text = {
                Column {
                    Text("Los totales no coinciden. Si el documento dice eso, escribí una breve justificación.")
                    OutlinedTextField(text, { text = it }, Modifier.fillMaxWidth())
                }
            },
            confirmButton = {
                TextButton(onClick = {
                    runCatching { core.confirm(id, text) }.onFailure { toast(it.message ?: "") }
                    showJustification = false; refresh()
                }) { Text("Confirmar") }
            }, dismissButton = { TextButton(onClick = { showJustification = false }) { Text("Cancelar") } })
    }
    if (showDouble) DoubleEntryDialog(detail, template.categories.map { it.id to it.label }) { showDouble = false }
}

@Composable
private fun DocumentSection(detail: CaptureDetail, locked: Boolean, onType: (String) -> Unit, onCamera: () -> Unit,
                            onGallery: () -> Unit, onSamples: () -> Unit, hasSamples: Boolean, onRead: () -> Unit) {
    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        listOf("telegrama" to "Telegrama", "acta" to "Acta", "certificado" to "Certificado").forEach { (k, l) ->
            FilterChip(selected = detail.summary.documentType == k, onClick = { if (!locked) onType(k) }, label = { Text(l) })
        }
    }
    if (detail.pages.isNotEmpty()) {
        Row(Modifier.horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            detail.pages.forEach { p -> thumbnail(p.path)?.let { Image(it.asImageBitmap(), p.file, Modifier.height(140.dp)) } }
        }
    }
    if (!locked) {
        Text("Nunca fotografíes la Boleta Única: está prohibido. Sólo telegrama, acta o certificado de escrutinio.",
            color = MaterialTheme.colorScheme.error, style = MaterialTheme.typography.bodySmall)
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Button(onClick = onCamera) { Text("Sacar foto") }
            OutlinedButton(onClick = onGallery) { Text("Galería") }
        }
        if (hasSamples) OutlinedButton(onClick = onSamples) { Text("Usar un telegrama de ejemplo") }
        if (detail.pages.isNotEmpty()) Button(onClick = onRead) { Text("Leer números con el servidor") }
    }
}

/** Numeric field. A cell the server could not read shows an empty box marked "?". */
@Composable
private fun ValueField(label: String, path: String, detail: CaptureDetail, readings: Map<String, ReadingRecord>,
                       locked: Boolean, onSet: (String, Long?) -> Unit) {
    val value = detail.values.firstOrNull { it.path == path }
    val reading = readings[path]
    val unreadable = reading?.status == "unreadable" && value?.value == null
    Row(Modifier.fillMaxWidth(), verticalAlignment = androidx.compose.ui.Alignment.CenterVertically) {
        Text(label, Modifier.weight(1f))
        if (value?.fromOcr == true) Text("OCR ", style = MaterialTheme.typography.labelSmall, color = Color(0xFF2B59C3))
        OutlinedTextField(
            value = value?.value?.toString() ?: "",
            onValueChange = { t -> onSet(path, t.filter(Char::isDigit).take(9).toLongOrNull()) },
            enabled = !locked, singleLine = true,
            placeholder = { Text(if (unreadable) "?" else "—") },
            isError = unreadable,
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            modifier = Modifier.width(110.dp),
        )
    }
}

@Composable
private fun IssuesSection(detail: CaptureDetail) {
    if (detail.issues.isEmpty()) Text("Todo cierra", color = Color(0xFF2E7D32))
    detail.issues.forEach { i -> Text("• ${i.message}", color = if (i.isError) MaterialTheme.colorScheme.error else Color(0xFFE65100)) }
}

@Composable
private fun ActionsSection(detail: CaptureDetail, presentation: Presentation, onConfirm: () -> Unit, onSend: () -> Unit,
                           onDouble: () -> Unit, onExport: () -> Unit) {
    val locked = detail.summary.locked
    if (!locked) {
        if (presentation == Presentation.DOUBLE) OutlinedButton(onClick = onDouble) { Text("Verificar con otra persona") }
        Button(onClick = onConfirm, enabled = detail.pages.isNotEmpty() && detail.issues.none { it.isError }) { Text("Confirmar captura") }
        Text(if (detail.pages.isEmpty()) "Agregá al menos una imagen del documento." else "Al confirmar, la captura queda bloqueada como evidencia.",
            style = MaterialTheme.typography.bodySmall)
    } else {
        if (!detail.summary.sent) Button(onClick = onSend) { Text("Enviar al servidor") }
        OutlinedButton(onClick = onExport) { Text("Exportar evidencia") }
        detail.receipts.lastOrNull()?.let { Text("Comprobante: $it", style = MaterialTheme.typography.bodySmall) }
    }
}

/** F-3 minimal blind double entry: votantes and each category total, compared with the first entry. */
@Composable
private fun DoubleEntryDialog(detail: CaptureDetail, categories: List<Pair<String, String>>, onClose: () -> Unit) {
    var votantes by remember { mutableStateOf("") }
    val totals = remember { mutableStateOf(categories.associate { it.first to "" }) }
    var result by remember { mutableStateOf<List<String>?>(null) }
    AlertDialog(onDismissRequest = onClose, title = { Text("Verificar con otra persona") },
        text = {
            Column {
                Text("Pasale el teléfono a otra persona. Carga mirando el documento, sin ver lo que cargaste vos.",
                    style = MaterialTheme.typography.bodySmall)
                OutlinedTextField(votantes, { votantes = it.filter(Char::isDigit) }, label = { Text("Total de votantes") },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number))
                categories.forEach { (cat, label) ->
                    OutlinedTextField(totals.value[cat] ?: "", { v -> totals.value = totals.value + (cat to v.filter(Char::isDigit)) },
                        label = { Text("Total de $label") }, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number))
                }
                result?.let { r ->
                    if (r.isEmpty()) Text("Las dos cargas coinciden", color = Color(0xFF2E7D32))
                    r.forEach { Text("• $it", color = Color(0xFFE65100)) }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = {
                val out = mutableListOf<String>()
                val first = detail.values.firstOrNull { it.path == "header.votantes" }?.value
                if (votantes.toLongOrNull() != first) out += "Votantes: primera carga ${first ?: "vacío"}, segunda $votantes"
                categories.forEach { (cat, label) ->
                    val sum = detail.values.filter { it.path.startsWith("cells.$cat.") }.sumOf { it.value ?: 0L }
                    if (totals.value[cat]?.toLongOrNull() != sum) out += "$label: la primera carga suma $sum, la segunda dice ${totals.value[cat]}"
                }
                result = out
            }) { Text("Comparar") }
        }, dismissButton = { TextButton(onClick = onClose) { Text("Listo") } })
}

private fun share(context: Context, paths: List<String>) {
    val uris = ArrayList(paths.map { FileProvider.getUriForFile(context, "ar.cuentaconmigo.app.files", File(it)) })
    val intent = android.content.Intent(android.content.Intent.ACTION_SEND_MULTIPLE).apply {
        type = "*/*"
        putParcelableArrayListExtra(android.content.Intent.EXTRA_STREAM, uris)
        addFlags(android.content.Intent.FLAG_GRANT_READ_URI_PERMISSION)
    }
    context.startActivity(android.content.Intent.createChooser(intent, "Exportar evidencia"))
}
