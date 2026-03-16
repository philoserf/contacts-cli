@preconcurrency import Contacts
import Foundation

final class ContactStore {
    private let store = CNContactStore()

    private static let summaryKeys: [CNKeyDescriptor] = [
        CNContactIdentifierKey as CNKeyDescriptor,
        CNContactGivenNameKey as CNKeyDescriptor,
        CNContactFamilyNameKey as CNKeyDescriptor,
        CNContactEmailAddressesKey as CNKeyDescriptor,
        CNContactPhoneNumbersKey as CNKeyDescriptor,
        CNContactOrganizationNameKey as CNKeyDescriptor,
        CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
    ]

    private static let detailKeys: [CNKeyDescriptor] = summaryKeys + [
        CNContactJobTitleKey as CNKeyDescriptor,
        CNContactDepartmentNameKey as CNKeyDescriptor,
        CNContactNoteKey as CNKeyDescriptor,
        CNContactPostalAddressesKey as CNKeyDescriptor,
        CNContactUrlAddressesKey as CNKeyDescriptor,
        CNContactSocialProfilesKey as CNKeyDescriptor,
        CNContactInstantMessageAddressesKey as CNKeyDescriptor,
        CNContactRelationsKey as CNKeyDescriptor,
        CNContactBirthdayKey as CNKeyDescriptor,
        CNContactDatesKey as CNKeyDescriptor,
        CNContactNamePrefixKey as CNKeyDescriptor,
        CNContactMiddleNameKey as CNKeyDescriptor,
        CNContactNameSuffixKey as CNKeyDescriptor,
        CNContactNicknameKey as CNKeyDescriptor,
        CNContactImageDataAvailableKey as CNKeyDescriptor,
        CNContactTypeKey as CNKeyDescriptor,
    ]

