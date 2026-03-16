import Foundation

enum ContactError: Error, CustomStringConvertible, Sendable {
    case permissionDenied
    case notFound(String)
    case ambiguousId(String, Int)
    case general(String)

    var exitCode: Int32 {
        switch self {
        case .permissionDenied: 2
        case .notFound: 3
        case .ambiguousId: 4
        case .general: 1
        }
    }

    var description: String {
        switch self {
        case .permissionDenied:
            "Permission denied. Grant access in System Settings → Privacy & Security → Contacts."
        case .notFound(let id):
            "Contact not found: \(id)"
        case .ambiguousId(let id, let count):
            "Ambiguous short ID '\(id)' matches \(count) contacts. Use a full ID."
        case .general(let message):
            message
        }
    }
}
