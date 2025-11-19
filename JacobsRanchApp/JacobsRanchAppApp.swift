//
//  JacobsRanchAppApp.swift
//  JacobsRanchApp
//

import SwiftUI

@main
struct JacobsRanchAppApp: App {
    @StateObject private var boardingInfo = BoardingInfo()

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(boardingInfo)
        }
    }
}