    func checkAccess() throws {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .authorized: return
        case .notDetermined:
            let semaphore = DispatchSemaphore(value: 0)
            // nonisolated(unsafe) is correct here: semaphore.wait() ensures the closure
            // has completed before accessGranted is read, so the mutation is safe.
            nonisolated(unsafe) var accessGranted = false
            store.requestAccess(for: .contacts) { granted, _ in
                accessGranted = granted
                semaphore.signal()
            }
            semaphore.wait()
            if !accessGranted { throw ContactError.permissionDenied }
        default:
            throw ContactError.permissionDenied
        }
    }

    func fetchAll() throws -> [ContactSummary] {
        try checkAccess()
        let request = CNContactFetchRequest(keysToFetch: Self.summaryKeys)
        request.sortOrder = .familyName
        var results: [ContactSummary] = []
        try store.enumerateContacts(with: request) { contact, _ in
            results.append(self.toSummary(contact))
        }
        return results
    }

    func search(query: String) throws -> [ContactSummary] {
        try checkAccess()
        var contacts: [CNContact] = []

        let namePredicate = CNContact.predicateForContacts(matchingName: query)
        contacts += try store.unifiedContacts(matching: namePredicate, keysToFetch: Self.summaryKeys)

        let emailPredicate = CNContact.predicateForContacts(matchingEmailAddress: query)
        contacts += try store.unifiedContacts(matching: emailPredicate, keysToFetch: Self.summaryKeys)

        let phoneNumber = CNPhoneNumber(stringValue: query)
        let phonePredicate = CNContact.predicateForContacts(matching: phoneNumber)
        contacts += try store.unifiedContacts(matching: phonePredicate, keysToFetch: Self.summaryKeys)

        var seen = Set<String>()
        return contacts.compactMap { contact in
            guard seen.insert(contact.identifier).inserted else { return nil }
            return toSummary(contact)
        }
    }

    func get(id: String) throws -> ContactDetail {
        try checkAccess()
        let contact = try resolveContact(id: id, keys: Self.detailKeys)
        return toDetail(contact)
    }

    func create(_ fields: ContactFields) throws -> String {
        try checkAccess()
        let contact = CNMutableContact()
        applyFields(fields, to: contact)
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)
        try store.execute(saveRequest)
        return contact.identifier
    }

    func update(id: String, _ fields: ContactFields) throws {
        try checkAccess()
        let contact = try resolveContact(id: id, keys: Self.detailKeys)
        // swiftlint:disable:next force_cast
        let mutable = contact.mutableCopy() as! CNMutableContact
        applyFields(fields, to: mutable)
        let saveRequest = CNSaveRequest()
        saveRequest.update(mutable)
        try store.execute(saveRequest)
    }

    func delete(id: String) throws {
        try checkAccess()
        let contact = try resolveContact(id: id, keys: Self.summaryKeys)
        // swiftlint:disable:next force_cast
        let mutable = contact.mutableCopy() as! CNMutableContact
        let saveRequest = CNSaveRequest()
        saveRequest.delete(mutable)
        try store.execute(saveRequest)
    }

    // MARK: - Private

    private func resolveContact(id: String, keys: [CNKeyDescriptor]) throws -> CNContact {
        if id.contains("-") || id.count > 20 {
            let predicate = CNContact.predicateForContacts(withIdentifiers: [id])
            let results = try store.unifiedContacts(matching: predicate, keysToFetch: keys)
            guard let contact = results.first else {
                throw ContactError.notFound(id)
            }
            return contact
        }

        let request = CNContactFetchRequest(keysToFetch: keys)
        var matches: [CNContact] = []
        try store.enumerateContacts(with: request) { contact, _ in
            if contact.identifier.hasPrefix(id) {
                matches.append(contact)
            }
        }

        switch matches.count {
        case 0: throw ContactError.notFound(id)
        case 1: return matches[0]
        default: throw ContactError.ambiguousId(id, matches.count)
        }
    }

    private func toSummary(_ contact: CNContact) -> ContactSummary {
        let fullName = CNContactFormatter.string(from: contact, style: .fullName)
            ?? (contact.organizationName.isEmpty ? nil : contact.organizationName)
            ?? (contact.emailAddresses.first?.value as String?)
            ?? "No Name"
        return ContactSummary(
            id: contact.identifier,
            fullName: fullName,
            email: contact.emailAddresses.first?.value as String?,
            phone: contact.phoneNumbers.first?.value.stringValue
        )
    }

    // swiftlint:disable function_body_length
    private func toDetail(_ contact: CNContact) -> ContactDetail {
        let birthday: String? = contact.birthday.flatMap { components in
            if let date = Calendar.current.date(from: components) {
                return ISO8601DateFormatter().string(from: date)
            }
            if let month = components.month, let day = components.day {
                return String(format: "--%02d-%02d", month, day)
            }
            return nil
        }

        return ContactDetail(
            id: contact.identifier,
            firstName: contact.givenName.isEmpty ? nil : contact.givenName,
            lastName: contact.familyName.isEmpty ? nil : contact.familyName,
            organization: contact.organizationName.isEmpty ? nil : contact.organizationName,
            jobTitle: contact.jobTitle.isEmpty ? nil : contact.jobTitle,
            department: contact.departmentName.isEmpty ? nil : contact.departmentName,
            note: contact.note.isEmpty ? nil : contact.note,
            emails: contact.emailAddresses.map {
                LabeledValue(
                    label: CNLabeledValue<NSString>.localizedString(forLabel: $0.label ?? ""),
                    value: $0.value as String
                )
            },
            phones: contact.phoneNumbers.map {
                LabeledValue(
                    label: CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: $0.label ?? ""),
                    value: $0.value.stringValue
                )
            },
            addresses: contact.postalAddresses.map { labeled in
                let addr = labeled.value
                return LabeledAddress(
                    label: CNLabeledValue<CNPostalAddress>.localizedString(forLabel: labeled.label ?? ""),
                    street: addr.street.isEmpty ? nil : addr.street,
                    city: addr.city.isEmpty ? nil : addr.city,
                    state: addr.state.isEmpty ? nil : addr.state,
                    postalCode: addr.postalCode.isEmpty ? nil : addr.postalCode,
                    country: addr.country.isEmpty ? nil : addr.country
                )
            },
            urls: contact.urlAddresses.map {
                LabeledValue(
                    label: CNLabeledValue<NSString>.localizedString(forLabel: $0.label ?? ""),
                    value: $0.value as String
                )
            },
            socialProfiles: contact.socialProfiles.map {
                SocialProfile(
                    service: $0.value.service,
                    username: $0.value.username,
                    url: $0.value.urlString.isEmpty ? nil : $0.value.urlString
                )
            },
            instantMessaging: contact.instantMessageAddresses.map {
                LabeledValue(label: $0.value.service, value: $0.value.username)
            },
            relatedNames: contact.contactRelations.map {
                LabeledValue(
                    label: CNLabeledValue<CNContactRelation>.localizedString(forLabel: $0.label ?? ""),
                    value: $0.value.name
                )
            },
            birthday: birthday,
            dates: contact.dates.map {
                let components = $0.value as DateComponents
                let dateStr: String
                if let date = Calendar.current.date(from: components) {
                    dateStr = ISO8601DateFormatter().string(from: date)
                } else if let month = components.month, let day = components.day {
                    dateStr = String(format: "--%02d-%02d", month, day)
                } else {
                    dateStr = "unknown"
                }
                return LabeledValue(
                    label: CNLabeledValue<NSDateComponents>.localizedString(forLabel: $0.label ?? ""),
                    value: dateStr
                )
            },
            namePrefix: contact.namePrefix.isEmpty ? nil : contact.namePrefix,
            middleName: contact.middleName.isEmpty ? nil : contact.middleName,
            nameSuffix: contact.nameSuffix.isEmpty ? nil : contact.nameSuffix,
            nickname: contact.nickname.isEmpty ? nil : contact.nickname,
            hasImage: contact.imageDataAvailable
        )
    }

    // swiftlint:enable function_body_length

    private func applyFields(_ fields: ContactFields, to contact: CNMutableContact) {
        if let v = fields.firstName { contact.givenName = v }
        if let v = fields.lastName { contact.familyName = v }
        if let v = fields.organization { contact.organizationName = v }
        if let v = fields.jobTitle { contact.jobTitle = v }
        if let v = fields.department { contact.departmentName = v }
        if let v = fields.note { contact.note = v }
        if let v = fields.namePrefix { contact.namePrefix = v }
        if let v = fields.middleName { contact.middleName = v }
        if let v = fields.nameSuffix { contact.nameSuffix = v }
        if let v = fields.nickname { contact.nickname = v }

        if let v = fields.birthday {
            if v.isEmpty {
                contact.birthday = nil
            } else if let date = ISO8601DateFormatter().date(from: v) {
                contact.birthday = Calendar.current.dateComponents([.year, .month, .day], from: date)
            }
        }

        if let emails = fields.emails {
            contact.emailAddresses = emails.map {
                CNLabeledValue(label: $0.label, value: $0.value as NSString)
            }
        }

        if let phones = fields.phones {
            contact.phoneNumbers = phones.map {
                CNLabeledValue(label: $0.label, value: CNPhoneNumber(stringValue: $0.value))
            }
        }

        if let addresses = fields.addresses {
            contact.postalAddresses = addresses.map { addr in
                let postal = CNMutablePostalAddress()
                if let v = addr.street { postal.street = v }
                if let v = addr.city { postal.city = v }
                if let v = addr.state { postal.state = v }
                if let v = addr.postalCode { postal.postalCode = v }
                if let v = addr.country { postal.country = v }
                return CNLabeledValue(label: addr.label, value: postal)
            }
        }

        if let urls = fields.urls {
            contact.urlAddresses = urls.map {
                CNLabeledValue(label: $0.label, value: $0.value as NSString)
            }
        }

        if let profiles = fields.socialProfiles {
            contact.socialProfiles = profiles.map {
                let profile = CNSocialProfile(
                    urlString: nil,
                    username: $0.username,
                    userIdentifier: nil,
                    service: $0.service
                )
                return CNLabeledValue(label: nil, value: profile)
            }
        }
    }
}
