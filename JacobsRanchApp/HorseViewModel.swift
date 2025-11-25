//
//  HorsesViewModel.swift
//  JacobsRanchApp
//

import Foundation
import Supabase

@MainActor
final class HorsesViewModel: ObservableObject {
    @Published var horses: [Horse] = []
    @Published var finishedLoading = false

    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    
    // LOAD ALL HORSES FOR USER
    func loadHorses(userId: String) async {
        do {
            let response = try await client
                .from("horses")
                .select()
                .eq("user_id", value: userId)
                .order("id", ascending: true)
                .execute()

            let data = try JSONDecoder().decode([Horse].self, from: response.data)
            self.horses = data
        } catch {
            print("ERROR loading horses:", error)
        }

        finishedLoading = true
    }

    // ADD EMPTY HORSE
    func addHorse(userId: String) async {
        let newHorse = Horse(userId: userId)

        let payload: [String: AnyEncodable] = [
            "user_id": AnyEncodable(value: userId),
            "name": AnyEncodable(value: ""),
            "owners": AnyEncodable(value: ""),
            "owner_contact": AnyEncodable(value: ""),
            "emergency_contact": AnyEncodable(value: ""),
            "vet_contact": AnyEncodable(value: ""),
            "stall_number": AnyEncodable(value: nil as Int?)
        ]

        do {
            let response = try await client
                .from("horses")
                .insert(payload)
                .select()
                .single()
                .execute()

            let created = try JSONDecoder().decode(Horse.self, from: response.data)
            horses.append(created)

        } catch {
            print("ERROR creating horse:", error)
        }
    }

    // UPDATE HORSE FIELD
    func saveHorse(_ horse: Horse) async {
        guard let id = horse.id else { return }

        let payload: [String: AnyEncodable] = [
            "name": AnyEncodable(value: horse.name),
            "owners": AnyEncodable(value: horse.owners),
            "owner_contact": AnyEncodable(value: horse.ownerContact),
            "emergency_contact": AnyEncodable(value: horse.emergencyContact),
            "vet_contact": AnyEncodable(value: horse.vetContact),
            "stall_number": AnyEncodable(value: horse.stallNumber)
        ]

        do {
            _ = try await client
                .from("horses")
                .update(payload)
                .eq("id", value: id)
                .execute()

        } catch {
            print("ERROR updating horse:", error)
        }
    }

    // DELETE HORSE
    func deleteHorse(id: Int) async {
        do {
            _ = try await client
                .from("horses")
                .delete()
                .eq("id", value: id)
                .execute()

            horses.removeAll { $0.id == id }

        } catch {
            print("ERROR deleting horse:", error)
        }
    }
}
