import ArgumentParser
import Foundation

struct ContactsCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "contacts-cli",
        abstract: "Manage Apple Contacts from the command line",
        version: "0.1.0",
        subcommands: [
            ListCommand.self,
            SearchCommand.self,
            GetCommand.self,
            CreateCommand.self,
            UpdateCommand.self,
            DeleteCommand.self,
        ]
    )
}

@main
enum CLI {
    static func main() {
        do {
            var command = try ContactsCLI.parseAsRoot()
            try command.run()
        } catch let error as ContactError {
            fputs("Error: \(error.description)\n", stderr)
            exit(error.exitCode)
        } catch {
            ContactsCLI.exit(withError: error)
        }
    }
}
