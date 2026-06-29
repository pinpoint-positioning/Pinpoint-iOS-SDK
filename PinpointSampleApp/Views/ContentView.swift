//
//  ContentView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 24.09.25.
//

import SwiftUI
import UniformTypeIdentifiers


struct ContentView: View {
    @ObservedObject var positionProvider = PositionProvider()
    @State var showFilePicker = false
    @State var showConfigSheet = false
    @State var siteIdInput: String = ""
    @State var selectedBlobData: Data? = nil
    @State var selectedFileName: String? = nil
    @State var showNoBlobAlert = false
    @State var showLicenseErrorAlert = false
    @State var forceTracelet: Bool = false

    private var hasLicenseError: Bool {
        positionProvider.initializationError != nil
    }

    // Local Positions to display
    private var localX: String {
        if let x = positionProvider.localPosition?.x { return String(format: "%.2f", x) }
        return "n/a"
    }

    private var localY: String {
        if let y = positionProvider.localPosition?.y { return String(format: "%.2f", y) }
        return "n/a"
    }


    private var localAcc: String {
        if let acc = positionProvider.localPosition?.accuracy { return String(format: "%.2f", acc) }
        return "n/a"
    }

    // World Coordinates to display
    private var wgs84Lat: String {
        if let lat = positionProvider.localPosition?.lat { return "\(lat)" }
        return "n/a"
    }
    private var wgs84Lon: String {
        if let lon = positionProvider.localPosition?.lon { return "\(lon)" }
        return "n/a"
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                // ── Header
                HStack(spacing: 10) {
                    Image("pinpoint-circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                    
                    Text("PinpointSDK Demo")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // License status pill
                    if hasLicenseError {
                        Label("No License", systemImage: "lock.fill")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color.red))
                    }
                }
                .padding(.top, 20)
                
                // ── Coordinates Card
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text("Local Position")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Spacer()
                        Circle()
                            .fill(isPositioning() ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .fill(isPositioning() ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                            )
                    }
                    
                    HStack(spacing: 20) {
                        CoordinateView(label: "X", value: localX, color: .red)
                        CoordinateView(label: "Y", value: localY, color: .green)
                    }
                    
