//
//  IdentifyHorseView.swift
//  JacobsRanchApp
//

import SwiftUI

struct IdentifyHorseView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var showCamera = false
    @State private var showPhotoPicker = false

    @State private var selectedImage: UIImage?
    @State private var prediction: String?
    @State private var confidence: Double = 0
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color("LightBackground")
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // CUSTOM BACK BUTTON
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

                // HEADER
                VStack(spacing: 6) {
                    Text("Horse Identification")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("DarkBlue"))

                    Text("Take or upload a photo to identify a horse")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)

                // IMAGE PREVIEW
                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 6)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 260, height: 260)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color("DarkBlue"))
                        )
                        .padding(.top, 20)
                }


                // ACTION BUTTONS
                VStack(spacing: 12) {

                    Button {
                        showCamera = true
                    } label: {
                        Text("Take Photo")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("DarkBlue"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button {
                        showPhotoPicker = true
                    } label: {
                        Text("Choose from Library")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("DarkBlue").opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    if isLoading {
                        ProgressView("Identifying...")
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 24)

                // RESULT CARD
                if let prediction {
                    VStack(spacing: 8) {
                        Text("Prediction")
                            .font(.headline)
                            .foregroundColor(Color("DarkBlue"))

                        Text(prediction)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Confidence: \(String(format: "%.2f", confidence))")
                            .foregroundColor(.gray)

                        Text(confidenceMessage(confidence))
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .foregroundColor(confidenceColor(confidence))
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(radius: 4)
                    .padding(.top, 24)
                }

                Spacer()
            }
        }
        .navigationBarHidden(true)

        // CAMERA
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
        }

        // PHOTO LIBRARY
        .sheet(isPresented: $showPhotoPicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
        }

        // AUTO IDENTIFY WHEN IMAGE CHANGES
        .onChange(of: selectedImage) { _ in
            if selectedImage != nil {
                identifyHorse()
            }
        }
    }

    // API CALL
    private func identifyHorse() {
        guard let image = selectedImage else { return }

        isLoading = true
        prediction = nil

        let url = URL(string: "http://127.0.0.1:8000/identify")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        let imageData = image.jpegData(compressionQuality: 0.8)!

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let result = try? JSONDecoder().decode(IdentifyResponse.self, from: data) else {
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }

            DispatchQueue.main.async {
                prediction = result.prediction
                confidence = result.confidence
                isLoading = false
            }
        }
        .resume()
    }

    // CONFIDENCE EXPLANATION
    private func confidenceMessage(_ score: Double) -> String {
        switch score {
        case 0.93...1.0:
            return "Near perfect match: extremely high confidence"
        case 0.88..<0.93:
            return "Very strong confidence"
        case 0.75..<0.88:
            return "Likely match"
        default:
            return "Low confidence: unable to reliably identify"
        }
    }

    private func confidenceColor(_ score: Double) -> Color {
        switch score {
        case 0.93...1.0:
            return .green
        case 0.88..<0.93:
            return .green
        case 0.75..<0.88:
            return .orange
        default:
            return .red
        }
    }
}

// API RESPONSE MODEL
struct IdentifyResponse: Codable {
    let prediction: String
    let confidence: Double
}
