//
//  BoardingView.swift
//  JacobsRanchApp
//

import SwiftUI
import Supabase

/// A button style that swaps background color when pressed
struct PressableButtonStyle: ButtonStyle {
    let normalColor: Color
    let pressedColor: Color
    let cornerRadius: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(configuration.isPressed ? pressedColor : normalColor)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// A single row showing a fee line item
struct FeeRow: View {
    let label: String
    let detail: String
    let amount: Double

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                Text(detail)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(amount, format: .currency(code: "USD"))
        }
    }
}

struct BoardingView: View {
    @EnvironmentObject var info: BoardingInfo
    @Environment(\.supabase) private var supabase
    @Environment(\.dismiss) private var dismiss

    @State private var showZelleAlert = false

    private let buttonColor = Color("DarkBlue")

    var body: some View {
        VStack(spacing: 24) {

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

            Text("BOARDING")
                .font(.largeTitle)
                .bold()

            // Fees breakdown
            VStack(spacing: 16) {
                FeeRow(
                    label: "Rent",
                    detail: "\(info.horseCount)×$\(info.stallRate)",
                    amount: Double(info.rentFee)
                )

                FeeRow(
                    label: "Trailer",
                    detail: info.usesTrailer ? "$\(info.trailerRate)" : "$0",
                    amount: Double(info.trailerFee)
                )

                FeeRow(
                    label: "Wi-Fi Share",
                    detail: info.usesWifi
                        ? "\(info.wifiSubscribers) profiles"
                        : "Not using Wi-Fi",
                    amount: info.wifiShare
                )

                Divider()

                HStack {
                    Text("Subtotal:")
                    Spacer()
                    Text(info.subtotal, format: .currency(code: "USD"))
                        .bold()
                }
            }
            .padding(.horizontal, 24)

            // Rent due date
            Text("Rent due: \(info.rentDueDate.formatted(.dateTime.month().day().year()))")
                .font(.footnote)
                .foregroundColor(.secondary)

            // Zelle Payment Button
            Button {
                let zelleEmail = "jacobsranchandstables@gmail.com"

                // Try opening major banking apps
                let bankLinks = [
                    "chase://pay",
                    "bofa://payments/zelle",
                    "wellsfargo://zelle"
                ]

                var openedBankApp = false

                for link in bankLinks {
                    if let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                        openedBankApp = true
                        break
                    }
                }

                // If no bank app found, copy Zelle email
                if !openedBankApp {
                    UIPasteboard.general.string = zelleEmail
                    showZelleAlert = true
                }

            } label: {
                Text("Zelle Jacob's Ranch & Stables")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .buttonStyle(
                PressableButtonStyle(
                    normalColor: (Color("DarkBlue")),
                    pressedColor: .black,
                    cornerRadius: 12
                )
            )
            .padding(.horizontal, 24)
            .alert("Zelle Email Copied", isPresented: $showZelleAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("No compatible banking app was found. The Zelle email has been copied; paste it into your bank app to complete payment.")
            }

            Spacer()
        }
        .padding(.top, 20)
        .navigationBarHidden(true)
        .onAppear {
            Task {
                // ALWAYS refresh before showing page
                if let session = try? await supabase.auth.session {
                    let userId = session.user.id.uuidString

                    // Refresh user profile + trailer/wifi settings
                    await info.loadProfile(from: supabase, userId: userId)

                    // Refresh horse count
                    let horses = try? await supabase
                        .from("horses")
                        .select("id")
                        .eq("user_id", value: userId)
                        .execute()

                    if let horses = horses {
                        let count = try? JSONDecoder().decode([Horse].self, from: horses.data)
                        info.horseCount = count?.count ?? 1
                    }

                    // Refresh number of total WiFi users
                    await info.loadWifiSubscribers(from: supabase)
                }
            }
        }
    }
}

struct BoardingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BoardingView()
        }
        .environmentObject(BoardingInfo())
    }
}
