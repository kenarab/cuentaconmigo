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
            documentSection(capture)
            mesaSection(capture)
            if !detectedNumbers.isEmpty && !capture.isLocked { ocrSection }
            Section("Totales de la mesa") {
                ForEach(template.headerFields) { field in
                    numberRow(field.label + (field.isRequired ? "" : " (opcional)"), key: .header(field.id))
                }
            }
            ForEach(template.categories) { category in
                Section(category.label) {
                    ForEach(template.rows) { row in
                        numberRow(row.label, key: .cell(category.id, row.id))
                    }
                }
            }
            validationSection(issues)
            actionsSection(capture, issues: issues)
        }
        .scrollDismissesKeyboard(.interactively)
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
            }
        }
    }

    private func mesaSection(_ capture: Capture) -> some View {
        Section("Mesa") {
            ForEach(template.mesaFields) { field in
                TextField(field.label, text: Binding(
                    get: { self.capture?.mesa[field.id] ?? "" },
                    set: { try? self.capture?.setMesa(field.id, $0) }))
                    .keyboardType(.numbersAndPunctuation)
                    .textInputAutocapitalization(.characters)
                    .disabled(capture.isLocked)
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
