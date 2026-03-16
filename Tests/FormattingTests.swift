import Testing
@testable import contacts_cli

@Suite("Formatting Tests")
struct FormattingTests {
    @Test("Table formats summary with columns")
    func tableOutput() {
        let contacts = [
            ContactSummary(id: "A1B2C3D4-XXXX:ABPerson", fullName: "Kerry Ayers",
                           email: "kerry@example.com", phone: "+16165551234"),
        ]
        let output = TableFormatter.format(contacts)
        #expect(output.contains("A1B2C3D4"))
        #expect(output.contains("Kerry Ayers"))
        #expect(output.contains("kerry@example.com"))
    }

    @Test("Table shows header row")
    func tableHeader() {
        let output = TableFormatter.format([])
        #expect(output.contains("ID"))
        #expect(output.contains("NAME"))
    }

    @Test("Card shows all populated fields")
    func cardOutput() {
        let detail = ContactDetail(
            id: "A1B2C3D4-XXXX:ABPerson",
            firstName: "Kerry",
            lastName: "Ayers",
            organization: "NKC",
            emails: [LabeledValue(label: "home", value: "kerry@example.com")],
            phones: [LabeledValue(label: "mobile", value: "+16165551234")]
        )
        let output = CardFormatter.format(detail)
        #expect(output.contains("Kerry"))
        #expect(output.contains("Ayers"))
        #expect(output.contains("NKC"))
        #expect(output.contains("home: kerry@example.com"))
        #expect(output.contains("mobile: +16165551234"))
    }

    @Test("Card omits empty fields")
    func cardOmitsEmpty() {
        let detail = ContactDetail(
            id: "A1B2C3D4-XXXX:ABPerson",
            firstName: "Test"
        )
        let output = CardFormatter.format(detail)
        #expect(!output.contains("Organization"))
        #expect(!output.contains("Birthday"))
    }
}
