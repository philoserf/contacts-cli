import Foundation

enum CardFormatter {
    static func format(_ contact: ContactDetail) -> String {
        var lines: [String] = []

        lines.append("ID: \(contact.shortId) (\(contact.id))")
        lines.append("")

        addIfPresent(&lines, "Prefix", contact.namePrefix)
        addIfPresent(&lines, "First Name", contact.firstName)
        addIfPresent(&lines, "Middle Name", contact.middleName)
        addIfPresent(&lines, "Last Name", contact.lastName)
        addIfPresent(&lines, "Suffix", contact.nameSuffix)
        addIfPresent(&lines, "Nickname", contact.nickname)
        addIfPresent(&lines, "Organization", contact.organization)
        addIfPresent(&lines, "Job Title", contact.jobTitle)
        addIfPresent(&lines, "Department", contact.department)

        addLabeledValues(&lines, "Email", contact.emails)
        addLabeledValues(&lines, "Phone", contact.phones)
        addAddresses(&lines, contact.addresses)
        addLabeledValues(&lines, "URL", contact.urls)
        addSocialProfiles(&lines, contact.socialProfiles)
        addLabeledValues(&lines, "IM", contact.instantMessaging)
        addLabeledValues(&lines, "Related", contact.relatedNames)

        addIfPresent(&lines, "Birthday", contact.birthday)
        addLabeledValues(&lines, "Date", contact.dates)
        addIfPresent(&lines, "Note", contact.note)

        if contact.hasImage {
            lines.append("Photo: yes")
        }

        return lines.joined(separator: "\n")
    }

    private static func addIfPresent(_ lines: inout [String], _ label: String, _ value: String?) {
        guard let value, !value.isEmpty else { return }
        lines.append("\(label): \(value)")
    }

    private static func addLabeledValues(_ lines: inout [String], _ label: String, _ values: [LabeledValue]) {
        for value in values {
            if let valueLabel = value.label {
                lines.append("\(label): \(valueLabel): \(value.value)")
            } else {
                lines.append("\(label): \(value.value)")
            }
        }
    }

    private static func addAddresses(_ lines: inout [String], _ addresses: [LabeledAddress]) {
        for addr in addresses {
            let parts = [addr.street, addr.city, addr.state, addr.postalCode, addr.country]
                .compactMap { $0 }
            let prefix = addr.label.map { "Address (\($0)): " } ?? "Address: "
            lines.append(prefix + parts.joined(separator: ", "))
        }
    }

    private static func addSocialProfiles(_ lines: inout [String], _ profiles: [SocialProfile]) {
        for profile in profiles {
            lines.append("Social: \(profile.service): \(profile.username)")
        }
    }
}
