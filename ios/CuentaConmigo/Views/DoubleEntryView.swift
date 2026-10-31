import SwiftUI
import TelegramaCore

/// F-3 minimal blind double entry (AS-5 a): a second person types the number of voters
/// and each category total without seeing the first entry; the app compares them with
/// the first person's values and sums.
struct DoubleEntryView: View {
    let template: FormTemplate
    let capture: Capture
    @Environment(\.dismiss) private var dismiss
    @State private var votantes = ""
    @State private var totals: [String: String] = [:]
    @State private var differences: [String]?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    numberField("Total de votantes", text: $votantes)
                    ForEach(template.categories) { category in
                        numberField("Total de \(category.label)", text: Binding(
                            get: { totals[category.id] ?? "" },
                            set: { totals[category.id] = $0.filter(\.isNumber) }))
                    }
                } header: {
                    Text("Segunda carga")
                } footer: {
                    Text("Pasale el teléfono a otra persona. Carga mirando el documento, sin ver lo que cargaste vos.")
                }
                if let differences {
                    Section("Resultado") {
                        if differences.isEmpty {
                            Label("Las dos cargas coinciden", systemImage: "checkmark.seal.fill").foregroundStyle(.green)
                        }
                        ForEach(differences, id: \.self) { text in
                            Label(text, systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                        }
                    }
                }
                Section {
                    Button("Comparar", action: compare)
                        .disabled(votantes.isEmpty || template.categories.contains { (totals[$0.id] ?? "").isEmpty })
                }
            }
            .navigationTitle("Verificar con otra persona")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Listo") { dismiss() } } }
        }
    }

    private func numberField(_ label: String, text: Binding<String>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("—", text: text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 100)
                .accessibilityLabel(label)
        }
    }

    private func compare() {
        var found: [String] = []
        let first = capture.value(header: "votantes")
        if Int(votantes) != first {
            found.append("Votantes: primera carga \(first.map(String.init) ?? "vacío"), segunda \(votantes)")
        }
        for category in template.categories {
            let sum = template.rows.reduce(0) { $0 + (capture.value(category: category.id, row: $1.id) ?? 0) }
            if Int(totals[category.id] ?? "") != sum {
                found.append("\(category.label): la suma de la primera carga da \(sum), la segunda dice \(totals[category.id] ?? "")")
            }
        }
        differences = found
    }
}
