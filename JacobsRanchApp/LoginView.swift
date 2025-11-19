//
//  LoginView.swift
//  JacobsRanchApp
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var showPassword = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var navigateToHome = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var boardingInfo: BoardingInfo

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
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

                // Email Field
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

                // Password Field
                HStack {
                    Image(systemName: "lock").foregroundColor(.gray)
                    Group {
                        if showPassword {
                            TextField("Enter your password", text: $password)
                        } else {
                            SecureField("Enter your password", text: $password)
                        }
                    }
                    .autocapitalization(.none)

                    Button { showPassword.toggle() } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                .padding(.horizontal)

                // Remember me + Forgot password
                HStack {
                    Button { rememberMe.toggle() } label: {
                        Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                            .font(.title3)
                            .foregroundColor(rememberMe ? .black : .gray)
                    }
                    Text("Remember me").font(.footnote)

                    Spacer()

                    NavigationLink("Forgot password?", destination: ResetPasswordView())
                        .font(.footnote)
                        .foregroundColor(Color("DarkBlue"))
                }
                .padding(.horizontal)

                // Navigate to home after login
                NavigationLink(
                    destination: HomeView().navigationBarBackButtonHidden(true),
                    isActive: $navigateToHome
                ) { EmptyView() }

                // Sign-In Button
                Button(action: signIn) {
                    Text("SIGN IN")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color("DarkBlue")))
                }
                .padding(.horizontal)

                Spacer()

                // Create account link
                HStack {
                    Text("Not a member?").font(.footnote).foregroundColor(.secondary)
                    NavigationLink("Create a new account", destination: RegisterView())
                        .font(.footnote)
                        .foregroundColor(Color("DarkBlue"))
                        .underline()
                }
                .padding(.bottom, 20)
            }
            .padding(.top, 20)
            .navigationBarBackButtonHidden(true)
            .alert("Login Failed", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    // TEMPORARY LOGIN (until Supabase)
    private func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please enter both email and password."
            showAlert = true
            return
        }

        // TEMP: Simulate successful login
        if password.count < 3 {
            alertMessage = "Invalid email or password."
            showAlert = true
            return
        }

        // Set default horse count
        boardingInfo.horseCount = 1

        isLoggedIn = true
        navigateToHome = true
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginView()
                .environmentObject(BoardingInfo())
        }
    }
}
