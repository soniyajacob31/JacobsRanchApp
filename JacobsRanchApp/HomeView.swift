//
//  HomeView.swift
//  JacobsRanchApp
//

import SwiftUI

struct HomeView: View {
    private let totalStalls = 14

    @EnvironmentObject private var boardingInfo: BoardingInfo
    @AppStorage("hasCompletedProfile") private var hasCompletedProfile = false
    @State private var showProfilePrompt = false

    @StateObject private var horsesVM = HorsesViewModel()

    private var availableStalls: Int {
        max(0, totalStalls - boardingInfo.horseCount)
    }

    var body: some View {
        VStack(spacing: 24) {
            Image("LogoHorses")
                .resizable()
                .scaledToFit()
                .frame(height: 130)
                .padding(.top, 50)

            HStack {
                Text("Available Stalls")
                    .font(.headline)
                Spacer()
                Text("\(availableStalls)")
                    .font(.headline)
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)

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
                MenuRow(title: "Profile") {
                    ProfileView()
                        .environmentObject(boardingInfo)
                        .environmentObject(horsesVM)
                }
            }
            .padding(.horizontal, 30)

            Spacer()

            HStack {
                Spacer()
                Button {
                    // TODO: Help
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.title2)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)

        .onChange(of: horsesVM.finishedLoading) { finished in
            if finished && !hasCompletedProfile {
                if horsesVM.horses.count == 1,
                   horsesVM.horses.first?.name.isEmpty == true {
                    showProfilePrompt = true
                }
            }
        }

        .alert("Tell us about your horse(s)!", isPresented: $showProfilePrompt) {
            Button("Got it") {
                hasCompletedProfile = true
            }
        } message: {
            Text("Head to your Profile and add your horse’s info.")
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
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 16)
        }
    }
}
