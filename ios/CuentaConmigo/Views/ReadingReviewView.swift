import SwiftUI
import TelegramaCore

/// Visual check over the telegram image (sdd/specs/assisted-review/SPEC.md §2).
/// Each value read by the server is drawn next to the handwritten number: the more
/// confident the reading, the darker the text. Tapping a number edits it.
struct ReadingReviewView: View {
    let imageURL: URL
    let readings: ScrutinyClient.ReadingSet
    let template: FormTemplate
    /// Corrections confirmed earlier by the person; they take priority over every reading.
    var savedCorrections: [String: Int?] = [:]
    /// Current value of a field in the capture (the person's edits win over the reading).
    let currentValue: (String) -> Int?
    /// Called when the person confirms the check and saves.
    let onSave: (Result) -> Void

    /// What the person confirmed: readings accepted as they are, and values corrected by hand.
    struct Result {
        var accepted: [String: Int] = [:]
        var corrected: [String: Int?] = [:]
        /// Every correction made on the image so far, to be kept with the capture.
        var allCorrections: [String: Int?] = [:]
    }

    @Environment(\.dismiss) private var dismiss
    @State private var editing: ScrutinyClient.Reading?
    @State private var draft = ""
    @State private var highlighted: String?
    @State private var reviewed: Set<String> = []
    /// Corrections made on the image; applied to the capture only on "Guardar".
    @State private var corrections: [String: Int?] = [:]
    @State private var showSummary = false
    @State private var loaded = false

