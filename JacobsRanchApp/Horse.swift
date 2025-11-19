//
//  Horse.swift
//  JacobsRanchApp
//

import Foundation
import SwiftUI

class Horse: ObservableObject, Identifiable, Codable, Equatable {
    let id: UUID
    @Published var name: String
    @Published var owners: String
    @Published var ownerContact: String
    @Published var emergencyContact: String
    @Published var vetContact: String

    // Equatable conformance
    static func == (lhs: Horse, rhs: Horse) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.owners == rhs.owners &&
               lhs.ownerContact == rhs.ownerContact &&
               lhs.emergencyContact == rhs.emergencyContact &&
               lhs.vetContact == rhs.vetContact
    }

    enum CodingKeys: CodingKey {
        case id, name, owners, ownerContact, emergencyContact, vetContact
    }

    init(id: UUID = UUID(), name: String = "", owners: String = "", ownerContact: String = "", emergencyContact: String = "", vetContact: String = "") {
        self.id = id
        self.name = name
        self.owners = owners
        self.ownerContact = ownerContact
        self.emergencyContact = emergencyContact
        self.vetContact = vetContact
    }

    // Decode manually for @Published properties
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        owners = try container.decode(String.self, forKey: .owners)
        ownerContact = try container.decode(String.self, forKey: .ownerContact)
        emergencyContact = try container.decode(String.self, forKey: .emergencyContact)
        vetContact = try container.decode(String.self, forKey: .vetContact)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(owners, forKey: .owners)
        try container.encode(ownerContact, forKey: .ownerContact)
        try container.encode(emergencyContact, forKey: .emergencyContact)
        try container.encode(vetContact, forKey: .vetContact)
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "name": name,
            "owners": owners,
            "ownerContact": ownerContact,
            "emergencyContact": emergencyContact,
            "vetContact": vetContact
        ]
    }

    static func fromDictionary(_ dict: [String: Any]) -> Horse {
        return Horse(
            id: UUID(uuidString: dict["id"] as? String ?? "") ?? UUID(),
            name: dict["name"] as? String ?? "",
            owners: dict["owners"] as? String ?? "",
            ownerContact: dict["ownerContact"] as? String ?? "",
            emergencyContact: dict["emergencyContact"] as? String ?? "",
            vetContact: dict["vetContact"] as? String ?? ""
        )
    }
}
