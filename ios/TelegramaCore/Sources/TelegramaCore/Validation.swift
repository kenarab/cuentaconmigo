import Foundation

public struct ValidationIssue: Codable, Hashable, Sendable {
    public let code: String
    public let severity: Severity
    public let path: String
    public init(code: String, severity: Severity, path: String) {
        self.code = code; self.severity = severity; self.path = path
    }
}

/// Plain values to validate, as in contracts/vectors/validation.json.
public struct ValidationInput: Codable, Equatable, Sendable {
    public var mesa: [String: String?]
    public var header: [String: Int?]
    public var cells: [String: [String: Int?]]
    public init(mesa: [String: String?], header: [String: Int?], cells: [String: [String: Int?]]) {
        self.mesa = mesa; self.header = header; self.cells = cells
    }
}

public enum Validator {
    public static func validate(_ input: ValidationInput, template: FormTemplate) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []

        for field in template.mesaFields {
            let raw = (input.mesa[field.id] ?? nil) ?? ""
            if raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(.init(code: "missing_mesa", severity: .error, path: "mesa.\(field.id)"))
            }
        }

        var header: [String: Int] = [:]
        for field in template.headerFields {
            let path = "header.\(field.id)"
            guard let value = input.header[field.id] ?? nil else {
                if field.isRequired { issues.append(.init(code: "missing_value", severity: .error, path: path)) }
                continue
            }
            if value < 0 {
                issues.append(.init(code: "negative_value", severity: .error, path: path))
            } else {
                header[field.id] = value
            }
        }

        if let rule = template.rules.votantesMaxElectores,
           let votantes = header["votantes"], let electores = header["electores"], votantes > electores {
            issues.append(.init(code: "votantes_exceed_electores", severity: rule.severity,
                                path: "header.votantes"))
        }

        for category in template.categories {
            var complete = true
            var sum = 0
            for row in template.rows {
                let path = "cells.\(category.id).\(row.id)"
                guard let value = input.cells[category.id]?[row.id] ?? nil else {
                    issues.append(.init(code: "missing_value", severity: .error, path: path))
                    complete = false
                    continue
                }
                if value < 0 {
                    issues.append(.init(code: "negative_value", severity: .error, path: path))
                    complete = false
                } else {
                    sum += value
                }
            }
            // The total is only meaningful when every cell is present and valid.
            if complete, let rule = template.rules.categoryTotalEqualsVotantes,
               let votantes = header["votantes"], sum != votantes {
                issues.append(.init(code: "category_total_mismatch", severity: rule.severity,
                                    path: "cells.\(category.id)"))
            }
        }
        return issues
    }
}
