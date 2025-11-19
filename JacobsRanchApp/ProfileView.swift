//
//  ProfileView.swift
//  JacobsRanchApp
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var showLogoutAlert = false
    @State private var navigateToLogin = false

    @EnvironmentObject private var horsesVM: HorsesViewModel
    @EnvironmentObject private var boardingInfo: BoardingInfo
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(Color("DarkBlue"))
                }
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))

            Form {
                Section(header:
                    HStack {
                        Text("Your Horses")
                        Spacer()
                        Button(action: horsesVM.addHorse) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color("DarkBlue"))
                        }
                    }
                ) {
                    ForEach($horsesVM.horses) { $horse in
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Horse Name", text: $horse.name)
                                .onChange(of: horse.name) { _, _ in horsesVM.saveHorses() }

                            TextField("Owners (comma-separated)", text: $horse.owners)
                                .onChange(of: horse.owners) { _, _ in horsesVM.saveHorses() }

                            TextField("Owner Contact", text: $horse.ownerContact)
                                .keyboardType(.phonePad)
                                .onChange(of: horse.ownerContact) { _, _ in horsesVM.saveHorses() }

                            TextField("Emergency Contact", text: $horse.emergencyContact)
                                .keyboardType(.phonePad)
                                .onChange(of: horse.emergencyContact) { _, _ in horsesVM.saveHorses() }

                            TextField("Vet Contact", text: $horse.vetContact)
                                .keyboardType(.phonePad)
                                .onChange(of: horse.vetContact) { _, _ in horsesVM.saveHorses() }
                        }
                        .padding(.vertical, 8)
                    }
                    .onDelete(perform: horsesVM.removeHorse)
                    .deleteDisabled(horsesVM.horses.count <= 1)
                }

                Section(header: Text("Boarding Extras")) {
                    HStack {
                        Text("Boarded Horses")
                        Spacer()
                        Text("\(max(1, horsesVM.horses.count))")
                    }

                    Toggle("Trailer Parking ($\(boardingInfo.trailerRate))",
                           isOn: $boardingInfo.usesTrailer)

                    Toggle("Use Wi-Fi",
                           isOn: $boardingInfo.usesWifi)
                }

                Section(header: Text("Account")) {
                    NavigationLink("Change Password", destination: ChangePasswordView())
                    NavigationLink("Update Email", destination: UpdateEmailView())

                    Button("Log Out") {
                        showLogoutAlert = true
                    }
                    .foregroundColor(.red)
                    .alert("Are you sure you want to log out?", isPresented: $showLogoutAlert) {
                        Button("Log Out", role: .destructive) {
                            isLoggedIn = false
                            navigateToLogin = true
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
            .toolbar { EditButton() }
            .onReceive(horsesVM.$horses) { list in
                boardingInfo.horseCount = max(1, list.count)
            }
            .navigationBarBackButtonHidden(true)

            // For logout navigation
            .navigationDestination(isPresented: $navigateToLogin) {
                ContentView().navigationBarBackButtonHidden(true)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
        }
        .environmentObject(BoardingInfo())
        .environmentObject(HorsesViewModel())
    }
}
