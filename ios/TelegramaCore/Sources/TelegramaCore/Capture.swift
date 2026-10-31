import Foundation

public enum ValueOrigin: String, Codable, Sendable {
    case manual
    case ocrAccepted = "ocr-accepted"
}

public struct CellValue: Codable, Equatable, Sendable {
    public var value: Int?
    public var origin: ValueOrigin
    public init(value: Int?, origin: ValueOrigin = .manual) {
        self.value = value; self.origin = origin
    }
}

public struct Mesa: Codable, Equatable, Sendable {
    public var distrito = "", seccion = "", circuito = "", mesa = ""
    public init(distrito: String = "", seccion: String = "", circuito: String = "", mesa: String = "") {
        self.distrito = distrito; self.seccion = seccion; self.circuito = circuito; self.mesa = mesa
    }
    public subscript(field: String) -> String? {
        get {
            switch field {
            case "distrito": distrito
            case "seccion": seccion
            case "circuito": circuito
            case "mesa": mesa
            default: nil
            }
        }
        set {
            let v = newValue ?? ""
            switch field {
            case "distrito": distrito = v
            case "seccion": seccion = v
            case "circuito": circuito = v
            case "mesa": mesa = v
            default: break
            }
        }
    }
}

public enum PageSource: String, Codable, Sendable { case scanner, photos }

/// One immutable page image, referenced by file name and SHA-256 of its bytes.
public struct Page: Codable, Equatable, Sendable {
    public let file: String
    public let sha256: String
    public let capturedAt: Date
    public let source: PageSource
    public init(file: String, sha256: String, capturedAt: Date, source: PageSource) {
        self.file = file; self.sha256 = sha256; self.capturedAt = capturedAt; self.source = source
    }
}

public enum CaptureStatus: String, Codable, Sendable { case draft, confirmed }

public struct AppInfo: Codable, Equatable, Sendable {
    public let platform: String
    public let version: String
    public init(platform: String, version: String) { self.platform = platform; self.version = version }
}

public enum CaptureError: Error, Equatable {
    case alreadyConfirmed
    case hasErrors([ValidationIssue])
    case warningsNeedJustification
}

/// Capture package as defined by contracts/schemas/capture.schema.json.
public struct Capture: Codable, Equatable, Sendable, Identifiable {
    public var schemaVersion = 1
    public let id: UUID
    public let templateId: String
    public let templateVersion: Int
    public var documentType: DocumentType
    public var mesa: Mesa
    public var pages: [Page]
    public var header: [String: CellValue]
    public var cells: [String: [String: CellValue]]
    public private(set) var status: CaptureStatus
    public private(set) var warningJustification: String?
    public let createdAt: Date
    public private(set) var confirmedAt: Date?
    public let app: AppInfo

    public init(id: UUID = UUID(), template: FormTemplate, documentType: DocumentType,
                createdAt: Date = Date(), app: AppInfo) {
        self.id = id
        templateId = template.id
        templateVersion = template.version
        self.documentType = documentType
        mesa = Mesa()
        pages = []
        header = [:]
        cells = [:]
        status = .draft
        self.createdAt = createdAt
        self.app = app
    }

    public var isLocked: Bool { status == .confirmed }

    public func value(header field: String) -> Int? { header[field]?.value }
    public func value(category: String, row: String) -> Int? { cells[category]?[row]?.value }

    public mutating func set(header field: String, _ value: Int?, origin: ValueOrigin = .manual) throws {
        guard !isLocked else { throw CaptureError.alreadyConfirmed }
        header[field] = CellValue(value: value, origin: origin)
    }

    public mutating func set(category: String, row: String, _ value: Int?,
                             origin: ValueOrigin = .manual) throws {
        guard !isLocked else { throw CaptureError.alreadyConfirmed }
        cells[category, default: [:]][row] = CellValue(value: value, origin: origin)
    }

    public var validationInput: ValidationInput {
        ValidationInput(
            mesa: ["distrito": mesa.distrito, "seccion": mesa.seccion,
                   "circuito": mesa.circuito, "mesa": mesa.mesa],
            header: header.mapValues { $0.value },
            cells: cells.mapValues { $0.mapValues { $0.value } })
    }

    /// Locks the capture. Errors block; warnings require a written justification.
    public mutating func confirm(template: FormTemplate, justification: String? = nil,
                                 at date: Date = Date()) throws {
        guard !isLocked else { throw CaptureError.alreadyConfirmed }
        let issues = Validator.validate(validationInput, template: template)
        let errors = issues.filter { $0.severity == .error }
        guard errors.isEmpty else { throw CaptureError.hasErrors(errors) }
        let note = justification?.trimmingCharacters(in: .whitespacesAndNewlines)
        if issues.contains(where: { $0.severity == .warning }) {
            guard let note, !note.isEmpty else { throw CaptureError.warningsNeedJustification }
            warningJustification = note
        }
        status = .confirmed
        confirmedAt = date
    }

    public static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return e
    }()

    public static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}
