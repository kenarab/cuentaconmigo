import CryptoKit
import Foundation

public enum EvidenceHash {
    /// Lowercase hex SHA-256 of the exact stored bytes.
    public static func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
