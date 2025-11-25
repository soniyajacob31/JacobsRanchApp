//
//  FormsView.swift
//  JacobsRanchApp
//

import SwiftUI
import QuickLook
import Supabase

struct FormsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.supabase) private var client: SupabaseClient
    @EnvironmentObject private var boardingInfo: BoardingInfo

    @State private var localPDFURL: URL?
    @State private var loading = true
    @State private var fileExists = false

    var body: some View {
        VStack(spacing: 0) {

            // Custom back button
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

            Text("Your Contract")
                .font(.title2)
                .bold()
                .padding(.top, 8)

            if loading {
                ProgressView().padding(.top, 40)
            }
            else if !fileExists {
                VStack(spacing: 12) {
                    Text("No forms available")
                        .font(.headline)

                    Text("Please contact the ranch if you need your contract uploaded.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
            }
            else if let pdfURL = localPDFURL {
                PDFViewer(url: pdfURL)
            }

            Spacer()
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await loadContract()
            }
        }
    }

    private func loadContract() async {
        guard !boardingInfo.userId.isEmpty else {
            loading = false
            fileExists = false
            return
        }

        // File is stored directly under the bucket
        let path = "\(boardingInfo.userId).pdf"

        do {
            let data = try await client.storage
                .from("contracts")
                .download(path: path)

            let tempURL = FileManager.default
                .temporaryDirectory
                .appendingPathComponent("\(boardingInfo.userId).pdf")

            try data.write(to: tempURL)

            DispatchQueue.main.async {
                self.localPDFURL = tempURL
                self.fileExists = true
                self.loading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.fileExists = false
                self.loading = false
            }
        }
    }
}

struct PDFViewer: View {
    let url: URL

    var body: some View {
        QLPreviewControllerWrapper(url: url)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct QLPreviewControllerWrapper: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL

        init(url: URL) { self.url = url }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as QLPreviewItem
        }
    }
}
