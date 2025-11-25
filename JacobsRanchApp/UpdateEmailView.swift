//
//  UpdateEmailView.swift
//  JacobsRanchApp
//

import SwiftUI
import Supabase

struct UpdateEmailView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.supabase) private var supabase: SupabaseClient
    @EnvironmentObject private var boardingInfo: BoardingInfo

    @State private var newEmail = ""
    @State private var showBanner = false
    @State private var showError = false
    @State private var errorMessage = ""

    var isValidEmail: Bool {
        newEmail.contains("@") && newEmail.contains(".")
    }

    var body: some View {
        VStack(spacing: 20) {

            // Back Arrow
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(Color("DarkBlue"))
                }
                Spacer()
            }
            .padding(.horizontal)

            // Logo
            Image("LogoHorses")
                .resizable()
                .scaledToFit()
                .frame(height: 130)

            Text("Update Email")
                .font(.title)
                .bold()
                .padding(.bottom, 30)

            // Input Field
            HStack {
                Image(systemName: "envelope").foregroundColor(.gray)
                TextField("New email address", text: $newEmail)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.4))
            )
            .padding(.horizontal)

            // SAVE BUTTON
            Button {
                Task { await handleEmailUpdate() }
            } label: {
                Text("SAVE")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color("DarkBlue")))
            }
            .padding(.horizontal)
            .disabled(!isValidEmail)
            .opacity(isValidEmail ? 1 : 0.4)

            // RESEND VERIFICATION
            Button("Resend Verification Email") {
                Task { await resendVerification() }
            }
            .foregroundColor(Color("DarkBlue"))

            Spacer()

            // SUCCESS BANNER
            if showBanner {
                VStack {
                    Text("Email Updated!")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.85))
                        .foregroundColor(.white)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: EMAIL UPDATE LOGIC
    @MainActor
    private func handleEmailUpdate() async {

        // 1) Duplicate check manually (no maybeSingle)
        do {
            let result = try await supabase
                .from("user_profiles")
                .select()
                .eq("email", value: newEmail)
                .execute()

            if !result.data.isEmpty {
                errorMessage = "This email is already in use."
                showError = true
                return
            }
        } catch {}

        // 2) Update Supabase Auth
        do {
            try await supabase.auth.update(user: UserAttributes(email: newEmail))
        } catch {
            errorMessage = "Failed to update email: \(error.localizedDescription)"
            showError = true
            return
        }

        // 3) Update user_profiles
        do {
            _ = try await supabase
                .from("user_profiles")
                .update(["email": AnyEncodable(value: newEmail)])
                .eq("id", value: boardingInfo.userId)
                .execute()

            boardingInfo.email = newEmail

        } catch {
            errorMessage = "Failed to update user profile."
            showError = true
            return
        }

        // 4) Success banner animation
        withAnimation { showBanner = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation { showBanner = false }
        }
    }

    // MARK: RESEND VERIFICATION
    @MainActor
    private func resendVerification() async {
        do {
            try await supabase.auth.resend(email: boardingInfo.email, type: .signup)
        } catch {
            errorMessage = "Could not resend verification email."
            showError = true
        }
    }
}
