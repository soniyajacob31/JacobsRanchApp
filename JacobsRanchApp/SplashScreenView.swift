//
//  SplashScreenView.swift
//  JacobsRanchApp
//

import SwiftUI
import Supabase

struct SplashScreenView: View {

    @Environment(\.supabase) var supabase: SupabaseClient
    @EnvironmentObject private var boardingInfo: BoardingInfo

    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var goHome = false
    @State private var goLogin = false

    private let isTesting = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 20) {
                    Image("LogoHorses")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 160)

                    Text("Jacob's Ranch and Stables")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }

                NavigationLink("", destination: HomeView(), isActive: $goHome)
                NavigationLink("", destination: ContentView(), isActive: $goLogin)
            }
            .task { await handleStartup() }
        }
    }

    func handleStartup() async {

        // Wait for Supabase to load local session
        try? await Task.sleep(for: .milliseconds(300))

        if isTesting {
            await sleepSplash()
            goHome = true
            return
        }

        // Check session
        if let session = try? await supabase.auth.session {
            isLoggedIn = true

            // Load user profile + stalls
            await boardingInfo.loadProfile(from: supabase, userId: session.user.id.uuidString)
            await boardingInfo.loadAvailableStalls(from: supabase)

            await sleepSplash()
            goHome = true
        } else {
            isLoggedIn = false
            await sleepSplash()
            goLogin = true
        }
    }

    func sleepSplash() async {
        try? await Task.sleep(for: .seconds(1.5))
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
            .environmentObject(BoardingInfo())
    }
}
