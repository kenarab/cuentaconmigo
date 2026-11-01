package ar.cuentaconmigo.app

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import uniffi.cc_core.Core
import uniffi.cc_core.MesaRecord
import uniffi.cc_core.OptionRecord
import uniffi.cc_core.PlaceRecord

/**
 * Cascading pickers (F-16): district -> section -> searchable polling place -> table.
 * Choosing the table fills district, section, circuit and table in one step. The list and
 * the search live in the shared core.
 */
@Composable
fun MesaPicker(core: Core, mesa: MesaRecord, enabled: Boolean, onChange: (MesaRecord) -> Unit) {
    var district by remember { mutableStateOf(mesa.distrito) }
    var section by remember { mutableStateOf(mesa.seccion) }
    var place by remember { mutableStateOf<PlaceRecord?>(null) }
    var query by remember { mutableStateOf("") }
    val districts = remember { core.districts() }
    val sections = remember(district) { if (district.isEmpty()) emptyList() else core.sections(district) }
    val places = remember(district, section, query) {
        if (district.isEmpty() || section.isEmpty()) emptyList() else core.places(district, section, query).take(30)
    }
    // A table already set (for example, from a sample) preselects its polling place.
    LaunchedEffect(mesa) {
        district = mesa.distrito
        section = mesa.seccion
        mesa.mesa.toLongOrNull()?.let { m ->
            if (mesa.distrito.isNotEmpty() && mesa.seccion.isNotEmpty()) place = core.locate(mesa.distrito, mesa.seccion, m)
        }
    }

    Column {
        Dropdown("Distrito", districts, district, enabled) { district = it; section = ""; place = null }
        if (district.isNotEmpty()) Dropdown("Sección", sections, section, enabled) { section = it; place = null }
        if (section.isNotEmpty()) {
            if (place == null) {
                OutlinedTextField(query, { query = it }, Modifier.fillMaxWidth(), enabled = enabled,
                    label = { Text("Buscar establecimiento, dirección o número de mesa") }, singleLine = true)
                places.forEach { p ->
                    Column(Modifier.fillMaxWidth().clickable(enabled) {
                        place = p
                        query.toLongOrNull()?.let { m ->
                            p.tables.firstOrNull { it.mesa == m }?.let { t -> onChange(MesaRecord(district, section, t.circuito, "%05d".format(t.mesa))) }
                        }
                    }.padding(vertical = 6.dp)) {
                        Text(p.nombre)
                        Text("${p.direccion} · ${p.localidad}", style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }
            } else {
                val p = place!!
                Text("Establecimiento: ${p.nombre}", Modifier.clickable(enabled) { place = null; query = "" }.padding(vertical = 6.dp))
                val tables = p.tables.map { OptionRecord("%05d".format(it.mesa), "Mesa ${it.mesa}") }
                Dropdown("Mesa", tables, mesa.mesa.takeIf { m -> tables.any { it.id == m } } ?: "", enabled) { id ->
                    val t = p.tables.first { "%05d".format(it.mesa) == id }
                    onChange(MesaRecord(district, section, t.circuito, id))
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun Dropdown(label: String, options: List<OptionRecord>, selected: String, enabled: Boolean, onSelect: (String) -> Unit) {
    var open by remember { mutableStateOf(false) }
    ExposedDropdownMenuBox(expanded = open, onExpandedChange = { if (enabled) open = it }) {
        OutlinedTextField(
            value = options.firstOrNull { it.id == selected }?.label ?: "Elegí",
            onValueChange = {}, readOnly = true, enabled = enabled, label = { Text(label) },
            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(open) },
            modifier = Modifier.fillMaxWidth().menuAnchor(),
        )
        ExposedDropdownMenu(expanded = open, onDismissRequest = { open = false }) {
            options.forEach { o -> DropdownMenuItem(text = { Text(o.label) }, onClick = { onSelect(o.id); open = false }) }
        }
    }
}
