import Foundation

/// Public polling-place list for the cascading table pickers (F-16).
/// Bundled from data/establecimientos/nomina-2025.json by ios/scripts/sync-contracts.sh.
struct PollingPlaces: Decodable {
    struct District: Decodable, Identifiable {
        let id: String
        let nombre: String
        let secciones: [Section]
    }

    struct Section: Decodable, Identifiable {
        let id: String
        let nombre: String
        let locales: [Place]
    }

    struct Place: Decodable, Identifiable {
        let codigo: String
        let nombre: String
        let direccion: String
        let localidad: String
        let mesas: [TableRange]
        var id: String { codigo }

        /// Expanded table numbers with their circuit, in order.
        var tables: [Table] {
            mesas.flatMap { range in
                (range.first...range.last).map { number in Table(mesa: number, circuito: range.circuito) }
            }
        }
    }

    struct Table: Hashable {
        let mesa: Int
        let circuito: String
    }

    /// Encoded as `[first, last, circuito]`.
    struct TableRange: Decodable {
        let first: Int
        let last: Int
        let circuito: String

        init(from decoder: Decoder) throws {
            var c = try decoder.unkeyedContainer()
            first = try c.decode(Int.self)
            last = try c.decode(Int.self)
            circuito = try c.decode(String.self)
        }
    }

    let distritos: [District]

    /// Nil when the list is not bundled; the editor then falls back to typing.
    static let shared: PollingPlaces? = {
        guard let url = Bundle.main.url(forResource: "nomina-2025", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(PollingPlaces.self, from: data)
    }()
}
