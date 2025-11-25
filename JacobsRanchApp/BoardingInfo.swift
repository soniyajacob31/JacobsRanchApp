//
//  BoardingInfo.swift
//  JacobsRanchApp
//

import Foundation
import SwiftUI
import Supabase

final class BoardingInfo: ObservableObject {

    @Published var userId: String = ""
    @Published var email: String = ""

    @Published var horseCount: Int = 1
    @Published var usesTrailer: Bool = false
    @Published var usesWifi: Bool = false
    @Published var wifiSubscribers: Int = 1

    @Published var availableStalls: Int = 14

    let stallRate = 250
    let trailerRate = 50
    let wifiRate = 50

    var rentFee: Int { horseCount * stallRate }
    var trailerFee: Int { usesTrailer ? trailerRate : 0 }

    var wifiShare: Double {
        guard usesWifi, wifiSubscribers > 0 else { return 0 }
        return Double(wifiRate) / Double(wifiSubscribers)
    }

    var subtotal: Double {
        Double(rentFee) + Double(trailerFee) + wifiShare
    }

    var rentDueDate: Date {
        let now = Date()
        var dc = Calendar.current.dateComponents([.year, .month], from: now)
        dc.month! += 1
        dc.day = 1
        return Calendar.current.date(from: dc)!
    }
}


// MARK: - Supabase Sync
extension BoardingInfo {

    // Load user profile
    @MainActor
    func loadProfile(from client: SupabaseClient, userId: String) async {
        do {
            let response = try await client
                .from("user_profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()

            let data = try JSONDecoder().decode(UserProfile.self, from: response.data)

            self.userId      = data.id
            self.email       = data.email
            self.usesWifi    = data.uses_wifi
            self.usesTrailer = data.uses_trailer

        } catch {
            // silent fail
        }
    }

    // Reset state
    func reset() {
        userId = ""
        usesTrailer = false
        usesWifi = false
        horseCount = 0
        wifiSubscribers = 1
    }

    // Save profile settings
    func saveProfile(to client: SupabaseClient) async {
        guard !userId.isEmpty else { return }

        let payload: [String: AnyEncodable] = [
            "uses_wifi": AnyEncodable(value: usesWifi),
            "uses_trailer": AnyEncodable(value: usesTrailer)
        ]

        do {
            _ = try await client
                .from("user_profiles")
                .update(payload)
                .eq("id", value: userId)
                .execute()
        } catch {
            // silent fail
        }
    }

    // Load total number of WiFi subscribers
    @MainActor
    func loadWifiSubscribers(from client: SupabaseClient) async {
        do {
            let response = try await client
                .from("wifi_subscribers")
                .select("id")
                .execute()

            struct WiFiRow: Decodable { let id: String }
            let rows = try JSONDecoder().decode([WiFiRow].self, from: response.data)

            self.wifiSubscribers = max(rows.count, 1)

        } catch {
            // silent fail
        }
    }

    // Load available stalls
    @MainActor
    func loadAvailableStalls(from client: SupabaseClient) async {
        do {
            let response = try await client
                .from("settings")
                .select()
                .single()
                .execute()

            let data = try JSONDecoder().decode(RanchSettings.self, from: response.data)
            self.availableStalls = data.available_stalls

        } catch {
            // silent fail
        }
    }
}


// MARK: - Models
struct UserProfile: Decodable {
    let id: String
    let email: String
    let uses_wifi: Bool
    let uses_trailer: Bool
}

struct RanchSettings: Decodable {
    let available_stalls: Int
}
