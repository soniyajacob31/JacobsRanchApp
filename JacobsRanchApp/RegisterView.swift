//
//  RegisterView.swift
//  JacobsRanchApp
//

import SwiftUI
import Supabase
import Auth

struct RegisterView: View {
    @State private var email = ""
    @State private var inviteCode = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var showPassword = false
    @State private var showConfirmPassword = false

    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var goHome = false

    @AppStorage("isLoggedIn") private var isLoggedIn = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.supabase) var client: SupabaseClient
    @EnvironmentObject private var boardingInfo: BoardingInfo

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                // Custom back button (blue)
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(Color("DarkBlue"))
                    }
                    Spacer()
                }
                .padding(.horizontal)

                Image("LogoHorses")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 130)

                Text("Register Now")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 30)

                // EMAIL
                HStack {
                    Image(systemName: "envelope").foregroundColor(.gray)
                    TextField("Enter your email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                .padding(.horizontal)

                // INVITE CODE
                HStack {
                    Image(systemName: "tag").foregroundColor(.gray)
                    TextField("Enter invite code", text: $inviteCode)
                        .autocapitalization(.none)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                .padding(.horizontal)

                // PASSWORD
                HStack {
                    Image(systemName: "lock").foregroundColor(.gray)

                    if showPassword {
                        TextField("Enter password", text: $password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Enter password", text: $password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }

                    Button { showPassword.toggle() } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                .padding(.horizontal)

                // CONFIRM PASSWORD
                HStack {
                    Image(systemName: "lock.rotation").foregroundColor(.gray)

                    if showConfirmPassword {
                        TextField("Confirm password", text: $confirmPassword)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Confirm password", text: $confirmPassword)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }

                    Button { showConfirmPassword.toggle() } label: {
                        Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                .padding(.horizontal)

                // Hidden nav link to go home
                NavigationLink(
                    "",
                    destination: HomeView().navigationBarBackButtonHidden(true),
                    isActive: $goHome
                )

                // REGISTER BUTTON
                Button(action: signUp) {
                    Text("REGISTER")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color("DarkBlue")))
                }
                .padding(.horizontal)
                .disabled(email.isEmpty || inviteCode.isEmpty || password.isEmpty || confirmPassword.isEmpty)

                Spacer()
            }
            .padding(.top, 20)
            .navigationBarBackButtonHidden(true)
            .alert("Message", isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    if alertMessage == "Account created! You can now log in." {
                        goHome = false
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func signUp() {
        guard inviteCode == "RANCH2017" else {
            showError("Invalid invite code.")
            return
        }

        guard password == confirmPassword else {
            showError("Passwords do not match.")
            return
        }

        Task {
            await executeSignup()
        }
    }

    @MainActor
    private func executeSignup() async {
        do {
            // Create the account
            let response = try await client.auth.signUp(
                email: email,
                password: password
            )

            let user = response.user
            let uid = user.id.uuidString

            // Insert default profile
            let payload: [String: AnyEncodable] = [
                "id": AnyEncodable(value: uid),
                "email": AnyEncodable(value: email),
                "uses_wifi": AnyEncodable(value: false),
                "uses_trailer": AnyEncodable(value: false)
            ]

            try await client
                .from("user_profiles")
                .insert(payload)
                .execute()

            showSuccess("Account created! You can now log in.")

        } catch {
            showError("Signup failed: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }

    @MainActor
    private func showSuccess(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}
