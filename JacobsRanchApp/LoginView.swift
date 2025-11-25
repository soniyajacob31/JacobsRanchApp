//
//  LoginView.swift
//  JacobsRanchApp
//

import SwiftUI
import Supabase

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToHome = false

    @AppStorage("isLoggedIn") private var isLoggedIn = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.supabase) var supabase: SupabaseClient
    @EnvironmentObject private var boardingInfo: BoardingInfo

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

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

                Text("Welcome Back")
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

                // PASSWORD
                HStack {
                    Image(systemName: "lock").foregroundColor(.gray)

                    Group {
                        if showPassword {
                            TextField("Enter your password", text: $password)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Enter your password", text: $password)
                                .autocapitalization(.none)
                        }
                    }

                    Button { showPassword.toggle() } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                .padding(.horizontal)

                NavigationLink(
                    "",
                    destination: HomeView()
                        .navigationBarBackButtonHidden(true),
                    isActive: $navigateToHome
                )

                // SIGN IN BUTTON
                Button(action: signIn) {
                    Text("SIGN IN")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color("DarkBlue")))
                }
                .padding(.horizontal)

                Spacer()

                // Register link
                HStack {
                    Text("Not a member?")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    NavigationLink("Create a new account", destination: RegisterView())
                        .font(.footnote)
                        .foregroundColor(Color("DarkBlue"))
                        .underline()
                }
                .padding(.bottom, 20)
            }
            .padding(.top, 20)
            .navigationBarBackButtonHidden(true)     // <-- FIXED HERE
            .alert("Login Failed", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please enter both email and password."
            showAlert = true
            return
        }

        Task {
            do {
                try await supabase.auth.signIn(email: email, password: password)

                isLoggedIn = true

                // Load profile into BoardingInfo
                if let session = try? await supabase.auth.session {
                    let userId = session.user.id.uuidString
                    await boardingInfo.loadProfile(from: supabase, userId: userId)
                }

                navigateToHome = true

            } catch {
                alertMessage = "Invalid email or password."
                showAlert = true
            }
        }
    }
}
