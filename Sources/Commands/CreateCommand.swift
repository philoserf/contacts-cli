import ArgumentParser
import Foundation

struct CreateCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new contact"
    )

    @Option(name: .long, help: "First name")
    var first: String?

    @Option(name: .long, help: "Last name")
    var last: String?

    @Option(name: .long, help: "Email (format: [label:]address, repeatable)")
    var email: [String] = []

    @Option(name: .long, help: "Phone (format: [label:]number, repeatable)")
    var phone: [String] = []

    @Option(name: .long, help: "Organization")
    var org: String?

    @Option(name: .long, help: "Job title")
    var title: String?

    @Option(name: .long, help: "Note")
    var note: String?

    @Option(name: .long, help: ArgumentParser.ArgumentHelp("Birthday (ISO 8601)", visibility: .hidden))
    var birthday: String?

    @Option(name: .long, help: ArgumentParser.ArgumentHelp("Department", visibility: .hidden))
    var department: String?

    @Option(name: .long, help: ArgumentParser.ArgumentHelp("Address (format: [label:]street;city;state;zip;country)", visibility: .hidden))
    var address: [String] = []

    @Option(name: .long, help: ArgumentParser.ArgumentHelp("URL (format: [label:]url, repeatable)", visibility: .hidden))
    var url: [String] = []

    @Option(name: .long, help: ArgumentParser.ArgumentHelp("Social profile (format: service:username)", visibility: .hidden))
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

    func validate() throws {
        guard first != nil || last != nil else {
            throw ValidationError("At least --first or --last is required")
        }
    }

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
        let newId = try store.create(fields)

        if json {
            let result = ["id": newId, "shortId": String(newId.prefix(8))]
            let data = try JSONEncoder().encode(result)
            print(String(data: data, encoding: .utf8)!)
        } else {
            print("Created: \(String(newId.prefix(8)))")
        }
    }
}
