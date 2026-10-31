import Foundation

public enum Severity: String, Codable, Sendable { case error, warning }

public enum DocumentType: String, Codable, CaseIterable, Sendable {
    case telegrama, acta, certificado

    public var label: String {
        switch self {
        case .telegrama: "Telegrama"
        case .acta: "Acta de escrutinio"
        case .certificado: "Certificado de escrutinio"
        }
    }
}

/// Declarative form definition (contracts/templates). Replacing the template must
/// not require code changes.
public struct FormTemplate: Codable, Equatable, Sendable {
    public struct Field: Codable, Equatable, Sendable, Identifiable {
        public let id: String
        public let label: String
        public let required: Bool?
        public var isRequired: Bool { required ?? true }
    }
    public struct Category: Codable, Equatable, Sendable, Identifiable {
        public let id: String
        public let label: String
    }
    public struct Row: Codable, Equatable, Sendable, Identifiable {
        public let id: String
        public let label: String
        public let kind: String
    }
    public struct Rule: Codable, Equatable, Sendable { public let severity: Severity }
    public struct Rules: Codable, Equatable, Sendable {
        public let votantesMaxElectores: Rule?
        public let categoryTotalEqualsVotantes: Rule?
    }

    public let id: String
    public let version: Int
    public let fictitious: Bool
    public let title: String
    public let documentTypes: [DocumentType]
    public let mesaFields: [Field]
    public let headerFields: [Field]
    public let categories: [Category]
    public let rows: [Row]
    public let rules: Rules

    public static func decode(_ data: Data) throws -> FormTemplate {
        try JSONDecoder().decode(FormTemplate.self, from: data)
    }
}
