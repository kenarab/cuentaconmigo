import Foundation
import TelegramaCore

/// Demo telegrams bundled for testing (F-17): real 2023 per-table figures on a
/// generated, watermarked form without personal data. Built by
/// scripts/samples/make_sample_telegrams.py.
struct SampleTelegram: Decodable, Identifiable {
    let id: String
    let file: String
    let documentType: DocumentType
    let label: String
    let mesa: Mesa

    private struct Manifest: Decodable { let samples: [SampleTelegram] }

    static let all: [SampleTelegram] = {
        guard let url = resource("samples", "json"),
              let data = try? Data(contentsOf: url),
              let manifest = try? JSONDecoder().decode(Manifest.self, from: data) else { return [] }
        return manifest.samples
    }()

    var imageData: Data? {
        let name = (file as NSString).deletingPathExtension
        let ext = (file as NSString).pathExtension
        return Self.resource(name, ext).flatMap { try? Data(contentsOf: $0) }
    }

    /// Synchronized folders may keep or flatten the Samples subfolder in the bundle.
    private static func resource(_ name: String, _ ext: String) -> URL? {
        Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Samples")
            ?? Bundle.main.url(forResource: name, withExtension: ext)
    }
}
