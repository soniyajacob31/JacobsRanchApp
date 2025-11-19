//
//  UpdateEmailView.swift
//  JacobsRanchApp
//
import SwiftUI

struct UpdateEmailView: View {
    // MARK: State
    @State private var email = ""
    @Environment(\.dismiss) private var dismiss

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
            Text("Update Email")
                .font(.title)
                .bold()
                .padding(.bottom, 30)

            // Email field
            HStack {
                Image(systemName: "envelope")
                    .foregroundColor(.gray)
                TextField("New email address", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5))
            )
            .padding(.horizontal)

            // SAVE button
            Button {
                // TODO: call your email-update API
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
            .disabled(!email.contains("@"))

            Spacer()
        }
        .padding(.top, 20)
        .navigationBarBackButtonHidden(true)
    }
}

struct UpdateEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            UpdateEmailView()
        }
    }
}
