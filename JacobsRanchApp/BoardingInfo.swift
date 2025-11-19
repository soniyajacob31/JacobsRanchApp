//
//  BoardingInfo.swift
//  JacobsRanchApp
//

import Foundation
import SwiftUI

/// Holds the user’s boarding settings and computes fees
final class BoardingInfo: ObservableObject {
    @Published var horseCount: Int       = 1
    @Published var usesTrailer: Bool     = false
    @Published var usesWifi: Bool        = false   // opt-in toggle
    @Published var wifiSubscribers: Int  = 1       // families sharing the $50

    // Pricing constants
    let stallRate   = 250
    let trailerRate = 50
    let wifiRate    = 50   // TOTAL Wi-Fi cost per month, split below

    // Computed fees
    var rentFee: Int       { horseCount * stallRate }
    var trailerFee: Int    { usesTrailer ? trailerRate : 0 }
    var wifiShare: Double  {
        guard usesWifi, wifiSubscribers > 0 else { return 0 }
        return Double(wifiRate) / Double(wifiSubscribers)
    }

    var subtotal: Double {
        Double(rentFee) + Double(trailerFee) + wifiShare
    }

    var rentDueDate: Date {
        let now = Date()
        var dc = Calendar.current.dateComponents([.year, .month], from: now)
        dc.month! += 1; dc.day = 1
        return Calendar.current.date(from: dc)!
    }
}
