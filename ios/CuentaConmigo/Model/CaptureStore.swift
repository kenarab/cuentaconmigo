import Foundation
import Observation
import TelegramaCore

/// Local evidence store. Each capture lives in its own folder with immutable page
/// JPEGs and a capture.json following contracts/schemas/capture.schema.json.
/// Files use complete data protection and are excluded from iCloud backup.
@MainActor
@Observable
final class CaptureStore {
    let template: FormTemplate
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

    /// Only drafts can be deleted; confirmed evidence stays.
    func deleteDraft(_ capture: Capture) {
        guard !capture.isLocked else { return }
        try? fm.removeItem(at: folder(for: capture.id))
        captures.removeAll { $0.id == capture.id }
    }

    func exportURLs(for capture: Capture) -> [URL] {
        [jsonURL(for: capture.id)] + capture.pages.map { pageURL($0, of: capture.id) }
    }
}
