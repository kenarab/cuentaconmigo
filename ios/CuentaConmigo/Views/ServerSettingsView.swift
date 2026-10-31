import SwiftUI

/// Connects the app to a scrutiny server with a one-time enrollment code.
/// No personal data is asked for or sent.
struct ServerSettingsView: View {
    let appVersion: String
    let onConnected: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var address = ServerSettings.url?.absoluteString ?? "https://"
    @State private var code = ""
    @State private var working = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("https://newbery.duckdns.org/cuentaconmigo", text: $address)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Código de alta", text: $code)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Servidor de lectura (OCR)")
                } footer: {
                    Text("Pedile la dirección y el código a quien coordina. No se envían datos personales; las fotos viajan al servidor para leer los números.")
                }
                if let error {
                    Section { Label(error, systemImage: "exclamationmark.triangle").foregroundStyle(.red) }
                }
                Section {
                    Button {
                        Task { await connect() }
                    } label: {
                        if working { ProgressView() } else { Text("Conectar") }
                    }
                    .disabled(working || code.isEmpty || URL(string: address)?.host == nil)
                    if ServerSettings.token != nil {
                        Button("Desconectar este teléfono", role: .destructive) {
                            ServerSettings.token = nil
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Servidor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cerrar") { dismiss() } } }
        }
    }

    private func connect() async {
        guard let url = URL(string: address.trimmingCharacters(in: .whitespaces)) else { return }
        working = true
        defer { working = false }
        do {
            let token = try await ScrutinyClient(baseURL: url, token: nil).enroll(code: code, appVersion: appVersion)
            ServerSettings.url = url
            ServerSettings.token = token
            onConnected()
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