    private var image: UIImage? { UIImage(contentsOfFile: imageURL.path) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                legend
                GeometryReader { geo in
                    let width = geo.size.width
                    let height = image.map { $0.size.height * width / max(1, $0.size.width) } ?? geo.size.height
                    ZoomableView(contentSize: CGSize(width: width, height: height)) {
                        page(width: width)
                    }
                }
                footer
            }
            .navigationTitle("Cotejo sobre la imagen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Confirmar") { showSummary = true } }
                ToolbarItem(placement: .bottomBar) {
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
                        corrections[ref] = digits.isEmpty ? nil : Int(digits.prefix(9))
                        reviewed.insert(ref)
                    }
                    editing = nil
                }
                Button("Cancelar", role: .cancel) { editing = nil }
            } message: {
                Text("Escribí el número tal como figura en el telegrama.")
            }
            .sheet(isPresented: $showSummary) { summary.presentationDetents([.medium, .large]) }
            .onAppear {
                guard !loaded else { return }
                corrections = savedCorrections.merging(corrections) { _, new in new }
                loaded = true
            }
        }
    }

    /// Value shown for a cell: the correction, else what the person had loaded, else the reading.
    private func shownValue(_ reading: ScrutinyClient.Reading) -> Int? {
        if let corrected = corrections[reading.ref] { return corrected }
        return currentValue(reading.ref) ?? reading.value
    }

    /// The form's own control: the rows of a category add up to the TOTAL written on the
    /// telegram. When it closes, the scanned document is OK.
    private func writtenCheck(_ category: String) -> (ok: Bool, text: String) {
        let values = template.rows.map { shown(ref: "cells.\(category).\($0.id)") }
        let sum = values.compactMap { $0 }.reduce(0, +)
        let missing = values.filter { $0 == nil }.count
        guard let total = shown(ref: "total.\(category)") else {
            return (false, "Control escrito: no se leyó el TOTAL; corregilo sobre la imagen")
        }
        let byHand = corrections["total.\(category)"] != nil ? " (total corregido por vos)" : ""
        if missing == 0 && sum == total {
            return (true, "Control escrito: suma \(sum) = total \(total)\(byHand) · documento OK")
        }
        return (false, "Control escrito: suma \(sum)\(missing > 0 ? " (faltan \(missing))" : "") ≠ total \(total)\(byHand) · no cierra")
    }

    private func change(ref: String, to value: Int?) -> String {
        let original: Int? = readings.fields.first { $0.ref == ref }?.value
        let before: String = original.map { String($0) } ?? "sin leer"
        let after: String = value.map { String($0) } ?? "vacío"
        return before + " → " + after
    }

    private func shown(ref: String) -> Int? {
        if let corrected = corrections[ref] { return corrected }
        return readings.fields.first { $0.ref == ref }.flatMap(shownValue) ?? currentValue(ref)
    }

    private func isCorrected(_ reading: ScrutinyClient.Reading) -> Bool {
        corrections[reading.ref] != nil || (currentValue(reading.ref) != nil && currentValue(reading.ref) != reading.value)
    }

    private var result: Result {
        var r = Result()
        r.allCorrections = corrections
        for ref in missingRefs { if let corrected = corrections[ref] { r.corrected[ref] = corrected } }
        for reading in readings.fields {
            if let corrected = corrections[reading.ref] {
                r.corrected[reading.ref] = corrected
            } else if currentValue(reading.ref) == nil, let value = reading.value {
                r.accepted[reading.ref] = value
            }
        }
        return r
    }

    private var summary: some View {
        let r = result
        let unread = readings.fields.filter { shownValue($0) == nil }
        return NavigationStack {
            List {
                Section {
                    ForEach(template.categories, id: \.id) { category in
                        let check = writtenCheck(category.id)
                        Label(check.text, systemImage: check.ok ? "checkmark.seal.fill" : "xmark.octagon")
                            .foregroundStyle(check.ok ? Color.green : Color.red)
                    }
                }
                Section("Reconocidos automáticamente (\(r.accepted.count))") {
                    ForEach(r.accepted.sorted { $0.key < $1.key }, id: \.key) { ref, value in
                        LabeledContent(title(for: ref), value: "\(value)")
                    }
                }
                Section("Corregidos por vos (\(r.corrected.count))") {
                    ForEach(r.corrected.sorted { $0.key < $1.key }, id: \.key) { ref, value in
                        LabeledContent(title(for: ref), value: change(ref: ref, to: value))
                    }
                }
                if !unread.isEmpty {
                    Section {
                        ForEach(unread, id: \.ref) { Text(title(for: $0.ref)) }
                    } header: {
                        Text("Sin leer (\(unread.count))")
                    } footer: {
                        Text("Cargalos a mano en el formulario.")
                    }
                }
            }
            .navigationTitle("Resumen del cotejo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Seguir revisando") { showSummary = false } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave(r)
                        showSummary = false
                        dismiss()
                    }
                }
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
                let placed = layoutMarkers(scale: scale)
                ForEach(readings.fields, id: \.ref) { reading in
                    if let spot = placed[reading.ref] { marker(reading, spot: spot) }
                }
            }
            .frame(width: width, height: image.size.height * width / max(1, image.size.width))
        } else {
            ContentUnavailableView("No se encontró la imagen", systemImage: "photo")
        }
    }

    /// Position and font size of a marker on the page.
    struct Spot { let rect: CGRect; let fontSize: CGFloat }

    private func markerText(_ reading: ScrutinyClient.Reading) -> String {
        shownValue(reading).map(String.init) ?? ""
    }

    /// Size each marker to its own cell (zoom in to read small ones) and place it where it
    /// covers neither the handwriting nor another marker: inside the cell beside the ink,
    /// then just outside the cell, then above or below it.
    private func layoutMarkers(scale: CGFloat) -> [String: Spot] {
        let inks = readings.fields.compactMap { $0.valueBox.map { box in
            CGRect(x: CGFloat(box[0]) * scale, y: CGFloat(box[1]) * scale,
                   width: CGFloat(box[2]) * scale, height: CGFloat(box[3]) * scale) } }
        var placed: [String: Spot] = [:]
        var taken: [CGRect] = []
        for reading in readings.fields.sorted(by: { $0.cellBox[1] < $1.cellBox[1] }) {
            guard reading.cellBox.count == 4 else { continue }
            let cell = CGRect(x: CGFloat(reading.cellBox[0]) * scale, y: CGFloat(reading.cellBox[1]) * scale,
                              width: CGFloat(reading.cellBox[2]) * scale, height: CGFloat(reading.cellBox[3]) * scale)
            let fontSize = max(5, min(28, cell.height * 0.55))
            let chars = CGFloat(max(3, markerText(reading).count + (isCorrected(reading) && reading.value != nil ? 4 : 0)))
            let size = CGSize(width: fontSize * 0.7 * chars + fontSize * 1.2, height: fontSize * 1.4)
            let ink = reading.valueBox.map { box in
                CGRect(x: CGFloat(box[0]) * scale, y: CGFloat(box[1]) * scale,
                       width: CGFloat(box[2]) * scale, height: CGFloat(box[3]) * scale) }
            let midY = cell.midY - size.height / 2
            let gap = max(2, fontSize * 0.3)
            var options: [CGPoint] = []
            if let ink {
                options.append(CGPoint(x: ink.maxX + gap, y: midY))
                options.append(CGPoint(x: ink.minX - size.width - gap, y: midY))
            }
            options += [CGPoint(x: cell.maxX - size.width - gap, y: midY),
                        CGPoint(x: cell.minX + gap, y: midY),
                        CGPoint(x: cell.maxX + gap, y: midY),
                        CGPoint(x: cell.minX - size.width - gap, y: midY),
                        CGPoint(x: (ink ?? cell).midX - size.width / 2, y: cell.minY - size.height - 1),
                        CGPoint(x: (ink ?? cell).midX - size.width / 2, y: cell.maxY + 1)]
            func free(_ r: CGRect) -> Bool {
                r.minX >= 0 && r.minY >= 0
                    && !taken.contains { $0.intersects(r) }
                    && !inks.contains { $0.insetBy(dx: 1, dy: 1).intersects(r) }
            }
            let inCell = { (r: CGRect) in cell.insetBy(dx: -1, dy: -1).contains(r) }
            let rects = options.map { CGRect(origin: $0, size: size) }
            let chosen = rects.first { inCell($0) && free($0) } ?? rects.first(where: free) ?? rects[0]
            taken.append(chosen)
            placed[reading.ref] = Spot(rect: chosen, fontSize: fontSize)
        }
        return placed
    }

    private func marker(_ reading: ScrutinyClient.Reading, spot: Spot) -> some View {
        let edited = isCorrected(reading)
        let shown = shownValue(reading)
        let level = ConfidenceLevel(reading.confidence)
        let fontSize = spot.fontSize
        let empty = shown == nil
        let stroke: Color = highlighted == reading.ref ? .orange : (empty ? .orange : (edited ? .blue : level.color))
        let dash = empty && reading.empty == true
        return Button {
            draft = shown.map(String.init) ?? (dash ? "0" : "")
            editing = reading
        } label: {
            HStack(spacing: fontSize * 0.2) {
                if dash {
                    Text("—").font(.system(size: fontSize, weight: .bold)).foregroundStyle(.orange)
                } else if empty {
                    Image(systemName: "pencil").font(.system(size: fontSize * 0.7)).foregroundStyle(.orange)
                } else if edited, let original = reading.value {
                    Text("\(original)").strikethrough().foregroundStyle(.secondary)
                        .font(.system(size: fontSize * 0.6, weight: .regular, design: .rounded))
                }
                Text(shown.map(String.init) ?? "")
                    .font(.system(size: fontSize, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(edited ? Color.blue : level.color)
            }
            .frame(width: spot.rect.width, height: spot.rect.height)
            .background(empty ? Color.yellow.opacity(0.25) : Color.white.opacity(0.85),
                        in: RoundedRectangle(cornerRadius: fontSize * 0.25))
            .overlay {
                RoundedRectangle(cornerRadius: fontSize * 0.25)
                    .stroke(stroke, style: StrokeStyle(lineWidth: highlighted == reading.ref ? 2.5 : 1.2,
                                                       dash: (level.dashed && !edited) || empty ? [3, 2] : []))
            }
        }
        .buttonStyle(.plain)
        .offset(x: spot.rect.minX, y: spot.rect.minY)
        .accessibilityLabel("\(title(for: reading.ref)): \(shown.map(String.init) ?? (dash ? "raya, tocá para confirmar cero" : "vacío, tocá para completar")), \(edited ? "corregido" : level.spoken)")
    }

    /// Fields of the form the server did not locate on the image: filled in by hand below.
    private var missingRefs: [String] {
        let located = Set(readings.fields.map(\.ref))
        let refs = template.headerFields.map { "header.\($0.id)" }
            + template.categories.flatMap { c in template.rows.map { "cells.\(c.id).\($0.id)" } }
            + template.categories.map { "total.\($0.id)" }
        return refs.filter { !located.contains($0) }
    }

    private var missingBoxes: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(missingRefs, id: \.self) { ref in
                    let value = shown(ref: ref)
                    Button {
                        draft = value.map(String.init) ?? ""
                        editing = ScrutinyClient.Reading(ref: ref, value: nil, confidence: 0, cellBox: [], valueBox: nil)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title(for: ref)).font(.caption2).lineLimit(1)
                            Text(value.map(String.init) ?? "✎").font(.body.bold().monospacedDigit())
                                .foregroundStyle(value == nil ? Color.orange : Color.blue)
                        }
                        .padding(6)
                        .frame(minWidth: 90, alignment: .leading)
                        .background(Color.yellow.opacity(value == nil ? 0.25 : 0.08), in: RoundedRectangle(cornerRadius: 6))
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.orange, style: StrokeStyle(lineWidth: 1, dash: [3, 2])))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
        }
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
            Text("Tocá un número o un casillero ✎ para cargarlo").font(.caption).foregroundStyle(.secondary)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(.bar)
    }

    private var footer: some View {
        let votantes = shown(ref: "header.votantes")
        let lines = template.categories.map { category -> String in
            let values = template.rows.map { shown(ref: "cells.\(category.id).\($0.id)") }
            let sum = values.compactMap { $0 }.reduce(0, +)
            let missing = values.filter { $0 == nil }.count
            let check = votantes.map { $0 == sum && missing == 0 ? "✓ coincide con votantes" : "votantes: \($0)" } ?? "falta el total de votantes"
            return "\(category.label): suma \(sum)\(missing > 0 ? " (faltan \(missing))" : "") · \(check)"
        }
        return VStack(alignment: .leading, spacing: 4) {
            ForEach(template.categories, id: \.id) { category in
                let check = writtenCheck(category.id)
                Label(check.text, systemImage: check.ok ? "checkmark.seal.fill" : "xmark.octagon")
                    .font(.subheadline.bold())
                    .foregroundStyle(check.ok ? Color.green : Color.red)
            }
            ForEach(lines, id: \.self) { Text($0).font(.footnote) }
            if !missingRefs.isEmpty {
                Text("No ubicados en la imagen: completalos acá").font(.caption).foregroundStyle(.orange)
                missingBoxes
            }
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
        if parts.first == "total" { return "TOTAL escrito (control)" }
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
