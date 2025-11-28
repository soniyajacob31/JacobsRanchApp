//
//  HomeView.swift
//  JacobsRanchApp
//

import SwiftUI
import Supabase

struct HomeView: View {

    @EnvironmentObject private var boardingInfo: BoardingInfo
    @Environment(\.supabase) private var supabase

    @AppStorage("hasCompletedProfile") private var hasCompletedProfile = false
    @State private var showProfilePrompt = false

    @EnvironmentObject private var horsesVM: HorsesViewModel

    var body: some View {
        VStack(spacing: 24) {

            // Logo
            Image("LogoHorses")
                .resizable()
                .scaledToFit()
                .frame(height: 130)
                .padding(.top, 50)

            // Available stalls
            HStack {
                Text("Available Stalls")
                    .font(.headline)
                    .foregroundColor(Color("DarkBlue"))

                Spacer()

                Text("\(boardingInfo.availableStalls)")
                    .font(.headline)
                    .foregroundColor(Color("DarkBlue"))
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)

            // Menu rows
            VStack(spacing: 0) {
                MenuRow(title: "Stalls") {
                    StallsView()
                }
                MenuRow(title: "Boarding") {
                    BoardingView()
                }
                MenuRow(title: "Forms") {
                    FormsView()
                }
                MenuRow(title: "Identify Horse") {
                        IdentifyHorseView()
                }
                MenuRow(title: "Profile") {
                    ProfileView()
                }
            }
            .padding(.horizontal, 30)

            Spacer()

        }
        .navigationBarTitleDisplayMode(.inline)

        .task {
            await boardingInfo.loadAvailableStalls(from: supabase)
        }

        .onChange(of: horsesVM.finishedLoading) { finished in
            if finished && !hasCompletedProfile {
                if horsesVM.horses.count == 1 &&
                    horsesVM.horses.first?.name.isEmpty == true {
                    showProfilePrompt = true
                }
            }
        }
        .alert("Tell us about your horse(s)!", isPresented: $showProfilePrompt) {
            Button("Got it") { hasCompletedProfile = true }
        }
    }
}

struct MenuRow<Destination: View>: View {
    let title: String
    let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination()) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 16)
        }
    }
}
