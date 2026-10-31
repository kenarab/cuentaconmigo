import Foundation
import Observation
import TelegramaCore

/// Local evidence store. Each capture lives in its own folder with immutable page
/// JPEGs and a capture.json following contracts/schemas/capture.schema.json.
/// Files use complete data protection and are excluded from iCloud backup.
@MainActor
@Observable
final class CaptureStore {
    /// Default form for new captures.
    let template: FormTemplate
    /// Every bundled form, by id: a capture uses the form of its own election.
    let templates: [String: FormTemplate]
    private(set) var captures: [Capture] = []
    private(set) var lastError: String?
    private let root: URL
    private let fm = FileManager.default

    static var appInfo: AppInfo {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return AppInfo(platform: "ios", version: version ?? "0")
    }

    init() {
        guard let url = Bundle.main.url(forResource: "generales-2023", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let template = try? FormTemplate.decode(data) else {
            fatalError("Bundled form template is missing or invalid")
        }
        self.template = template
        var all = [template.id: template]
        for id in ["balotaje-2015"] {
            if let url = Bundle.main.url(forResource: id, withExtension: "json"),
               let data = try? Data(contentsOf: url), let other = try? FormTemplate.decode(data) {
                all[other.id] = other
            }
        }
        templates = all
        let support = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        var root = support.appendingPathComponent("Captures", isDirectory: true)
        try? fm.createDirectory(at: root, withIntermediateDirectories: true,
                                attributes: [.protectionKey: FileProtectionType.complete])
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try? root.setResourceValues(values)
        self.root = root
        reload()
    }

    func reload() {
        let dirs = (try? fm.contentsOfDirectory(at: root, includingPropertiesForKeys: nil)) ?? []
        captures = dirs.compactMap { dir in
            guard let data = try? Data(contentsOf: dir.appendingPathComponent("capture.json")) else { return nil }
            return try? Capture.decoder.decode(Capture.self, from: data)
        }.sorted { $0.createdAt > $1.createdAt }
    }

    func folder(for id: UUID) -> URL { root.appendingPathComponent(id.uuidString, isDirectory: true) }
    func jsonURL(for id: UUID) -> URL { folder(for: id).appendingPathComponent("capture.json") }
    func pageURL(_ page: Page, of id: UUID) -> URL { folder(for: id).appendingPathComponent(page.file) }

    /// Values corrected by the person during the visual check (including the written TOTAL,
    /// which is not a form field). Local to the phone, outside the evidence package; they
    /// always win over automatic readings.
    func reviewCorrections(for id: UUID) -> [String: Int?] {
        guard let data = try? Data(contentsOf: folder(for: id).appendingPathComponent("review-corrections.json")),
              let map = try? JSONDecoder().decode([String: Int?].self, from: data) else { return [:] }
        return map
    }

    func saveReviewCorrections(_ map: [String: Int?], for id: UUID) {
        guard let data = try? JSONEncoder().encode(map) else { return }
        try? data.write(to: folder(for: id).appendingPathComponent("review-corrections.json"),
                        options: [.atomic, .completeFileProtection])
    }

    func template(for capture: Capture) -> FormTemplate { templates[capture.templateId] ?? template }

    func create(documentType: DocumentType = .telegrama) -> Capture {
        let capture = Capture(template: template, documentType: documentType, app: Self.appInfo)
        try? fm.createDirectory(at: folder(for: capture.id), withIntermediateDirectories: true,
                                attributes: [.protectionKey: FileProtectionType.complete])
        save(capture)
        return capture
    }

    /// Writes a new page once; existing page files are never overwritten.
    func addPage(jpeg: Data, source: PageSource, to capture: inout Capture) throws {
        guard !capture.isLocked else { throw CaptureError.alreadyConfirmed }
        let page = Page(file: "page-\(capture.pages.count + 1).jpg",
                        sha256: EvidenceHash.sha256Hex(jpeg),
                        capturedAt: Date(), source: source)
        try jpeg.write(to: pageURL(page, of: capture.id), options: [.withoutOverwriting, .completeFileProtection])
        try capture.appendPage(page)
        save(capture)
    }

    func save(_ capture: Capture) {
        do {
            let data = try Capture.encoder.encode(capture)
            try data.write(to: jsonURL(for: capture.id), options: [.atomic, .completeFileProtection])
            if let i = captures.firstIndex(where: { $0.id == capture.id }) {
                captures[i] = capture
            } else {
                captures.insert(capture, at: 0)
            }
            lastError = nil
        } catch {
            lastError = "No se pudo guardar la captura: \(error.localizedDescription)"
        }
    }

    /// Receipts of every submission to the server, appended and never removed.
    func receiptsURL(for id: UUID) -> URL { folder(for: id).appendingPathComponent("receipts.jsonl") }

    /// A capture sent to the server is proof of what was submitted: it can no longer be deleted.
    func wasSent(_ capture: Capture) -> Bool { fm.fileExists(atPath: receiptsURL(for: capture.id).path) }

    func appendReceipt(_ receipt: Data, for id: UUID) {
        let url = receiptsURL(for: id)
        let line = receipt + Data("\n".utf8)
        if let handle = try? FileHandle(forWritingTo: url) {
            handle.seekToEndOfFile()
            handle.write(line)
            try? handle.close()
        } else {
            try? line.write(to: url, options: [.completeFileProtection])
        }
        captures = captures  // refresh views that depend on wasSent
    }

    /// Unsent captures (drafts or confirmed) can be deleted; sent ones are kept as proof.
    func delete(_ capture: Capture) {
        guard !wasSent(capture) else { return }
        try? fm.removeItem(at: folder(for: capture.id))
        captures.removeAll { $0.id == capture.id }
    }

    func exportURLs(for capture: Capture) -> [URL] {
        [jsonURL(for: capture.id)] + capture.pages.map { pageURL($0, of: capture.id) }
            + (wasSent(capture) ? [receiptsURL(for: capture.id)] : [])
    }
}
