import PhotosUI
import SwiftUI
import TelegramaCore

enum FieldKey: Hashable {
    case header(String)
    case cell(String, String)
}

struct CaptureEditorView: View {
    let captureID: UUID
    @Environment(CaptureStore.self) private var store
    @State private var capture: Capture?
    @State private var detectedNumbers: [Int] = []
    @State private var showScanner = false
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var viewing: URL?
    @State private var showJustification = false
    @State private var justification = ""
    @State private var message: String?
    @State private var showServer = false
    @State private var showDoubleEntry = false
    @State private var step = 0
    @AppStorage("presentation") private var presentation = Presentation.split
    @State private var serverStatus: String?
    @State private var readingSet: ScrutinyClient.ReadingSet?
    @State private var showReview = false
    @FocusState private var focus: FieldKey?

    private var template: FormTemplate { store.template }

    var body: some View {
        Group {
            if let capture { form(capture) } else { ProgressView() }
        }
        .navigationTitle(capture.map { $0.mesa.mesa.isEmpty ? "Nueva captura" : "Mesa \($0.mesa.mesa)" } ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { capture = store.captures.first { $0.id == captureID } }
        .onChange(of: capture) { _, new in if let new { store.save(new) } }
        .fullScreenCover(isPresented: $showScanner) {
            DocumentScanner(onFinish: { images in
                showScanner = false
                Task { await add(images.compactMap { $0.jpegData(compressionQuality: 0.9) }, source: .scanner) }
            }, onCancel: { showScanner = false })
            .ignoresSafeArea()
        }
        .sheet(item: $viewing) { PageViewer(url: $0) }
        .sheet(isPresented: $showDoubleEntry) {
            if let capture { DoubleEntryView(template: template, capture: capture) }
        }
        .fullScreenCover(isPresented: $showReview) {
            if let capture, let readingSet, let page = capture.pages.first {
                ReadingReviewView(imageURL: store.pageURL(page, of: capture.id), readings: readingSet,
                                  template: template,
                                  currentValue: { ref in key(for: ref).flatMap { value(for: $0) } },
                                  onEdit: { ref, newValue in
                                      if let key = key(for: ref) { set(newValue, for: key, origin: .manual) }
                                  })
            }
        }
        .sheet(isPresented: $showServer) {
            ServerSettingsView(appVersion: CaptureStore.appInfo.version) { Task { await readWithServer() } }
        }
        .onChange(of: photoItems) { _, items in
            guard !items.isEmpty else { return }
            Task {
                var jpegs: [Data] = []
                for item in items {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let jpeg = UIImage(data: data)?.jpegData(compressionQuality: 0.9) {
                        jpegs.append(jpeg)
                    }
                }
                photoItems = []
                await add(jpegs, source: .photos)
            }
        }
        .alert("Hay avisos", isPresented: $showJustification) {
            TextField("Explicá por qué confirmás igual", text: $justification)
            Button("Confirmar") { confirm(justification: justification) }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Los totales no coinciden. Si el documento dice eso, escribí una breve justificación.")
        }
        .alert(message ?? "", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
            Button("OK", role: .cancel) {}
        }
    }

    // MARK: - Form

    @ViewBuilder
    private func form(_ capture: Capture) -> some View {
        let issues = Validator.validate(capture.validationInput, template: template)
        Form {
            if capture.isLocked {
                Section {
                    Label("Captura confirmada. Ya no se puede editar.", systemImage: "lock.fill")
                }
            }
            if presentation == .wizard && !capture.isLocked {
                wizardStep(capture, issues: issues)
            } else {
                documentSection(capture)
                mesaSection(capture)
                if !detectedNumbers.isEmpty && !capture.isLocked { ocrSection }
                totalsSection
                ForEach(template.categories) { categorySection($0) }
                validationSection(issues)
                actionsSection(capture, issues: issues)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var totalsSection: some View {
        Section("Totales de la mesa") {
            ForEach(template.headerFields) { field in
                numberRow(field.label + (field.isRequired ? "" : " (opcional)"), key: .header(field.id))
            }
        }
    }

    private func categorySection(_ category: FormTemplate.Category) -> some View {
        Section(category.label) {
            ForEach(template.rows) { row in
                numberRow(row.label, key: .cell(category.id, row.id))
            }
        }
    }

    /// F-1: one section per screen. Steps: document, table, totals, each category, review.
    @ViewBuilder
    private func wizardStep(_ capture: Capture, issues: [ValidationIssue]) -> some View {
        let count = 4 + template.categories.count
        let current = min(step, count - 1)
        Section {
            ProgressView(value: Double(current + 1), total: Double(count))
            Text("Paso \(current + 1) de \(count)").font(.footnote).foregroundStyle(.secondary)
        }
        switch current {
        case 0: documentSection(capture)
        case 1: mesaSection(capture)
        case 2:
            if !detectedNumbers.isEmpty { ocrSection }
            totalsSection
        case count - 1:
            validationSection(issues)
            actionsSection(capture, issues: issues)
        default:
            if !detectedNumbers.isEmpty { ocrSection }
            categorySection(template.categories[current - 3])
        }
        Section {
            HStack {
                Button("Anterior") { step = max(current - 1, 0) }
                    .disabled(current == 0)
                Spacer()
                Button("Siguiente") { step = min(current + 1, count - 1) }
                    .disabled(current == count - 1)
                    .buttonStyle(.borderedProminent)
            }
        }
    }

    private func documentSection(_ capture: Capture) -> some View {
        Section("Documento") {
            Picker("Tipo", selection: Binding(get: { capture.documentType },
                                              set: { try? self.capture?.setDocumentType($0) })) {
                ForEach(template.documentTypes, id: \.self) { Text($0.label).tag($0) }
            }
            .disabled(capture.isLocked)
            if !capture.pages.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(capture.pages, id: \.file) { page in
                            let url = store.pageURL(page, of: capture.id)
                            Button { viewing = url } label: {
                                if let image = UIImage(contentsOfFile: url.path) {
                                    Image(uiImage: image).resizable().scaledToFit().frame(height: 120)
                                }
                            }
                            .accessibilityLabel("Ver \(page.file)")
                        }
                    }
                }
            }
            if !capture.isLocked {
                Label("Nunca fotografíes la Boleta Única: está prohibido. Sólo telegrama, acta o certificado de escrutinio.",
                      systemImage: "hand.raised.fill")
                    .font(.callout)
                    .foregroundStyle(.red)
                if DocumentScanner.isAvailable {
                    Button { showScanner = true } label: {
                        Label("Escanear documento", systemImage: "doc.viewfinder")
                    }
                }
                PhotosPicker(selection: $photoItems, matching: .images) {
                    Label("Importar desde Fotos", systemImage: "photo.on.rectangle")
                }
                if !capture.pages.isEmpty {
                    Button {
                        Task {
                            await ServerSettings.connectIfNeeded(appVersion: CaptureStore.appInfo.version)
                            if ServerSettings.token == nil { showServer = true } else { await readWithServer() }
                        }
                    } label: {
                        Label("Leer números con el servidor", systemImage: "text.viewfinder")
                    }
                    if let serverStatus {
                        Text(serverStatus).font(.footnote).foregroundStyle(.secondary)
                    }
                    if readingSet != nil {
                        Button { showReview = true } label: {
                            Label("Cotejar sobre la imagen", systemImage: "rectangle.and.text.magnifyingglass")
                        }
                    }
                }
                if !SampleTelegram.all.isEmpty {
                    Menu {
                        ForEach(SampleTelegram.all) { sample in
                            Button(sample.label) { Task { await use(sample) } }
                        }
                    } label: {
                        Label("Usar un telegrama de ejemplo", systemImage: "doc.text.image")
                    }
                }
            }
        }
    }

    private func mesaSection(_ capture: Capture) -> some View {
        Section {
            if let places = PollingPlaces.shared, !capture.isLocked {
                MesaPicker(places: places, mesa: capture.mesa) { try? self.capture?.setMesa($0) }
            }
            ForEach(template.mesaFields) { field in
                TextField(field.label, text: Binding(
                    get: { self.capture?.mesa[field.id] ?? "" },
                    set: { try? self.capture?.setMesa(field.id, $0) }))
                    .keyboardType(.numbersAndPunctuation)
                    .textInputAutocapitalization(.characters)
                    .disabled(capture.isLocked)
            }
        } header: {
            Text("Mesa")
        } footer: {
            if PollingPlaces.shared != nil && !capture.isLocked {
                Text("Elegí distrito, sección, establecimiento y mesa; los códigos se completan solos. También podés corregirlos a mano.")
            }
        }
    }

    private var ocrSection: some View {
        Section {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(Array(detectedNumbers.enumerated()), id: \.offset) { _, number in
                        Button("\(number)") { fillFocused(with: number) }
                            .buttonStyle(.bordered)
                            .disabled(focus == nil)
                    }
                }
            }
        } header: {
            Text("Números detectados")
        } footer: {
            Text("Tocá un campo y después un número para copiarlo. Revisá siempre contra la imagen.")
        }
    }

    private func validationSection(_ issues: [ValidationIssue]) -> some View {
        Section("Validación") {
            if issues.isEmpty {
                Label("Todo cierra", systemImage: "checkmark.seal.fill").foregroundStyle(.green)
            }
            ForEach(issues, id: \.self) { issue in
                Label(describe(issue), systemImage: issue.severity == .error
                      ? "xmark.octagon.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(issue.severity == .error ? .red : .orange)
            }
        }
    }

    @ViewBuilder
    private func actionsSection(_ capture: Capture, issues: [ValidationIssue]) -> some View {
        Section {
            if capture.isLocked {
                ShareLink(items: store.exportURLs(for: capture)) {
                    Label("Exportar evidencia", systemImage: "square.and.arrow.up")
                }
            } else {
                if presentation == .doubleEntry {
                    Button { showDoubleEntry = true } label: {
                        Label("Verificar con otra persona", systemImage: "person.2")
                    }
                }
                Button {
                    if issues.contains(where: { $0.severity == .warning }) {
                        showJustification = true
                    } else {
                        confirm(justification: nil)
                    }
                } label: {
                    Label("Confirmar captura", systemImage: "lock")
                }
                .disabled(capture.pages.isEmpty || issues.contains { $0.severity == .error })
            }
        } footer: {
            if !capture.isLocked {
                Text(capture.pages.isEmpty
                     ? "Agregá al menos una imagen del documento."
                     : "Al confirmar, la captura queda bloqueada como evidencia.")
            }
        }
    }

    // MARK: - Values

    private func numberRow(_ label: String, key: FieldKey) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("—", text: Binding(get: { text(for: key) }, set: { setText($0, for: key) }))
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 100)
                .focused($focus, equals: key)
                .disabled(capture?.isLocked ?? true)
                .accessibilityLabel(label)
        }
    }

    private func value(for key: FieldKey) -> Int? {
        switch key {
        case .header(let id): capture?.value(header: id)
        case .cell(let cat, let row): capture?.value(category: cat, row: row)
        }
    }

    private func text(for key: FieldKey) -> String { value(for: key).map(String.init) ?? "" }

    private func setText(_ text: String, for key: FieldKey) {
        let digits = text.filter(\.isNumber)
        set(digits.isEmpty ? nil : Int(digits.prefix(9)), for: key, origin: .manual)
    }

    private func set(_ value: Int?, for key: FieldKey, origin: ValueOrigin) {
        switch key {
        case .header(let id): try? capture?.set(header: id, value, origin: origin)
        case .cell(let cat, let row): try? capture?.set(category: cat, row: row, value, origin: origin)
        }
    }

    private func fillFocused(with number: Int) {
        guard let focus else { return }
        set(number, for: focus, origin: .ocrAccepted)
    }

    // MARK: - Actions

    private func add(_ jpegs: [Data], source: PageSource) async {
        guard var current = capture else { return }
        do {
            for jpeg in jpegs { try store.addPage(jpeg: jpeg, source: source, to: &current) }
            capture = current
        } catch {
            message = "No se pudo guardar la imagen."
        }
        var found: [Int] = []
        for jpeg in jpegs { found += await TextRecognizer.numbers(in: jpeg) }
        var seen = Set(detectedNumbers)
        detectedNumbers += found.filter { seen.insert($0).inserted }
    }

    /// Sends the capture to the scrutiny server and adds its OCR numbers as suggestions.
    private func readWithServer() async {
        guard let current = capture, let client = ServerSettings.client else {
            showServer = true
            return
        }
        serverStatus = "Enviando al servidor…"
        do {
            let receipt = try await client.upload(current) { try? Data(contentsOf: store.pageURL($0, of: current.id)) }
            store.appendReceipt(receipt, for: current.id)
            serverStatus = "Leyendo los números…"
            let filled = await fillFromReadings(current, client: client)
            for _ in 0..<30 {
                let result = try await client.ocr(captureID: current.id)
                if result.finished {
                    var seen = Set(detectedNumbers)
                    detectedNumbers += result.numbers.filter { seen.insert($0).inserted }
                    serverStatus = filled > 0
                        ? "Listo: el servidor completó \(filled) campos. Cotejalos sobre la imagen."
                        : result.numbers.isEmpty
                        ? "El servidor no encontró números. Cargalos mirando la imagen."
                        : "Listo: el servidor sugirió \(result.numbers.count) números. Revisalos contra la imagen."
                    return
                }
                try await Task.sleep(for: .seconds(2))
            }
            serverStatus = "El servidor sigue procesando. Probá de nuevo en un rato."
        } catch {
            serverStatus = error.localizedDescription
        }
    }

    /// Fills empty fields with the server's per-cell readings of the first page (origin
    /// "ocr-accepted": the person still reviews and can edit every value). Returns how many.
    private func fillFromReadings(_ current: Capture, client: ScrutinyClient) async -> Int {
        guard let page = current.pages.first,
              let jpeg = try? Data(contentsOf: store.pageURL(page, of: current.id)),
              var readings = try? await client.readings(jpeg: jpeg, templateId: current.templateId) else { return 0 }
        // Only cells of this form can be checked on the image.
        readings = ScrutinyClient.ReadingSet(image: readings.image, alignment: readings.alignment,
                                             fields: readings.fields.filter { key(for: $0.ref) != nil },
                                             masks: readings.masks)
        var filled = 0
        for reading in readings.fields {
            guard let value = reading.value, let key = key(for: reading.ref), self.value(for: key) == nil else { continue }
            set(value, for: key, origin: .ocrAccepted)
            filled += 1
        }
        readingSet = readings.fields.isEmpty ? nil : readings
        if readingSet != nil { showReview = true }
        return filled
    }

    /// Field of this form for a contract reference such as "cells.presidente.blanco".
    private func key(for ref: String) -> FieldKey? {
        let parts = ref.split(separator: ".").map(String.init)
        if parts.count == 2, parts[0] == "header", template.headerFields.contains(where: { $0.id == parts[1] }) {
            return .header(parts[1])
        }
        if parts.count == 3, parts[0] == "cells", template.categories.contains(where: { $0.id == parts[1] }),
           template.rows.contains(where: { $0.id == parts[2] }) {
            return .cell(parts[1], parts[2])
        }
        return nil
    }

    /// Loads a bundled demo telegram and fills the table identification (F-17).
    private func use(_ sample: SampleTelegram) async {
        guard let jpeg = sample.imageData else {
            message = "No se encontró el ejemplo."
            return
        }
        try? capture?.setDocumentType(sample.documentType)
        try? capture?.setMesa(sample.mesa)
        await add([jpeg], source: .sample)
    }

    private func confirm(justification: String?) {
        guard var current = capture else { return }
        do {
            try current.confirm(template: template, justification: justification)
            capture = current
        } catch CaptureError.warningsNeedJustification {
            message = "Escribí una justificación para confirmar con avisos."
        } catch {
            message = "Hay errores que corregir antes de confirmar."
        }
    }

    private func describe(_ issue: ValidationIssue) -> String {
        let parts = issue.path.split(separator: ".").map(String.init)
        func rowLabel() -> String {
            guard parts.count == 3 else { return "" }
            let cat = template.categories.first { $0.id == parts[1] }?.label ?? parts[1]
            let row = template.rows.first { $0.id == parts[2] }?.label ?? parts[2]
            return "\(cat): \(row)"
        }
        switch issue.code {
        case "missing_mesa":
            return "Falta \(template.mesaFields.first { $0.id == parts.last }?.label ?? "un dato de la mesa")"
        case "missing_value":
            if parts.first == "header" {
                return "Falta \(template.headerFields.first { $0.id == parts.last }?.label ?? "un total")"
            }
            return "Falta el valor de \(rowLabel())"
        case "negative_value": return "Valor negativo en \(rowLabel())"
        case "votantes_exceed_electores": return "Hay más votantes que electores habilitados"
        case "category_total_mismatch":
            let cat = template.categories.first { $0.id == parts.last }?.label ?? ""
            return "\(cat): la suma no coincide con el total de votantes"
        default: return issue.code
        }
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
