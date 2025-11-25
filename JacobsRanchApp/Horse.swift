//
//  Horse.swift
//  JacobsRanchApp
//

import Foundation

final class Horse: ObservableObject, Identifiable, Codable {
    let id: Int?                  // Supabase row ID (Int)
    @Published var userId: String // uuid
    @Published var name: String
    @Published var owners: String
    @Published var ownerContact: String
    @Published var emergencyContact: String
    @Published var vetContact: String
    @Published var stallNumber: Int?   // nullable

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case owners
        case ownerContact = "owner_contact"
        case emergencyContact = "emergency_contact"
        case vetContact = "vet_contact"
        case stallNumber = "stall_number"
    }

    init(
        id: Int? = nil,
        userId: String,
        name: String = "",
        owners: String = "",
        ownerContact: String = "",
        emergencyContact: String = "",
        vetContact: String = "",
        stallNumber: Int? = nil
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.owners = owners
        self.ownerContact = ownerContact
        self.emergencyContact = emergencyContact
        self.vetContact = vetContact
        self.stallNumber = stallNumber
    }

    // Manual decode for @Published
    required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id = try? c.decode(Int.self, forKey: .id)
        userId = try c.decode(String.self, forKey: .userId)
        name = try c.decode(String.self, forKey: .name)
        owners = try c.decode(String.self, forKey: .owners)
        ownerContact = try c.decode(String.self, forKey: .ownerContact)
        emergencyContact = try c.decode(String.self, forKey: .emergencyContact)
        vetContact = try c.decode(String.self, forKey: .vetContact)
        stallNumber = try? c.decode(Int.self, forKey: .stallNumber)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try? c.encode(id, forKey: .id)
        try c.encode(userId, forKey: .userId)
        try c.encode(name, forKey: .name)
        try c.encode(owners, forKey: .owners)
        try c.encode(ownerContact, forKey: .ownerContact)
        try c.encode(emergencyContact, forKey: .emergencyContact)
        try c.encode(vetContact, forKey: .vetContact)
        try? c.encode(stallNumber, forKey: .stallNumber)
    }
}
