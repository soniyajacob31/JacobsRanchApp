//
//  ChangePasswordView.swift
//  JacobsRanchApp
//


import SwiftUI

struct ChangePasswordView: View {
    // MARK: State
    @State private var currentPassword = ""
    @State private var newPassword     = ""
    @State private var confirmPassword = ""
    @State private var showCurrent     = false
    @State private var showNew         = false
    @State private var showConfirm     = false

    @Environment(\.dismiss) private var dismiss

    // computed validation
    private var passwordsMatch: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword
    }

    var body: some View {
        VStack(spacing: 20) {
            // ← Back chevron
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
            .padding(.horizontal)

            // Logo
            Image("LogoHorses")
                .resizable()
                .scaledToFit()
                .frame(height: 130)

            // Heading
            Text("Change Password")
                .font(.title)
                .bold()
                .padding(.bottom, 30)

            // Current password
            HStack {
                Image(systemName: "lock")
                    .foregroundColor(.gray)
                Group {
                    if showCurrent {
                        TextField("Current password", text: $currentPassword)
                    } else {
                        SecureField("Current password", text: $currentPassword)
                    }
                }
                Button { showCurrent.toggle() } label: {
                    Image(systemName: showCurrent ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5)))
            .padding(.horizontal)

            // New password
            HStack {
                Image(systemName: "lock.rotation")
                    .foregroundColor(.gray)
                Group {
                    if showNew {
                        TextField("New password", text: $newPassword)
                    } else {
                        SecureField("New password", text: $newPassword)
                    }
                }
                Button { showNew.toggle() } label: {
                    Image(systemName: showNew ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5)))
            .padding(.horizontal)

            // Confirm password
            HStack {
                Image(systemName: "lock.shield")
                    .foregroundColor(.gray)
                Group {
                    if showConfirm {
                        TextField("Confirm password", text: $confirmPassword)
                    } else {
                        SecureField("Confirm password", text: $confirmPassword)
                    }
                }
                Button { showConfirm.toggle() } label: {
                    Image(systemName: showConfirm ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                // red border if mismatch
                                (!confirmPassword.isEmpty && !passwordsMatch)
                                ? Color.red
                                : Color.gray.opacity(0.5),
                                lineWidth: 1
                            ))
            .padding(.horizontal)

            // Inline error message
            if !confirmPassword.isEmpty && !passwordsMatch {
                Text("Passwords do not match")
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .transition(.opacity)
            }

            // SAVE button
            Button {
                // TODO: call your password-change API
                dismiss()
            } label: {
                Text("SAVE")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("DarkBlue"))
                            .shadow(color: Color.black.opacity(0.3),
                                    radius: 4, x: 0, y: 2)
                    )
            }
            .padding(.horizontal)
            .disabled(!passwordsMatch)   // only enabled when they match

            Spacer()
        }
        .padding(.top, 20)
        .animation(.easeInOut, value: passwordsMatch)
        .navigationBarBackButtonHidden(true)
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChangePasswordView()
        }
    }
}
