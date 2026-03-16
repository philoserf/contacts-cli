import ArgumentParser
import Foundation

struct SearchCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "search",
        abstract: "Search contacts by name, email, or phone"
    )

    @Argument(help: "Search query")
    var query: String

    @Flag(name: .long, help: "Output as JSON")
    var json = false

    mutating func run() throws {
        let store = ContactStore()
        let contacts = try store.search(query: query)

        if json {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(contacts)
            print(String(data: data, encoding: .utf8)!)
        } else {
            print(TableFormatter.format(contacts))
        }
    }
}
