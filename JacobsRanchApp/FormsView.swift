//
//  FormsView.swift
//  JacobsRanchApp
//


import SwiftUI

struct FormsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // ← Custom back chevron
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(Color("DarkBlue"))
                }
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))

            // Title
            Text("Your Contract")
                .font(.title2)
                .bold()
                .padding(.top, 8)

            // Scrollable contract image
            ScrollView {
                Image("Contract")    // your bundled contract PNG
                    .resizable()
                    .scaledToFit()
                    .padding()
            }

            Spacer()
        }
        .navigationBarHidden(true)
        .navigationTitle("Forms")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FormsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FormsView()
        }
    }
}
