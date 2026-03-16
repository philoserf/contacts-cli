import Foundation

struct ContactSummary: Codable, Sendable {
    let id: String
    let shortId: String
    let fullName: String
    let email: String?
    let phone: String?

    init(id: String, fullName: String, email: String?, phone: String?) {
        self.id = id
        self.shortId = String(id.prefix(8))
        self.fullName = fullName
        self.email = email
        self.phone = phone
    }
}
