import SwiftUI

/// The three interchangeable presentations of the same capture flow (#2, app-architecture).
enum Presentation: String, CaseIterable, Identifiable {
    case wizard = "F-1"
    case split = "F-2"
    case doubleEntry = "F-3"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .wizard: "F-1 · Asistente paso a paso"
        case .split: "F-2 · Imagen y campos"
        case .doubleEntry: "F-3 · Con doble carga a ciegas"
        }
    }

    var detail: String {
        switch self {
        case .wizard: "Una sección por pantalla, con Anterior y Siguiente."
        case .split: "Todo en una pantalla, con la imagen y los números detectados a mano."
        case .doubleEntry: "Como F-2, y otra persona vuelve a cargar votantes y totales sin ver la primera carga."
        }
    }
}

/// E-12: settings with the presentation selector and the server connection.
struct SettingsView: View {
    @AppStorage("presentation") private var presentation = Presentation.split
    @Environment(\.dismiss) private var dismiss
    @State private var showServer = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Diseño", selection: $presentation) {
                        ForEach(Presentation.allCases) { option in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.title)
                                Text(option.detail).font(.footnote).foregroundStyle(.secondary)
                            }
                            .tag(option)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Diseño de la carga")
                } footer: {
                    Text("Los tres usan el mismo flujo y las mismas validaciones. Probalos y contanos cuál funciona mejor.")
                }
                Section("Servidor de lectura") {
                    LabeledContent("Estado", value: ServerSettings.token == nil ? "Sin conectar" : "Conectado")
                    if let url = ServerSettings.url { LabeledContent("Dirección", value: url.absoluteString) }
                    Button(ServerSettings.token == nil ? "Conectar" : "Cambiar servidor") { showServer = true }
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Listo") { dismiss() } } }
            .sheet(isPresented: $showServer) {
                ServerSettingsView(appVersion: CaptureStore.appInfo.version) {}
            }
        }
    }
}
