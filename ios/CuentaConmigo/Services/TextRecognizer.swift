import Foundation
import TelegramaCore
import UIKit
import Vision

/// On-device OCR used only as an assistant: it suggests numbers, never fills fields.
enum TextRecognizer {
    static func numbers(in jpeg: Data) async -> [Int] {
        await Task.detached(priority: .userInitiated) {
            guard let image = UIImage(data: jpeg)?.cgImage else { return [] }
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            request.recognitionLanguages = ["es-ES"]
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            guard (try? handler.perform([request])) != nil else { return [] }
            let strings = (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }
            return strings
                .flatMap { $0.split(whereSeparator: { $0.isWhitespace }) }
                .compactMap { DigitNormalizer.normalize(String($0)) }
        }.value
    }
}
