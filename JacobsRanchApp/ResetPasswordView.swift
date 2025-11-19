//
//  ResetPasswordView.swift
//  JacobsRanchApp
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var email = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
            .padding(.horizontal)

            Image("LogoHorses")
                .resizable()
                .scaledToFit()
                .frame(height: 130)

            Text("Reset Password")
                .font(.title)
                .bold()
                .padding(.bottom, 30)

            HStack {
                Image(systemName: "envelope").foregroundColor(.gray)
                TextField("Enter your email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5))
            )
            .padding(.horizontal)

            Button {
                // TEMPORARY — backend not implemented yet
                alertMessage = "A reset email will be sent once Supabase authentication is added."
                showAlert = true

            } label: {
                Text("RESET PASSWORD")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("DarkBlue"))
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
            }
            .padding(.horizontal)
            .disabled(email.isEmpty)

            Spacer()
        }
        .padding(.top, 20)
        .navigationBarBackButtonHidden(true)
        .alert("Message", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text(alertMessage)
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ResetPasswordView()
        }
    }
}
