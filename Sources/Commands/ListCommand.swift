import ArgumentParser
import Foundation

struct ListCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all contacts"
    )

    @Flag(name: .long, help: "Output as JSON")
    var json = false

    mutating func run() throws {
        let store = ContactStore()
        let contacts = try store.fetchAll()

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
