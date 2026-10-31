import Foundation

/// Converts an OCR token to a non-negative integer (contracts/vectors/digits.json).
/// Look-alike letters are only corrected when the token has at least one real digit.
public enum DigitNormalizer {
    static let lookAlikes: [Character: Character] = [
        "O": "0", "o": "0", "l": "1", "I": "1", "|": "1", "S": "5", "B": "8"
    ]

    public static func normalize(_ text: String) -> Int? {
        let token = text.filter { !$0.isWhitespace && $0 != "." && $0 != "," }
        guard !token.isEmpty, token.count <= 9,
              token.contains(where: { $0.isASCII && $0.isNumber }) else { return nil }
        var digits = ""
        for char in token {
            if char.isASCII && char.isNumber {
                digits.append(char)
            } else if let mapped = lookAlikes[char] {
                digits.append(mapped)
            } else {
                return nil
            }
        }
        return Int(digits)
    }
}
