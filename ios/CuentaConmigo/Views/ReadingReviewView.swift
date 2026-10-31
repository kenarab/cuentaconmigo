import SwiftUI
import TelegramaCore

/// Visual check over the telegram image (sdd/specs/assisted-review/SPEC.md §2).
/// Each value read by the server is drawn next to the handwritten number: the more
/// confident the reading, the darker the text. Tapping a number edits it.
struct ReadingReviewView: View {
    let imageURL: URL
    let readings: ScrutinyClient.ReadingSet
    let template: FormTemplate
    /// Current value of a field in the capture (the person's edits win over the reading).
    let currentValue: (String) -> Int?
    /// Applies an edit made on the image (origin "manual").
    let onEdit: (String, Int?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var zoom: CGFloat = 1
    @State private var baseZoom: CGFloat = 1
    @State private var editing: ScrutinyClient.Reading?
    @State private var draft = ""
    @State private var highlighted: String?
    @State private var reviewed: Set<String> = []

    private var image: UIImage? { UIImage(contentsOfFile: imageURL.path) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                legend
                GeometryReader { geo in
                    ScrollView([.horizontal, .vertical]) {
                        page(width: geo.size.width * zoom)
                    }
                    .gesture(MagnifyGesture()
                        .onChanged { zoom = min(4, max(1, baseZoom * $0.magnification)) }
                        .onEnded { _ in baseZoom = zoom })
                }
                footer
            }
            .navigationTitle("Cotejo sobre la imagen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Listo") { dismiss() } }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Siguiente dudoso", systemImage: "arrow.down.circle") { nextDoubtful() }
                        .labelStyle(.titleAndIcon)
                }
            }
            .alert(editing.map { title(for: $0.ref) } ?? "", isPresented: Binding(
                get: { editing != nil }, set: { if !$0 { editing = nil } })) {
                TextField("Valor", text: $draft).keyboardType(.numberPad)
                Button("Guardar") {
                    if let ref = editing?.ref {
                        let digits = draft.filter(\.isNumber)
                        onEdit(ref, digits.isEmpty ? nil : Int(digits.prefix(9)))
                        reviewed.insert(ref)
                    }
                    editing = nil
                }
                Button("Cancelar", role: .cancel) { editing = nil }
            } message: {
                Text("Escribí el número tal como figura en el telegrama.")
            }
        }
    }

    // MARK: - Page with overlays

    @ViewBuilder
    private func page(width: CGFloat) -> some View {
        if let image {
            let scale = width / CGFloat(max(1, readings.image.width))
            ZStack(alignment: .topLeading) {
                Image(uiImage: image).resizable().scaledToFit().frame(width: width)
                // Signatures, names and ID numbers are covered (participant-protection).
                ForEach(Array((readings.masks ?? []).enumerated()), id: \.offset) { _, box in
                    Rectangle().fill(.black.opacity(0.85))
                        .frame(width: CGFloat(box[2]) * scale, height: CGFloat(box[3]) * scale)
                        .offset(x: CGFloat(box[0]) * scale, y: CGFloat(box[1]) * scale)
                        .overlay { Text("Datos personales tapados").font(.caption).foregroundStyle(.white) }
                        .allowsHitTesting(false)
                }
                ForEach(readings.fields, id: \.ref) { reading in
                    marker(reading, scale: scale)
                }
            }
            .frame(width: width, height: image.size.height * width / max(1, image.size.width))
        } else {
            ContentUnavailableView("No se encontró la imagen", systemImage: "photo")
        }
    }

    private func marker(_ reading: ScrutinyClient.Reading, scale: CGFloat) -> some View {
        let cell = reading.cellBox
        let edited = currentValue(reading.ref) != reading.value && currentValue(reading.ref) != nil
        let shown = currentValue(reading.ref) ?? reading.value
        let level = ConfidenceLevel(reading.confidence)
        let fontSize = max(14, min(34, CGFloat(cell[3]) * scale * 0.55))
        // Drawn at the right end of the cell, beside the handwriting.
        let x = CGFloat(cell[0] + cell[2]) * scale - fontSize * 3.2
        let y = CGFloat(cell[1]) * scale + (CGFloat(cell[3]) * scale - fontSize * 1.4) / 2
        return Button {
            draft = shown.map(String.init) ?? ""
            editing = reading
        } label: {
            HStack(spacing: 4) {
                if edited, let original = reading.value {
                    Text("\(original)").strikethrough().foregroundStyle(.secondary)
                        .font(.system(size: fontSize * 0.6, weight: .regular, design: .rounded))
                }
                Text(shown.map(String.init) ?? "¿?")
                    .font(.system(size: fontSize, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(edited ? Color.blue : level.color)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 6))
            .overlay {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(highlighted == reading.ref ? Color.orange : (edited ? Color.blue : level.color),
                            style: StrokeStyle(lineWidth: highlighted == reading.ref ? 3 : 1.5,
                                               dash: level.dashed && !edited ? [4, 3] : []))
            }
        }
        .buttonStyle(.plain)
        .offset(x: x, y: y)
        .accessibilityLabel("\(title(for: reading.ref)): \(shown.map(String.init) ?? "sin leer"), \(edited ? "corregido" : level.spoken)")
    }

    // MARK: - Legend, totals, navigation

    private var legend: some View {
        HStack(spacing: 10) {
            Text("Confianza:").font(.caption)
            ForEach(ConfidenceLevel.allCases, id: \.self) { level in
                Text("123").font(.caption.bold().monospacedDigit()).foregroundStyle(level.color)
                    .padding(.horizontal, 4)
                    .overlay(RoundedRectangle(cornerRadius: 4)
                        .stroke(level.color, style: StrokeStyle(lineWidth: 1, dash: level.dashed ? [3, 2] : [])))
                    .accessibilityLabel(level.spoken)
            }
            Text("Tocá un número para corregirlo").font(.caption).foregroundStyle(.secondary)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(.bar)
    }

    private var footer: some View {
        let votantes = currentValue("header.votantes")
        let lines = template.categories.map { category -> String in
            let values = template.rows.map { currentValue("cells.\(category.id).\($0.id)") }
            let sum = values.compactMap { $0 }.reduce(0, +)
            let missing = values.filter { $0 == nil }.count
            let check = votantes.map { $0 == sum && missing == 0 ? "✓ coincide con votantes" : "votantes: \($0)" } ?? "falta el total de votantes"
            return "\(category.label): suma \(sum)\(missing > 0 ? " (faltan \(missing))" : "") · \(check)"
        }
        return VStack(alignment: .leading, spacing: 4) {
            ForEach(lines, id: \.self) { Text($0).font(.footnote) }
            Text("Alineación: \(readings.alignment.ok ? "\(readings.alignment.anchorsUsed) referencias impresas encontradas" : "no se pudo alinear; cargá a mano")")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.bar)
    }

    private func nextDoubtful() {
        let ordered = readings.fields.sorted { $0.confidence < $1.confidence }.map(\.ref)
        let pending = ordered.filter { !reviewed.contains($0) }
        guard let next = pending.first(where: { $0 != highlighted }) ?? pending.first else { return }
        highlighted = next
        reviewed.insert(next)
    }

    private func title(for ref: String) -> String {
        let parts = ref.split(separator: ".").map(String.init)
        if parts.first == "header", let field = template.headerFields.first(where: { $0.id == parts.last }) {
            return field.label
        }
        if parts.count == 3, let row = template.rows.first(where: { $0.id == parts[2] }) {
            return row.label
        }
        return ref
    }
}

/// Four published steps from light gray to black (assisted-review RV-3 ★). The two
/// lowest also get a dashed outline so the cue does not depend on shade alone.
enum ConfidenceLevel: CaseIterable {
    case low, medium, high, veryHigh

    init(_ confidence: Double) {
        switch confidence {
        case ..<0.4: self = .low
        case ..<0.6: self = .medium
        case ..<0.8: self = .high
        default: self = .veryHigh
        }
    }

    var color: Color {
        switch self {
        case .low: Color(white: 0.68)
        case .medium: Color(white: 0.48)
        case .high: Color(white: 0.26)
        case .veryHigh: .black
        }
    }

    var dashed: Bool { self == .low || self == .medium }

    var spoken: String {
        switch self {
        case .low: "confianza baja"
        case .medium: "confianza media"
        case .high: "confianza alta"
        case .veryHigh: "confianza muy alta"
        }
    }
}
