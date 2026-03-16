import ArgumentParser
import Foundation

struct UpdateCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update an existing contact"
    )

    @Argument(help: "Contact ID (short or full)")
    var id: String

    @Option(name: .long, help: "First name")
    var first: String?

    @Option(name: .long, help: "Last name")
    var last: String?

    @Option(name: .long, help: "Email — replaces all (format: [label:]address, repeatable)")
    var email: [String] = []

    @Option(name: .long, help: "Phone — replaces all (format: [label:]number, repeatable)")
    var phone: [String] = []

    @Option(name: .long, help: "Organization")
    var org: String?

    @Option(name: .long, help: "Job title")
    var title: String?

    @Option(name: .long, help: "Note (empty string clears)")
    var note: String?

    @Option(name: .long, help: ArgumentParser.ArgumentHelp("Birthday (ISO 8601, empty clears)", visibility: .hidden))
    var birthday: String?

    @Option(name: .long, help: ArgumentParser.ArgumentHelp("Department", visibility: .hidden))
    var department: String?

    @Option(name: .long, help: ArgumentParser.ArgumentHelp("Address — replaces all", visibility: .hidden))
    var address: [String] = []

    @Option(name: .long, help: ArgumentParser.ArgumentHelp("URL — replaces all", visibility: .hidden))
    var url: [String] = []

    @Option(name: .long, help: ArgumentParser.ArgumentHelp("Social profile — replaces all", visibility: .hidden))
    var social: [String] = []

    @Option(name: .long, help: ArgumentParser.ArgumentHelp("Name prefix", visibility: .hidden))
    var namePrefix: String?

    @Option(name: .long, help: ArgumentParser.ArgumentHelp("Middle name", visibility: .hidden))
    var middleName: String?

    @Option(name: .long, help: ArgumentParser.ArgumentHelp("Name suffix", visibility: .hidden))
    var nameSuffix: String?

    @Option(name: .long, help: ArgumentParser.ArgumentHelp("Nickname", visibility: .hidden))
    var nickname: String?

    @Flag(name: .long, help: "Output as JSON")
    var json = false

    mutating func run() throws {
        let fields = ContactFields(
            firstName: first,
            lastName: last,
            emails: email.isEmpty ? nil : email.map { parsed in
                let lv = LabeledValue.parse(parsed)
                return ContactFields.LabeledEntry(label: lv.label, value: lv.value)
            },
            phones: phone.isEmpty ? nil : phone.map { parsed in
                let lv = LabeledValue.parse(parsed)
                return ContactFields.LabeledEntry(label: lv.label, value: lv.value)
            },
            organization: org,
            jobTitle: title,
            department: department,
            note: note,
            birthday: birthday,
            addresses: address.isEmpty ? nil : address.map { input in
                let parsed = LabeledAddress.parse(input)
                return ContactFields.AddressEntry(
                    label: parsed.label, street: parsed.street, city: parsed.city,
                    state: parsed.state, postalCode: parsed.postalCode, country: parsed.country
                )
            },
            urls: url.isEmpty ? nil : url.map { parsed in
                let lv = LabeledValue.parse(parsed)
                return ContactFields.LabeledEntry(label: lv.label, value: lv.value)
            },
            socialProfiles: social.isEmpty ? nil : social.map { parsed in
                let sp = SocialProfile.parse(parsed)
                return ContactFields.SocialEntry(service: sp.service, username: sp.username)
            },
            namePrefix: namePrefix,
            middleName: middleName,
            nameSuffix: nameSuffix,
            nickname: nickname
        )

        let store = ContactStore()
        try store.update(id: id, fields)

        if json {
            print("{\"status\":\"updated\"}")
        } else {
            print("Updated: \(String(id.prefix(8)))")
        }
    }
}
