//
//  BoardingView.swift
//  JacobsRanchApp
//

import SwiftUI

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
    @Environment(\.dismiss) private var dismiss
    private let buttonColor = Color("DarkBlue")

    var body: some View {
        VStack(spacing: 24) {
            // Custom back button
            HStack {
                Button {
                  dismiss()
                } label: {
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

            // Pay with Apple Pay
            Button {
                // TODO: trigger Apple Pay
            } label: {
                Text("Pay with Pay")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .buttonStyle(
                PressableButtonStyle(
                    normalColor: .black,
                    pressedColor: buttonColor,
                    cornerRadius: 12
                )
            )
            .padding(.horizontal, 24)

            Spacer()
        }
        .padding(.top, 20)
        .navigationBarHidden(true)
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

