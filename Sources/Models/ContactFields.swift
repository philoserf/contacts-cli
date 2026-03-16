import Foundation

struct ContactFields {
    struct AddressEntry {
        var label: String?
        var street: String?
        var city: String?
        var state: String?
        var postalCode: String?
        var country: String?
    }

    struct LabeledEntry {
        var label: String?
        var value: String
    }

    struct SocialEntry {
        var service: String
        var username: String
    }

    var firstName: String?
    var lastName: String?
    var emails: [LabeledEntry]?
    var phones: [LabeledEntry]?
    var organization: String?
    var jobTitle: String?
    var department: String?
    var note: String?
    var birthday: String?
    var addresses: [AddressEntry]?
    var urls: [LabeledEntry]?
    var socialProfiles: [SocialEntry]?
    var namePrefix: String?
    var middleName: String?
    var nameSuffix: String?
    var nickname: String?
}
