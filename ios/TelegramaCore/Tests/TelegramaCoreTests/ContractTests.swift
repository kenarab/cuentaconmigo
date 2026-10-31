import Foundation
import XCTest
@testable import TelegramaCore

/// Runs the shared conformance vectors in /contracts. Android must pass the same files.
final class ContractTests: XCTestCase {
    static let repoRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().deletingLastPathComponent()

    func load(_ path: String) throws -> Data {
        try Data(contentsOf: Self.repoRoot.appendingPathComponent(path))
    }

    func template() throws -> FormTemplate {
        try FormTemplate.decode(load("contracts/templates/demo-2027.json"))
    }

    func testValidationVectors() throws {
        struct Expected: Decodable, Hashable { let code: String; let severity: Severity; let path: String }
        struct Case: Decodable { let name: String; let input: ValidationInput; let expected: [Expected] }
        struct File: Decodable { let cases: [Case] }
        let file = try JSONDecoder().decode(File.self, from: load("contracts/vectors/validation.json"))
        let template = try template()
        XCTAssertFalse(file.cases.isEmpty)
        for c in file.cases {
            let got = Set(Validator.validate(c.input, template: template).map {
                Expected(code: $0.code, severity: $0.severity, path: $0.path)
            })
            XCTAssertEqual(got, Set(c.expected), c.name)
        }
    }

    func testDigitVectors() throws {
        struct Case: Decodable { let input: String; let expected: Int? }
        struct File: Decodable { let cases: [Case] }
        let file = try JSONDecoder().decode(File.self, from: load("contracts/vectors/digits.json"))
        XCTAssertFalse(file.cases.isEmpty)
        for c in file.cases {
            XCTAssertEqual(DigitNormalizer.normalize(c.input), c.expected, "input: \(c.input)")
        }
    }

    func testExampleCaptureRoundTrips() throws {
        let data = try load("contracts/examples/capture.example.json")
        let capture = try Capture.decoder.decode(Capture.self, from: data)
        let reencoded = try Capture.encoder.encode(capture)
        XCTAssertEqual(try Capture.decoder.decode(Capture.self, from: reencoded), capture)

        func stripNulls(_ v: Any) -> Any {
            if let d = v as? [String: Any] {
                return d.filter { !($0.value is NSNull) }.mapValues(stripNulls)
            }
            if let a = v as? [Any] { return a.map(stripNulls) }
            return v
        }
        let original = stripNulls(try JSONSerialization.jsonObject(with: data)) as! NSDictionary
        let roundTrip = stripNulls(try JSONSerialization.jsonObject(with: reencoded)) as! NSDictionary
        XCTAssertEqual(original, roundTrip)
        XCTAssertTrue(Validator.validate(capture.validationInput, template: try template()).isEmpty)
    }

    func testBundledTemplateMatchesContract() throws {
        XCTAssertEqual(try load("ios/CuentaConmigo/Resources/demo-2027.json"),
                       try load("contracts/templates/demo-2027.json"),
                       "Run ios/scripts/sync-contracts.sh")
    }
}

final class CaptureTests: XCTestCase {
    func template() throws -> FormTemplate {
        try FormTemplate.decode(Data(contentsOf: ContractTests.repoRoot
            .appendingPathComponent("contracts/templates/demo-2027.json")))
    }

    func filled(_ t: FormTemplate) throws -> Capture {
        var c = Capture(template: t, documentType: .telegrama, app: AppInfo(platform: "ios", version: "test"))
        try c.setMesa(Mesa(distrito: "99", seccion: "001", circuito: "0001", mesa: "00042"))
        try c.set(header: "votantes", 70)
        for cat in t.categories { for row in t.rows { try c.set(category: cat.id, row: row.id, 10) } }
        return c
    }

    func testConfirmLocksCapture() throws {
        let t = try template()
        var c = try filled(t)
        try c.confirm(template: t)
        XCTAssertTrue(c.isLocked)
        XCTAssertNotNil(c.confirmedAt)
        let page = Page(file: "page-1.jpg", sha256: String(repeating: "0", count: 64),
                        capturedAt: Date(), source: .scanner)
        let mutations: [(inout Capture) throws -> Void] = [
            { try $0.set(header: "votantes", 1) },
            { try $0.set(category: "presidente", row: "lista-a", 1) },
            { try $0.setMesa("mesa", "1") },
            { try $0.setMesa(Mesa()) },
            { try $0.setDocumentType(.acta) },
            { try $0.appendPage(page) },
        ]
        let before = c
        for mutate in mutations {
            XCTAssertThrowsError(try mutate(&c)) { XCTAssertEqual($0 as? CaptureError, .alreadyConfirmed) }
        }
        XCTAssertEqual(c, before, "A confirmed capture must not change")
    }

    func testErrorsBlockConfirmation() throws {
        let t = try template()
        var c = try filled(t)
        try c.setMesa("mesa", "")
        XCTAssertThrowsError(try c.confirm(template: t))
        XCTAssertFalse(c.isLocked)
    }

    func testWarningsNeedJustification() throws {
        let t = try template()
        var c = try filled(t)
        try c.set(header: "votantes", 71)
        XCTAssertThrowsError(try c.confirm(template: t, justification: "  ")) {
            XCTAssertEqual($0 as? CaptureError, .warningsNeedJustification)
        }
        try c.confirm(template: t, justification: "El telegrama tiene un voto recurrido sin anotar")
        XCTAssertEqual(c.warningJustification, "El telegrama tiene un voto recurrido sin anotar")
    }

    func testSHA256Hex() {
        XCTAssertEqual(EvidenceHash.sha256Hex(Data("test".utf8)),
                       "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08")
    }
}
