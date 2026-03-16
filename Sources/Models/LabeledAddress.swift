import Foundation

struct LabeledAddress: Codable, Sendable {
    let label: String?
    let street: String?
    let city: String?
    let state: String?
    let postalCode: String?
    let country: String?

    static func parse(_ input: String) -> LabeledAddress {
        var label: String?
        var addressPart = input

        if let colonIndex = input.firstIndex(of: ":") {
            let candidateLabel = String(input[input.startIndex..<colonIndex])
            if candidateLabel.count <= 20, !candidateLabel.contains(";") {
                label = candidateLabel
                addressPart = String(input[input.index(after: colonIndex)...])
            }
        }

        let parts = addressPart.split(separator: ";", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .map { $0.isEmpty ? nil : $0 }

        return LabeledAddress(
            label: label,
            street: parts.isEmpty ? nil : parts[0],
            city: parts.count > 1 ? parts[1] : nil,
            state: parts.count > 2 ? parts[2] : nil,
            postalCode: parts.count > 3 ? parts[3] : nil,
            country: parts.count > 4 ? parts[4] : nil
        )
    }
}
