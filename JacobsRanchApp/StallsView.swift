// StallsView.swift
// JacobsRanchApp
//

import SwiftUI

// MARK: — Model

class Stall: ObservableObject, Identifiable {
    let id: Int
    @Published var horseName        = "Buttercup"
    @Published var owners           = "Jane Doe"
    @Published var ownerContact     = "555-123-4567"
    @Published var emergencyContact = "555-987-6543"
    @Published var vetContact       = "555-246-8101"
    
    init(id: Int) { self.id = id }
}

// MARK: — ViewModel

class StallsViewModel: ObservableObject {
    @Published var stalls: [Stall] = (1...14).map { Stall(id: $0) }
    func stall(for id: Int) -> Stall { stalls.first { $0.id == id }! }
}

// MARK: — Views

struct StallsView: View {
    @StateObject private var vm = StallsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // Layout constants
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
          .background(Color(.systemGroupedBackground))
          
          GeometryReader { geo in
            let totalWidth = geo.size.width
            let cellWidth = (totalWidth
                             - horizontalPadding*2
                             - corridorWidth) / 2

            ScrollView {
              VStack(spacing: 0) {
                // Arena
                Text("Indoor Arena")
                  .font(.headline)
                  .frame(width: totalWidth - horizontalPadding*2, height: 100)
                  .background(
                    RoundedRectangle(cornerRadius: 8)
                      .fill(Color.white)
                      .overlay(
                        RoundedRectangle(cornerRadius: 8)
                          .stroke(Color.black, lineWidth: 1)
                      )
                  )
                  .padding(.top, 20)

                // First row
                HStack(spacing: 0) {
                  LeftColumn(ids: Array(1...4),
                             cellWidth: cellWidth,
                             cellHeight: cellHeight,
                             vm: vm)
                  Spacer().frame(width: corridorWidth)
                  RightColumn(ids: [14,13,12,11],
                              cellWidth: cellWidth,
                              cellHeight: cellHeight,
                              vm: vm)
                }
                .padding(.horizontal, horizontalPadding)

                Spacer().frame(height: interRowGap)

                // Second row
                HStack(spacing: 0) {
                  LeftColumn(ids: Array(5...7),
                             cellWidth: cellWidth,
                             cellHeight: cellHeight,
                             vm: vm)
                  Spacer().frame(width: corridorWidth)
                  RightColumn(ids: [10,9,8],
                              cellWidth: cellWidth,
                              cellHeight: cellHeight,
                              vm: vm)
                }
                .padding(.horizontal, horizontalPadding)

                Spacer(minLength: 40)
              }
              .background(Color(.systemGroupedBackground))
            }
          }
        }
        .navigationBarHidden(true)
    }
}

// Break the two columns into small reusable views:

private struct LeftColumn: View {
  let ids: [Int]
  let cellWidth: CGFloat
  let cellHeight: CGFloat
  @ObservedObject var vm: StallsViewModel

  var body: some View {
    VStack(spacing: 0) {
      ForEach(ids, id: \.self) { i in
        NavigationLink {
          StallDetailView(stall: vm.stall(for: i))
        } label: {
          StallCell(label: "Stall \(i)")
        }
        .frame(width: cellWidth, height: cellHeight)
      }
    }
  }
}

private struct RightColumn: View {
  let ids: [Int]
  let cellWidth: CGFloat
  let cellHeight: CGFloat
  @ObservedObject var vm: StallsViewModel

  var body: some View {
    VStack(spacing: 0) {
      ForEach(ids, id: \.self) { i in
        NavigationLink {
          StallDetailView(stall: vm.stall(for: i))
        } label: {
          StallCell(label: "Stall \(i)")
        }
        .frame(width: cellWidth, height: cellHeight)
      }
    }
  }
}

private struct StallCell: View {
  let label: String
  var body: some View {
    Text(label)
      .foregroundColor(Color("DarkBlue"))
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(
        RoundedRectangle(cornerRadius: 4)
          .fill(Color.white)
          .overlay(
            RoundedRectangle(cornerRadius: 4)
              .stroke(Color.black, lineWidth: 1)
          )
      )
  }
}

// MARK: — StallDetailView

struct StallDetailView: View {
  @ObservedObject var stall: Stall
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    Form {
      Section(header: Text("Stall \(stall.id)")) {
        ReadOnlyRow(label: "Horse Name",       value: stall.horseName)
        ReadOnlyRow(label: "Owners",           value: stall.owners)
        ReadOnlyRow(label: "Owner Contact",    value: stall.ownerContact)
        ReadOnlyRow(label: "Emergency Contact",value: stall.emergencyContact)
        ReadOnlyRow(label: "Vet Contact",      value: stall.vetContact)
      }
      Section {
        Button("Done") { dismiss() }
          .frame(maxWidth: .infinity, alignment: .center)
          .foregroundColor(.white)
          .padding()
          .background(RoundedRectangle(cornerRadius: 8)
                        .fill(Color("DarkBlue")))
          .listRowBackground(Color.clear)
          .listRowSeparator(.hidden)
      }
    }
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button { dismiss() } label: {
          Image(systemName: "chevron.left")
            .font(.title3)
            .foregroundColor(Color("DarkBlue"))
        }
      }
    }
  }
}

private struct ReadOnlyRow: View {
  let label: String, value: String
  var body: some View {
    HStack {
      Text(label).foregroundColor(.secondary)
      Spacer()
      Text(value.isEmpty ? "—" : value)
    }
  }
}

struct StallsView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      StallsView()
    }
  }
}
