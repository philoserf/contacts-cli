import Foundation

struct LabeledValue: Codable, Sendable {
    let label: String?
    let value: String

    static func parse(_ input: String) -> LabeledValue {
        if let colonIndex = input.firstIndex(of: ":") {
            let label = String(input[input.startIndex..<colonIndex])
            let value = String(input[input.index(after: colonIndex)...])
            if label.count <= 20, !label.contains("@"), !label.contains(" "),
               !label.contains("/"), !value.hasPrefix("//") {
                return LabeledValue(label: label, value: value)
            }
        }
        return LabeledValue(label: nil, value: input)
    }
}
