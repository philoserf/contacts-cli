import ArgumentParser
import Darwin
import Foundation

struct DeleteCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a contact"
    )

    @Argument(help: "Contact ID (short or full)")
    var id: String

    @Flag(name: .long, help: "Skip confirmation prompt")
    var force = false

    @Flag(name: .long, help: "Output as JSON")
    var json = false

    mutating func run() throws {
        let store = ContactStore()
        let detail = try store.get(id: id)
        let name = [detail.firstName, detail.lastName].compactMap { $0 }.joined(separator: " ")
        let displayName = name.isEmpty ? detail.id : name

        if !force {
            let isTTY = isatty(STDIN_FILENO) != 0
            guard isTTY else {
                throw ContactError.general("Refusing to delete without --force in non-interactive mode")
            }
            print("Delete \(displayName)? [y/N] ", terminator: "")
            guard let response = readLine()?.lowercased(), response == "y" || response == "yes" else {
                print("Cancelled.")
                return
            }
        }

        try store.delete(id: id)

        if json {
            print("{\"status\":\"deleted\"}")
        } else {
            print("Deleted: \(displayName)")
        }
    }
}
