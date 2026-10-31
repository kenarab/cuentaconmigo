import Foundation
import Security
import TelegramaCore

/// Client for the scrutiny backend (contracts/api/scrutiny-v1.openapi.json).
/// Sends a confirmed or draft capture with its page images and reads back OCR
/// suggestions. Results are suggestions only (origin "ocr"); people confirm values.
struct ScrutinyClient {
    struct Failure: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    struct OCRResult {
        let finished: Bool
        let numbers: [Int]
    }

    let baseURL: URL
    let token: String?

    func enroll(code: String, appVersion: String) async throws -> String {
        struct Body: Encodable { let enrollmentCode: String; let platform: String; let appVersion: String }
        struct Reply: Decodable { let deviceToken: String }
        let data = try JSONEncoder().encode(Body(enrollmentCode: code, platform: "ios", appVersion: appVersion))
        let reply: Reply = try await send("POST", "v1/devices/enroll", body: data, contentType: "application/json")
        return reply.deviceToken
    }

    /// Two-step upload: the package first, then only the images the server is missing.
    /// Returns the server's hash-chained receipt as raw JSON, kept on the phone for audits.
    @discardableResult
    func upload(_ capture: Capture, imageData: (Page) -> Data?) async throws -> Data {
        struct Reply: Decodable { let missingBlobs: [String]; let receipt: Receipt }
        struct Receipt: Codable {
            let captureId, bodySha256, receivedAt, prevHash, chainHash, rule: String
            let index: Int
        }
        struct Stored: Decodable { let sha256: String }
        let reply: Reply = try await send("POST", "v1/captures", body: try Capture.encoder.encode(capture),
                                          contentType: "application/json")
        for sha in reply.missingBlobs {
            guard let page = capture.pages.first(where: { $0.sha256 == sha }), let data = imageData(page) else { continue }
            let _: Stored = try await send("PUT", "v1/blobs/\(sha)", body: data, contentType: "image/jpeg")
        }
        return try JSONEncoder().encode(reply.receipt)
    }

    /// One per-cell reading aligned to the printed form (POST /v1/readings, form-layouts SPEC).
    struct Reading: Decodable {
        let ref: String
        let value: Int?
        let confidence: Double
    }

    /// Reads one page image; nothing is stored on the server. Values are suggestions.
    func readings(jpeg: Data, templateId: String) async throws -> [Reading] {
        struct Reply: Decodable { let fields: [Reading] }
        let reply: Reply = try await send("POST", "v1/readings?templateId=\(templateId)", body: jpeg,
                                          contentType: "image/jpeg")
        return reply.fields
    }

    func ocr(captureID: UUID) async throws -> OCRResult {
        struct Page: Decodable { let status: String; let numbers: [Int] }
        struct Reply: Decodable { let results: [Page] }
        let reply: Reply = try await send("GET", "v1/captures/\(captureID.uuidString)/ocr")
        let finished = reply.results.allSatisfy { $0.status == "done" || $0.status == "failed" }
        var seen = Set<Int>()
        return OCRResult(finished: finished,
                         numbers: reply.results.flatMap(\.numbers).filter { seen.insert($0).inserted })
    }

    private func send<T: Decodable>(_ method: String, _ path: String, body: Data? = nil,
                                    contentType: String? = nil) async throws -> T {
        // appendingPathComponent keeps the base prefix (/cuentaconmigo) but would escape "?":
        // add the query separately.
        let pieces = path.split(separator: "?", maxSplits: 1).map(String.init)
        var components = URLComponents(url: baseURL.appendingPathComponent(pieces[0]), resolvingAgainstBaseURL: false)
        if pieces.count == 2 { components?.percentEncodedQuery = pieces[1] }
        guard let url = components?.url else { throw Failure(message: "Dirección del servidor inválida.") }
        var request = URLRequest(url: url, timeoutInterval: 60)
        request.httpMethod = method
        request.httpBody = body
        if let contentType { request.setValue(contentType, forHTTPHeaderField: "Content-Type") }
        if let token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw Failure(message: "No se pudo conectar con el servidor. Revisá la dirección y la red.")
        }
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            let problem = try? JSONDecoder().decode(ProblemDetails.self, from: data)
            throw Failure(message: problem.map { [$0.title, $0.detail].compactMap { $0 }.joined(separator: ": ") }
                          ?? "El servidor respondió \(status).")
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

/// RFC 9457 problem details returned by the server on errors.
private struct ProblemDetails: Decodable { let title: String; let detail: String? }

/// Server address in UserDefaults; device token in the Keychain (this device only).
enum ServerSettings {
    private static let urlKey = "scrutinyServerURL"
    private static let service = "com.kenarab.CuentaConmigo.scrutiny"

    /// Team build default (Resources/server.json, git-ignored, copied by install-device.sh).
    struct Bundled: Decodable { let url: URL; let enrollmentCode: String }
    static let bundled: Bundled? = Bundle.main.url(forResource: "server", withExtension: "json")
        .flatMap { try? Data(contentsOf: $0) }
        .flatMap { try? JSONDecoder().decode(Bundled.self, from: $0) }

    /// Enrolls silently with the bundled server when the phone is not connected yet.
    static func connectIfNeeded(appVersion: String) async {
        guard token == nil, let bundled else { return }
        if let newToken = try? await ScrutinyClient(baseURL: bundled.url, token: nil)
            .enroll(code: bundled.enrollmentCode, appVersion: appVersion) {
            url = bundled.url
            token = newToken
        }
    }

    /// Build default (Info.plist CCDefaultServerURL, sdd/specs/server-location/SPEC.md).
    static let defaultURL: URL? = (Bundle.main.object(forInfoDictionaryKey: "CCDefaultServerURL") as? String)
        .flatMap { $0.isEmpty ? nil : URL(string: $0) }

    static var url: URL? {
        get { UserDefaults.standard.string(forKey: urlKey).flatMap(URL.init(string:)) ?? bundled?.url ?? defaultURL }
        set { UserDefaults.standard.set(newValue?.absoluteString, forKey: urlKey) }
    }

    static var token: String? {
        get {
            let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                        kSecAttrService as String: service,
                                        kSecReturnData as String: true]
            var item: CFTypeRef?
            guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
                  let data = item as? Data else { return nil }
            return String(data: data, encoding: .utf8)
        }
        set {
            let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                        kSecAttrService as String: service]
            SecItemDelete(query as CFDictionary)
            guard let newValue else { return }
            var add = query
            add[kSecValueData as String] = Data(newValue.utf8)
            add[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            SecItemAdd(add as CFDictionary, nil)
        }
    }

    static var client: ScrutinyClient? {
        url.map { ScrutinyClient(baseURL: $0, token: token) }
    }
}
