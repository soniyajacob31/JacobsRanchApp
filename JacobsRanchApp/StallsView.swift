//
//  StallsView.swift
//  JacobsRanchApp
//

import SwiftUI
import Supabase

// MARK: — Horse Model

struct StallHorse: Decodable, Identifiable {
    let id: Int
    let name: String
    let owners: String
    let owner_contact: String
    let emergency_contact: String
    let vet_contact: String
    let stall_number: Int?
}

// MARK: — ViewModel

class StallsViewModel: ObservableObject {
    @Published var horses: [StallHorse] = []
    @Published var loading = false

    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
        Task { await loadHorses() }
    }

    @MainActor
    func loadHorses() async {
        loading = true
        do {
            let response = try await client
                .from("horses")
                .select()
                .execute()

            let decoded = try JSONDecoder().decode([StallHorse].self, from: response.data)
            horses = decoded
        } catch {
            print("Failed to load horses:", error)
        }
        loading = false
    }

    func horseFor(stallNumber: Int) -> StallHorse? {
        horses.first { $0.stall_number == stallNumber }
    }
}

// MARK: — Main View

struct StallsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: StallsViewModel

    init() {
        _vm = StateObject(
            wrappedValue: StallsViewModel(
                client: JacobsRanchAppApp.supabaseClient
            )
        )
    }

    private let horizontalPadding: CGFloat = 16
    private let corridorWidth: CGFloat     = 40
    private let cellHeight: CGFloat        = 70
    private let interRowGap: CGFloat       = 60

    var body: some View {
        VStack(spacing: 0) {

            // Back arrow
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(Color("DarkBlue"))
                }
                Spacer()
            }
            .padding()
            .background(Color.white)

            if vm.loading {
                ProgressView()
            } else {
                content(vm)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: — Main Layout

    private func content(_ vm: StallsViewModel) -> some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let rawWidth = (totalWidth - horizontalPadding*2 - corridorWidth) / 2
            let cellWidth = max(rawWidth, 1)   

            ScrollView {
                VStack(spacing: 0) {

                    Text("Indoor Arena")
                        .font(.title3.bold())
                        .frame(width: totalWidth - horizontalPadding*2, height: 100)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                        )
                        .padding(.top, 20)

                    stallRow(vm: vm,
                             left: Array(1...4),
                             right: [14, 13, 12, 11],
                             cellWidth: cellWidth,
                             cellHeight: cellHeight)

                    Spacer().frame(height: interRowGap)

                    stallRow(vm: vm,
                             left: Array(5...7),
                             right: [10, 9, 8],
                             cellWidth: cellWidth,
                             cellHeight: cellHeight)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, horizontalPadding)
            }
        }
    }

    // MARK: — Row Generator

    private func stallRow(vm: StallsViewModel,
                          left: [Int],
                          right: [Int],
                          cellWidth: CGFloat,
                          cellHeight: CGFloat) -> some View {

        HStack(spacing: 0) {

            VStack(spacing: 0) {
                ForEach(left, id: \.self) { stallNum in
                    NavigationLink {
                        StallDetailView(
                            horse: vm.horseFor(stallNumber: stallNum),
                            stallNumber: stallNum
                        )
                    } label: {
                        StallCell(label: "Stall \(stallNum)")
                    }
                    .frame(width: cellWidth, height: cellHeight)
                }
            }

            Spacer().frame(width: corridorWidth)

            VStack(spacing: 0) {
                ForEach(right, id: \.self) { stallNum in
                    NavigationLink {
                        StallDetailView(
                            horse: vm.horseFor(stallNumber: stallNum),
                            stallNumber: stallNum
                        )
                    } label: {
                        StallCell(label: "Stall \(stallNum)")
                    }
                    .frame(width: cellWidth, height: cellHeight)
                }
            }
        }
    }
}

// MARK: — Cell UI

struct StallCell: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.headline)
            .foregroundColor(Color("DarkBlue"))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.black, lineWidth: 2)
                    )
            )
    }
}

// MARK: — Detail View

struct StallDetailView: View {
    let horse: StallHorse?
    let stallNumber: Int
    @Environment(\.dismiss) private var dismiss

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
            .padding(.top, 8)

            HStack {
                Spacer()
                Text("Stall \(stallNumber)")
                    .font(.title2)
                    .bold()
                Spacer()
            }

            VStack(spacing: 14) {
                readOnlyRow("Horse Name", horse?.name)
                Divider()

                readOnlyRow("Owners", horse?.owners)
                Divider()

                readOnlyRow("Owner Contact", horse?.owner_contact)
                Divider()

                readOnlyRow("Emergency Contact", horse?.emergency_contact)
                Divider()

                readOnlyRow("Vet Contact", horse?.vet_contact)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
            )
            .padding(.horizontal)

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("DarkBlue"))
                    )
            }
            .padding(.horizontal, 30)

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.white)
    }

    private func readOnlyRow(_ label: String, _ value: String?) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .font(.body)

            Spacer()

            Text(value?.isEmpty == false ? value! : "—")
                .foregroundColor(.primary)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}
