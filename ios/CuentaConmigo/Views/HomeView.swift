import SwiftUI
import TelegramaCore

struct HomeView: View {
    @Environment(CaptureStore.self) private var store
    @State private var path: [UUID] = []

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
                            .deleteDisabled(capture.isLocked)
                    }
                    .onDelete { offsets in
                        offsets.map { store.captures[$0] }.forEach(store.deleteDraft)
                    }
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
