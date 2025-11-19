import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var inviteCode = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @EnvironmentObject private var boardingInfo: BoardingInfo

    var body: some View {
        VStack(spacing: 20) {
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

            // Email field
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

            // Invite code field
            HStack {
                Image(systemName: "tag").foregroundColor(.gray)
                TextField("Enter invite code", text: $inviteCode)
                    .autocapitalization(.none)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
            .padding(.horizontal)

            // Register button
            Button(action: signUp) {
                Text("REGISTER")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color("DarkBlue")))
            }
            .padding(.horizontal)
            .disabled(email.isEmpty || inviteCode.isEmpty)

            Spacer()
        }
        .padding(.top, 20)
        .navigationBarBackButtonHidden(true)
        .alert("Message", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                if alertMessage == "Check your inbox to set a password." {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }

    private func signUp() {
        guard !email.isEmpty, !inviteCode.isEmpty else {
            alertMessage = "Email and invite code required."
            showAlert = true
            return
        }

        if inviteCode != "HORSE2025" {
            alertMessage = "Invalid invite code."
            showAlert = true
            return
        }

        // TEMP — No backend yet
        boardingInfo.horseCount = 1

        alertMessage = "Check your inbox to set a password (Supabase will handle this later)."
        showAlert = true
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RegisterView()
                .environmentObject(BoardingInfo())
        }
    }
}
