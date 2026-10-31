import SwiftUI
import TelegramaCore

struct HomeView: View {
    @Environment(CaptureStore.self) private var store
    @State private var path: [UUID] = []
    @State private var pendingDelete: Capture?

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if store.template.fictitious {
                    Section {
                        Label("Prototipo con un formulario ficticio. No cargues datos reales todavía.",
                              systemImage: "exclamationmark.triangle")
                            .font(.callout)
                    }
                }
                Section("Mis capturas") {
                    if store.captures.isEmpty {
                        Text("Todavía no hay capturas. Tocá “Nueva captura” al terminar el escrutinio de tu mesa.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(store.captures) { capture in
                        NavigationLink(value: capture.id) { CaptureRow(capture: capture) }
                            .deleteDisabled(store.wasSent(capture))
                    }
                    .onDelete { offsets in pendingDelete = offsets.first.map { store.captures[$0] } }
                }
                Section {
                } footer: {
                    Text(BuildInfo.summary)
                        .font(.footnote.monospacedDigit())
                        .frame(maxWidth: .infinity)
                        .textSelection(.enabled)
                }
            }
            .navigationTitle("Cuenta Conmigo")
            .confirmationDialog(pendingDelete?.isLocked == true ? "Esta evidencia no se envió. Si la borrás, se pierde."
                                                                 : "Se borran la captura y sus imágenes de este teléfono.",
                                isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }),
                                titleVisibility: .visible) {
                Button(pendingDelete?.isLocked == true ? "Borrar igual" : "Borrar", role: .destructive) {
                    if let capture = pendingDelete { store.delete(capture) }
                    pendingDelete = nil
                }
            }
            .navigationDestination(for: UUID.self) { id in
                CaptureEditorView(captureID: id)
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    path.append(store.create().id)
                } label: {
                    Label("Nueva captura", systemImage: "doc.viewfinder")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 56)
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .background(.bar)
            }
        }
    }
}

private struct CaptureRow: View {
    let capture: Capture

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(capture.mesa.mesa.isEmpty ? "Mesa sin número" : "Mesa \(capture.mesa.mesa)")
                .font(.headline)
            HStack {
                Label(capture.isLocked ? "Confirmada" : "Borrador",
                      systemImage: capture.isLocked ? "lock.fill" : "pencil")
                    .foregroundStyle(capture.isLocked ? .green : .orange)
                Text("· \(capture.documentType.label) · \(capture.pages.count) pág.")
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
        }
        .accessibilityElement(children: .combine)
    }
}
