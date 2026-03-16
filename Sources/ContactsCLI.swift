import ArgumentParser

@main
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
