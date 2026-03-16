import Foundation

struct ContactDetail: Codable, Sendable {
    let id: String
    let shortId: String
    let firstName: String?
    let lastName: String?
    let organization: String?
    let jobTitle: String?
    let department: String?
    let note: String?
    let emails: [LabeledValue]
    let phones: [LabeledValue]
    let addresses: [LabeledAddress]
    let urls: [LabeledValue]
    let socialProfiles: [SocialProfile]
    let instantMessaging: [LabeledValue]
    let relatedNames: [LabeledValue]
    let birthday: String?
    let dates: [LabeledValue]
    let namePrefix: String?
    let middleName: String?
    let nameSuffix: String?
    let nickname: String?
    let hasImage: Bool

    init(id: String, firstName: String? = nil, lastName: String? = nil,
         organization: String? = nil, jobTitle: String? = nil, department: String? = nil,
         note: String? = nil, emails: [LabeledValue] = [], phones: [LabeledValue] = [],
         addresses: [LabeledAddress] = [], urls: [LabeledValue] = [],
         socialProfiles: [SocialProfile] = [], instantMessaging: [LabeledValue] = [],
         relatedNames: [LabeledValue] = [], birthday: String? = nil,
         dates: [LabeledValue] = [], namePrefix: String? = nil, middleName: String? = nil,
         nameSuffix: String? = nil, nickname: String? = nil, hasImage: Bool = false) {
        self.id = id
        self.shortId = String(id.prefix(8))
        self.firstName = firstName
        self.lastName = lastName
        self.organization = organization
        self.jobTitle = jobTitle
        self.department = department
        self.note = note
        self.emails = emails
        self.phones = phones
        self.addresses = addresses
        self.urls = urls
        self.socialProfiles = socialProfiles
        self.instantMessaging = instantMessaging
        self.relatedNames = relatedNames
        self.birthday = birthday
        self.dates = dates
        self.namePrefix = namePrefix
        self.middleName = middleName
        self.nameSuffix = nameSuffix
        self.nickname = nickname
        self.hasImage = hasImage
    }
}
