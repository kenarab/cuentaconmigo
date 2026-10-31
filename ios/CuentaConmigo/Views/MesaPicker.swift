import SwiftUI
import TelegramaCore

/// Cascading pickers: district → section → polling place → table (F-16).
/// Choosing a table fills district, section, circuit and table in one step.
struct MesaPicker: View {
    let places: PollingPlaces
    let mesa: Mesa
    let onChange: (Mesa) -> Void

    @State private var districtID = ""
    @State private var sectionID = ""
    @State private var placeID = ""

    private var district: PollingPlaces.District? { places.distritos.first { $0.id == districtID } }
    private var section: PollingPlaces.Section? { district?.secciones.first { $0.id == sectionID } }
    private var place: PollingPlaces.Place? { section?.locales.first { $0.id == placeID } }

    var body: some View {
        Group {
            Picker("Distrito", selection: $districtID) {
                Text("Elegí").tag("")
                ForEach(places.distritos) { Text($0.nombre).tag($0.id) }
            }
            .onChange(of: districtID) { _, _ in sectionID = ""; placeID = "" }

            if let district {
                Picker("Sección", selection: $sectionID) {
                    Text("Elegí").tag("")
                    ForEach(district.secciones) { Text($0.nombre).tag($0.id) }
                }
                .onChange(of: sectionID) { _, _ in placeID = "" }
            }

            if let section {
                NavigationLink {
                    PlaceSearch(places: section.locales) { placeID = $0.id }
                } label: {
                    LabeledContent("Establecimiento", value: place?.nombre ?? "Elegí")
                }
            }

            if let place {
                Picker("Mesa", selection: Binding(
                    get: { Int(mesa.mesa) ?? 0 },
                    set: { number in
                        guard let table = place.tables.first(where: { table in table.mesa == number }) else { return }
                        onChange(Mesa(distrito: districtID, seccion: sectionID, circuito: table.circuito,
                                      mesa: String(format: "%05d", number)))
                    })) {
                    Text("Elegí").tag(0)
                    ForEach(place.tables, id: \.self) { table in Text("Mesa \(table.mesa)").tag(table.mesa) }
                }
            }
        }
        .onAppear(perform: restoreSelection)
    }

    /// Preselects the lists from an already identified table (for example, a sample).
    private func restoreSelection() {
        guard districtID.isEmpty, let d = places.distritos.first(where: { $0.id == mesa.distrito }) else { return }
        districtID = d.id
        guard let s = d.secciones.first(where: { $0.id == mesa.seccion }) else { return }
        sectionID = s.id
        let number = Int(mesa.mesa) ?? -1
        placeID = s.locales.first { place in place.tables.contains { table in table.mesa == number } }?.id ?? ""
    }
}

/// Searchable list of polling places by name, address or locality.
private struct PlaceSearch: View {
    let places: [PollingPlaces.Place]
    let onSelect: (PollingPlaces.Place) -> Void
    @State private var query = ""
    @Environment(\.dismiss) private var dismiss

    private var filtered: [PollingPlaces.Place] {
        guard !query.isEmpty else { return places }
        return places.filter {
            "\($0.nombre) \($0.direccion) \($0.localidad)".localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        List(filtered) { place in
            Button {
                onSelect(place)
                dismiss()
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(place.nombre).font(.headline)
                    Text("\(place.direccion) · \(place.localidad)").font(.subheadline).foregroundStyle(.secondary)
                }
            }
        }
        .searchable(text: $query, prompt: "Nombre, dirección o localidad")
        .navigationTitle("Establecimiento")
    }
}
