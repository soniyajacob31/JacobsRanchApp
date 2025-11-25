//
//  ChangePasswordView.swift
//  JacobsRanchApp
//

import SwiftUI
import Supabase

struct ChangePasswordView: View {

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    @State private var showCurrent = false
    @State private var showNew = false
    @State private var showConfirm = false

    @State private var showSuccessBanner = false
    @State private var showError = false
    @State private var errorMessage = ""

    @Environment(\.dismiss) private var dismiss
    @Environment(\.supabase) private var supabase: SupabaseClient

    var passwordsMatch: Bool {
        !newPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6
    }

    var body: some View {
        VStack(spacing: 20) {

            // Back button
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

            Text("Change Password")
                .font(.title)
                .bold()
                .padding(.bottom, 20)

            // CURRENT PASSWORD FIELD
            passwordField(
                title: "Current Password",
                text: $currentPassword,
                show: $showCurrent
            )

            // NEW PASSWORD FIELD
            passwordField(
                title: "New Password",
                text: $newPassword,
                show: $showNew
            )

            // CONFIRM PASSWORD
            passwordField(
                title: "Confirm Password",
                text: $confirmPassword,
                show: $showConfirm
            )
            .overlay(
                Group {
                    if !confirmPassword.isEmpty && !passwordsMatch {
                        Text("Passwords do not match")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 50)
                    }
                },
                alignment: .bottomLeading
            )

            // SAVE BUTTON
            Button {
                Task { await handlePasswordChange() }
            } label: {
                Text("SAVE")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color("DarkBlue")))
            }
            .padding(.horizontal)
            .disabled(!passwordsMatch)
            .opacity(passwordsMatch ? 1 : 0.4)

            Spacer()

            if showSuccessBanner {
                VStack {
                    Text("Password Updated!")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Password FIELD UI
    @ViewBuilder
    func passwordField(title: String, text: Binding<String>, show: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.gray)

            Group {
                if show.wrappedValue {
                    TextField(title, text: text)
                } else {
                    SecureField(title, text: text)
                }
            }

            Button { show.wrappedValue.toggle() } label: {
                Image(systemName: show.wrappedValue ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.5))
        )
        .padding(.horizontal)
    }

    // MARK: - SUPABASE LOGIC
    @MainActor
    private func handlePasswordChange() async {
        guard let session = try? await supabase.auth.session else {
            errorMessage = "Session expired. Please log in again."
            showError = true
            return
        }

        let email = session.user.email ?? ""

        // 1. REAUTH user with current password
        do {
            _ = try await supabase.auth.signIn(
                email: email,
                password: currentPassword
            )
        } catch {
            errorMessage = "Current password is incorrect."
            showError = true
            return
        }

        // 2. UPDATE password
        do {
            try await supabase.auth.update(
                user: UserAttributes(password: newPassword)
            )

            withAnimation { showSuccessBanner = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation { showSuccessBanner = false }
            }

        } catch {
            errorMessage = "Failed to update password."
            showError = true
        }
    }
}
