import Foundation

struct SocialProfile: Codable, Sendable {
    let service: String
    let username: String
    let url: String?

    static func parse(_ input: String) -> SocialProfile {
        let parts = input.split(separator: ":", maxSplits: 1)
        if parts.count == 2 {
            return SocialProfile(
                service: String(parts[0]),
                username: String(parts[1]),
                url: nil
            )
        }
        return SocialProfile(service: "other", username: input, url: nil)
    }
}