                    HStack {
                        Image(systemName: "scope")
                            .foregroundColor(.orange)
                            .font(.system(size: 16, weight: .medium))
                        Text("Accuracy: ± \(localAcc) m")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .opacity(hasLicenseError ? 0.4 : 1)
                .allowsHitTesting(!hasLicenseError)
                
                // ── WGS84 Coordinates Card
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "globe")
                        Text("WGS84 Coordinates")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Spacer()
                        
                    }
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Latitude:")
                                .font(.subheadline).fontWeight(.medium).foregroundColor(.secondary)
                                .frame(width: 80, alignment: .leading)
                            Text(wgs84Lat)
                                .font(.subheadline).fontWeight(.semibold).foregroundColor(.primary)
                            Spacer()
                        }
                        HStack {
                            Text("Longitude:")
                                .font(.subheadline).fontWeight(.medium).foregroundColor(.secondary)
                                .frame(width: 80, alignment: .leading)
                            Text(wgs84Lon)
                                .font(.subheadline).fontWeight(.semibold).foregroundColor(.primary)
                            Spacer()
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .opacity(hasLicenseError ? 0.4 : 1)
                .allowsHitTesting(!hasLicenseError)
                
                // ── Buttons Section
                VStack(spacing: 16) {

                    VStack {
                        Toggle("Force TRACElet", isOn: $forceTracelet)
                            .font(.headline)

                        Text("Use a TRACElet connection via BLE, even when native UWB support is available on the iPhone")
                            .font(.caption)
                    }
                    .padding()
                    .background(.gray.opacity(0.2))
                    .cornerRadius(8)

                    Button(action: {
                        if isPositioning() {
                            Task { await stopPositionStream() }
                        } else {
                            showConfigSheet = true
                        }
                    }) {
                        HStack {
                            if isConnecting() {
                                ProgressView()
                            } else {
                                Image(systemName: isPositioning() ? "stop.fill" : "location.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(isPositioning() ? "Disconnect" : "Start Positioning")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(
                                    colors: isPositioning()
                                        ? [Color.red.opacity(0.8), Color.red]
                                        : [Color.blue.opacity(0.8), Color.blue]
                                ),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(
                            color: (isPositioning() ? Color.red : Color.blue).opacity(0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                    }
                    .disabled(isConnecting() || hasLicenseError)
                    .opacity(hasLicenseError ? 0.4 : 1)

                    if isPositioning() && forceTracelet {
                        Button(action: {
                            Task { await positionProvider.showMe() }
                        }) {
                            HStack {
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Show Me")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.orange.opacity(0.8), Color.orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(hasLicenseError)
                        .opacity(hasLicenseError ? 0.4 : 1)
                    }
                }
                .opacity(hasLicenseError ? 0.4 : 1)

                Spacer()
                VersionLabel()
            }
            .padding(.horizontal, 24)
        }
        .task {
            await positionProvider.setup()
        }
        .onChange(of: positionProvider.initializationError) { _, error in
            if error != nil {
                showLicenseErrorAlert = true
            }
        }

        .sheet(isPresented: $showConfigSheet) {
            ConfigurationSheet(
                siteIdInput: $siteIdInput,
                selectedBlobData: $selectedBlobData,
                selectedFileName: $selectedFileName,
                showFilePicker: $showFilePicker,
                isPresented: $showConfigSheet
            ) {
                Task { await startPositionStream() }
            }
        }

        .alert("Blob Required", isPresented: $showNoBlobAlert) {
            Button("Select File") { showFilePicker = true }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please select a .bin site blob file before connecting.")
        }
        .alert("License Error", isPresented: $showLicenseErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(positionProvider.initializationError ?? "Unknown error")
        }
    }

    // MARK: - Actions


    func stopPositionStream() async {
        await positionProvider.stopPositionStream()
    }

    func startPositionStream() async {
        guard let siteId = UInt32(siteIdInput, radix: 16) else { return }
        guard let blob = selectedBlobData else {
            showNoBlobAlert = true
            return
        }

        await positionProvider.startPositionStream(siteID: siteId, blob: blob, forceTracelet:forceTracelet)

    }

    func isPositioning() -> Bool {
        return positionProvider.connectionState == .POSITIONING
    }
    
    
    func isConnecting() -> Bool {
        return positionProvider.connectionState == .CONNECTING
    }
}


// MARK: - Configuration Sheet

struct ConfigurationSheet: View {
    @Binding var siteIdInput: String
    @Binding var selectedBlobData: Data?
    @Binding var selectedFileName: String?
    @Binding var showFilePicker: Bool
    @Binding var isPresented: Bool
    let onStart: () -> Void

    private var canStart: Bool {
        !siteIdInput.isEmpty && UInt32(siteIdInput, radix: 16) != nil && selectedBlobData != nil
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Site ID (hex)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)

                        HStack(spacing: 8) {
                            Text("0x")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                                .fontWeight(.semibold)

                            TextField("0000", text: $siteIdInput)
                                .font(.system(.body, design: .monospaced))
                                .keyboardType(.asciiCapable)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.characters)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    siteIdInput.isEmpty || UInt32(siteIdInput, radix: 16) != nil
                                        ? Color.clear
                                        : Color.red.opacity(0.5),
                                    lineWidth: 1
                                )
                        )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Site Blob (.bin)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)

                        Button {
                            showFilePicker = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: selectedBlobData != nil ? "doc.fill" : "doc.badge.plus")
                                    .foregroundColor(selectedBlobData != nil ? .blue : .secondary)

                                Text(selectedFileName ?? "Select .bin file…")
                                    .font(.subheadline)
                                    .foregroundColor(selectedBlobData != nil ? .primary : .secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)

                                Spacer()

                                if selectedBlobData != nil {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()
                    // Start Positioning Button
                    Button {
                        isPresented = false
                        onStart()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text( "Start Positioning")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .blue.opacity(0.85)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(!canStart)
                    .opacity(canStart ? 1 : 0.5)
                }
                .padding(24)
            }
            .navigationTitle("Configuration")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [UTType(filenameExtension: "bin") ?? .data],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                guard url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }

                do {
                    selectedBlobData = try Data(contentsOf: url)
                    selectedFileName = url.lastPathComponent
                } catch {
                    print("Failed reading file: \(error)")
                }

            case .failure(let error):
                print("File picker error: \(error)")
            }
        }
    }
}


// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
        ContentView()
            .preferredColorScheme(.dark)
    }
}
