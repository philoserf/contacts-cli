import ArgumentParser
import Foundation

struct GetCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "get",
        abstract: "Get full details for a contact"
    )

    @Argument(help: "Contact ID (short or full)")
    var id: String

    @Flag(name: .long, help: "Output as JSON")
    var json = false

    mutating func run() throws {
        let store = ContactStore()
        let detail = try store.get(id: id)

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(detail)
            print(String(data: data, encoding: .utf8)!)
        } else {
            print(CardFormatter.format(detail))
        }
    }
}
