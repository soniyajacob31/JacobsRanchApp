//
//  ContentView.swift
//  JacobsRanchApp
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Logo
            Image("LogoHorses")
                .resizable()
                .scaledToFit()
                .frame(height: 145)

            // Title
            Text("JACOB’S\nRANCH AND STABLES")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            // LOGIN button
            NavigationLink {
                LoginView()
            } label: {
                Text("LOGIN")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("DarkBlue"))
                            .shadow(color: Color.black.opacity(0.5),
                                    radius: 4, x: 0, y: 2)
                    )
            }
            .padding(.horizontal)

            // Get Started button
            NavigationLink {
                RegisterView()
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .fontWeight(.regular)
                    .foregroundColor(Color.black)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.5),
                                    radius: 4, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.vertical, 20)
        .navigationBarBackButtonHidden(true) 
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentView()
        }
    }
}
