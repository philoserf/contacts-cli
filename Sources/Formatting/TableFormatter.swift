import Foundation

enum TableFormatter {
    static func format(_ contacts: [ContactSummary]) -> String {
        let header = [
            "ID".padding(toLength: 10, withPad: " ", startingAt: 0),
            "NAME".padding(toLength: 25, withPad: " ", startingAt: 0),
            "EMAIL".padding(toLength: 30, withPad: " ", startingAt: 0),
            "PHONE",
        ].joined()
        let divider = String(repeating: "-", count: 80)
        var lines = [header, divider]

        for contact in contacts {
            let line = [
                contact.shortId.padding(toLength: 10, withPad: " ", startingAt: 0),
                String(contact.fullName.prefix(24)).padding(toLength: 25, withPad: " ", startingAt: 0),
                String((contact.email ?? "").prefix(29)).padding(toLength: 30, withPad: " ", startingAt: 0),
                contact.phone ?? "",
            ].joined()
            lines.append(line.trimmingCharacters(in: .whitespaces))
        }
        return lines.joined(separator: "\n")
    }
}
