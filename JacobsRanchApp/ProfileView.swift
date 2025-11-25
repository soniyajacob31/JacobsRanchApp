//
//  ProfileView.swift
//  JacobsRanchApp
//

import SwiftUI
import Supabase

struct ProfileView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var showLogoutAlert = false

    @State private var showSaveSuccess = false
    @State private var showSaveError = false
    @State private var saveErrorMessage = ""

    @EnvironmentObject private var horsesVM: HorsesViewModel
    @EnvironmentObject private var boardingInfo: BoardingInfo
    @Environment(\.dismiss) private var dismiss
    @Environment(\.supabase) private var supabase: SupabaseClient

    var body: some View {
        VStack(spacing: 0) {

            // TOP BAR
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(Color("DarkBlue"))
                }
                Spacer()
                EditButton()
                    .foregroundColor(Color("DarkBlue"))
            }
            .padding()
            .background(Color(.systemGroupedBackground))

            ZStack {
                Form {

                    // MARK: — HORSES
                    Section(header:
                        HStack {
                            Text("Your Horses")
                            Spacer()
                            Button {
                                Task { await horsesVM.addHorse(userId: boardingInfo.userId) }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color("DarkBlue"))
                            }
                        }
                    ) {

                        ForEach($horsesVM.horses) { $horse in
                            VStack(alignment: .leading, spacing: 14) {

                                Text("Horse \(indexFor(horse: horse))")
                                    .font(.headline)

                                TextField("Horse Name", text: $horse.name)

                                TextField("Owners (Comma separated if multiple)",
                                          text: $horse.owners)

                                TextField("Owner Contact (10 digits)",
                                          text: $horse.ownerContact)
                                    .keyboardType(.numberPad)

                                TextField("Emergency Contact (10 digits)",
                                          text: $horse.emergencyContact)
                                    .keyboardType(.numberPad)

                                TextField("Vet Contact (10 digits)",
                                          text: $horse.vetContact)
                                    .keyboardType(.numberPad)
                            }
                            .padding(.vertical, 6)
                        }
                        .onDelete { indexSet in
                            Task {
                                for i in indexSet {
                                    if let id = horsesVM.horses[i].id {
                                        await horsesVM.deleteHorse(id: id)
                                    }
                                }
                                await horsesVM.loadHorses(userId: boardingInfo.userId)
                            }
                        }

                        Button(action: {
                            Task { await handleSaveAll() }
                        }) {
                            Text("Save Changes")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("DarkBlue"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }

                    // MARK: — BOARDING EXTRAS
                    Section(header: Text("Boarding Extras")) {

                        Toggle("Trailer Parking ($\(boardingInfo.trailerRate))",
                               isOn: $boardingInfo.usesTrailer)
                            .onChange(of: boardingInfo.usesTrailer) { _, _ in
                                Task { await boardingInfo.saveProfile(to: supabase) }
                            }

                        Toggle("Use Wi-Fi",
                               isOn: $boardingInfo.usesWifi)
                            .onChange(of: boardingInfo.usesWifi) { _, _ in
                                Task { await boardingInfo.saveProfile(to: supabase) }
                            }
                    }

                    // MARK: — ACCOUNT
                    Section(header: Text("Account")) {
                        NavigationLink("Change Password", destination: ChangePasswordView())
                        NavigationLink("Update Email", destination: UpdateEmailView())

                        Button("Log Out") {
                            showLogoutAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }

                // LOGOUT ALERT (correct placement)
                .alert("Are you sure you want to log out?",
                       isPresented: $showLogoutAlert)
                {
                    Button("Log Out", role: .destructive) {
                        Task {
                            do {
                                try await supabase.auth.signOut()
                            } catch {
                                print("Error signing out:", error)
                            }

                            boardingInfo.reset()
                            horsesVM.horses = []
                            isLoggedIn = false
                        }
                    }

                    Button("Cancel", role: .cancel) {}
                }

                // SUCCESS BANNER
                if showSaveSuccess {
                    VStack {
                        Text("Saved!")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.85))
                            .foregroundColor(.white)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        Spacer()
                    }
                }
            }
            .onAppear {
                Task { await horsesVM.loadHorses(userId: boardingInfo.userId) }
            }
        }
        .navigationBarHidden(true)
        .alert("Error Saving", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveErrorMessage)
        }
    }

    // MARK: — Helpers

    private func indexFor(horse: Horse) -> Int {
        if let index = horsesVM.horses.firstIndex(where: { $0.id == horse.id }) {
            return index + 1
        }
        return 1
    }

    @MainActor
    private func handleSaveAll() async {
        var seen = Set<String>()

        for h in horsesVM.horses {
            let name = h.name.trimmingCharacters(in: .whitespaces).lowercased()
            guard !name.isEmpty else { continue }
            if seen.contains(name) {
                saveErrorMessage = "A horse named \"\(h.name)\" already exists."
                showSaveError = true
                return
            }
            seen.insert(name)
        }

        for h in horsesVM.horses {
            for num in [h.ownerContact, h.emergencyContact, h.vetContact] {
                let digits = num.filter(\.isNumber)
                if !digits.isEmpty && digits.count != 10 {
                    saveErrorMessage = "Phone numbers must be 10 digits."
                    showSaveError = true
                    return
                }
            }
        }

        for horse in horsesVM.horses {
            horse.ownerContact = formattedPhone(horse.ownerContact)
            horse.emergencyContact = formattedPhone(horse.emergencyContact)
            horse.vetContact = formattedPhone(horse.vetContact)
            await horsesVM.saveHorse(horse)
        }

        withAnimation { showSaveSuccess = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { showSaveSuccess = false }
        }
    }

    private func formattedPhone(_ phone: String) -> String {
        let digits = phone.filter(\.isNumber)
        guard digits.count == 10 else { return phone }
        return "\(digits.prefix(3))-\(digits.dropFirst(3).prefix(3))-\(digits.suffix(4))"
    }
}
