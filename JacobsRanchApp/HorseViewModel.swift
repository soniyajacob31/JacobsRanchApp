//
//  HorsesViewModel.swift
//  JacobsRanchApp
//

import SwiftUI
import Foundation

class HorsesViewModel: ObservableObject {
    @Published var horses: [Horse] = []
    @Published var finishedLoading = false

    // TEMP: No backend yet
    private var userId: String? {
        return "local-user-id"
    }

    init() {
        loadHorses()
    }

    func addHorse() {
        horses.append(Horse())
        saveHorses()
    }

    func removeHorse(at offsets: IndexSet) {
        horses.remove(atOffsets: offsets)
        saveHorses()
    }

    func saveHorses() {
        // TEMP: No backend — store locally for now
        let data = horses.map { $0.toDictionary() }
        UserDefaults.standard.set(data, forKey: "horses")
    }

    func loadHorses() {
        if let saved = UserDefaults.standard.array(forKey: "horses") as? [[String: Any]] {
            self.horses = saved.map { Horse.fromDictionary($0) }
        } else {
            self.horses = [Horse()]  // default one horse
        }
        
        self.finishedLoading = true
    }
}
