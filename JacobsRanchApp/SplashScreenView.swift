//
//  SplashScreenView.swift
//  JacobsRanchApp
//

import SwiftUI

struct SplashScreenView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var showNext = false

    // Set to true for testing — app will go to ContentView
    private let isTesting = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 20) {
                    Image("LogoHorses")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 160)

                    Text("Jacob's Ranch and Stables")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }

                // Navigation logic
                NavigationLink(destination: nextView, isActive: $showNext) {
                    EmptyView()
                }
            }
            .onAppear {
                // Delay for splash screen duration
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showNext = true
                }
            }
        }
    }

    private var nextView: some View {
        if isTesting {
            return AnyView(ContentView())
        } else {
            return isLoggedIn
                ? AnyView(HomeView())
                : AnyView(ContentView())
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
