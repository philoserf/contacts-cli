import Foundation
import Testing
@testable import contacts_cli

@Suite("Model Tests")
struct ModelTests {
    @Test("Short ID extracts first 8 characters")
    func shortId() {
        let summary = ContactSummary(
            id: "A1B2C3D4-5678-9ABC-DEF0-123456789ABC:ABPerson",
            fullName: "Test User",
            email: nil,
            phone: nil
        )
        #expect(summary.shortId == "A1B2C3D4")
    }

    @Test("LabeledValue parses label:value format")
    func labeledValueParsing() {
        let parsed = LabeledValue.parse("work:test@example.com")
        #expect(parsed.label == "work")
        #expect(parsed.value == "test@example.com")
    }

    @Test("LabeledValue parses value without label")
    func labeledValueNoLabel() {
        let parsed = LabeledValue.parse("test@example.com")
        #expect(parsed.label == nil)
        #expect(parsed.value == "test@example.com")
    }

    @Test("LabeledValue treats URL as value, not label:value")
    func labeledValueUrl() {
        let parsed = LabeledValue.parse("https://example.com")
        #expect(parsed.label == nil)
        #expect(parsed.value == "https://example.com")
    }

    @Test("LabeledAddress parses compound format")
    func addressParsing() {
        let parsed = LabeledAddress.parse("home:123 Main;Grand Rapids;MI;49503;US")
        #expect(parsed.label == "home")
        #expect(parsed.street == "123 Main")
        #expect(parsed.city == "Grand Rapids")
        #expect(parsed.state == "MI")
        #expect(parsed.postalCode == "49503")
        #expect(parsed.country == "US")
    }

    @Test("LabeledAddress handles empty fields")
    func addressEmptyFields() {
        let parsed = LabeledAddress.parse("home:123 Main;;MI;;US")
        #expect(parsed.street == "123 Main")
        #expect(parsed.city == nil)
        #expect(parsed.state == "MI")
        #expect(parsed.postalCode == nil)
        #expect(parsed.country == "US")
    }

    @Test("SocialProfile parses service:username")
    func socialProfileParsing() {
        let parsed = SocialProfile.parse("linkedin:markayers")
        #expect(parsed.service == "linkedin")
        #expect(parsed.username == "markayers")
    }

    @Test("ContactSummary encodes to JSON")
    func summaryJson() throws {
        let summary = ContactSummary(
            id: "A1B2C3D4-5678-9ABC-DEF0-123456789ABC:ABPerson",
            fullName: "Test User",
            email: "test@example.com",
            phone: nil
        )
        let data = try JSONEncoder().encode(summary)
        let json = String(data: data, encoding: .utf8)!
        #expect(json.contains("\"shortId\":\"A1B2C3D4\""))
    }

    @Test("ContactError has correct exit codes")
    func exitCodes() {
        #expect(ContactError.permissionDenied.exitCode == 2)
        #expect(ContactError.notFound("x").exitCode == 3)
        #expect(ContactError.ambiguousId("x", 2).exitCode == 4)
    }
}
