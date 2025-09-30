//
//  ContentView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 24.09.25.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var positionProvider = PositionProvider()
    @State var isConnecting = false
    @State var showReferenceSheet = false

    
    // Local Positions to display
    private var localX: String {
        if let x = positionProvider.localPosition?.x {
            return "\(x)"
        }
        return "n/a"
    }
    private var localY: String {
        if let y = positionProvider.localPosition?.y {
            return "\(y)"
        }
        return "n/a"
    }
    private var localZ: String {
        if let z = positionProvider.localPosition?.z {
            return "\(z)"
        }
        return "n/a"
    }
    private var localAcc: String {
        if let acc = positionProvider.localPosition?.accuracy {
            return String(format: "%.2f", acc)
        }
        return "n/a"
    }
    
    // World Coordinates to display
    private var wgs84Lat: String {
        if let lat = positionProvider.worldPosition?.latitude {
            return "\(lat)"
        }
        return "n/a"
    }
    private var wgs84Lon: String {
        if let lon = positionProvider.worldPosition?.longitude {
            return "\(lon)"
        }
        return "n/a"
    }
    
    
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Image("pinpoint-circle")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue.gradient)
                    
                    Text("Pinpoint Positioning Demo")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .padding(.top, 20)
                
                // Coordinates Card
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text("LocalPosition")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Circle()
                            .fill(isConnected() ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .fill(isConnected() ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                                    .scaleEffect(isConnected() ? 2.0 : 1.0)
                                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isConnected())
                            )
                    }
                    
                    // Coordinate Values
                    HStack(spacing: 20) {
                        CoordinateView(label: "X", value: localX, color: .red)
                        CoordinateView(label: "Y", value: localY, color: .green)
                        CoordinateView(label: "Z", value: localZ, color: .blue)
                    }
                    
                    // Accuracy
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
                
                // WGS84 Coordinates Card
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "globe")
                        Text("WGS84 Coordinates")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            showReferenceSheet = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    
                    // Coordinate Values
                    VStack(spacing: 12) {
                        HStack {
                            Text("Latitude:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .frame(width: 80, alignment: .leading)
                            
                            Text(wgs84Lat)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text("Longitude:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .frame(width: 80, alignment: .leading)
                            
                            Text(wgs84Lon)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
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
                
                // Buttons Section
                VStack(spacing: 16) {
                    // Connect/Disconnect Button
                    Button(action: {
                        if !isConnected() {
                            Task {
                                await connectToTracelet()
                            }
                        } else {
                            disconnect()
                        }
                    }) {
                        HStack {
                            if isConnecting {
                                ProgressView()
                            } else {
                                
                                Text(isConnected() ? "Disconnect" : "Connect")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: isConnected() ?
                                                   [Color.red.opacity(0.8), Color.red] :
                                                    [Color.blue.opacity(0.8), Color.blue]
                                                  ),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: (isConnected() ? Color.red : Color.blue).opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .scaleEffect(isConnected() ? 1.0 : 1.0)
                    .disabled(isConnecting)
                    
                    
                    
                    // Show Me Button
                    if isConnected() {
                        Button(action: {
                            Task {
                                await showMe()
                            }
                        }) {
                            HStack {
                                Image(systemName: "eye.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                
                                Text("Show Me")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.tertiary, lineWidth: 1)
                                    )
                            )
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    
                    FootnoteView("Hold a TRACElet close to your phone, when tapping on Connect", icon: "info.circle")
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
        }
        .sheet(isPresented: $showReferenceSheet) {
            ReferenceCoordinateSheet(
                onSave: setWorldCoordinateReference
            )
        }
        
    }
    
    func showMe() async {
        let success = await positionProvider.showMe()
        if success {
            print("ShowMe succeeded")
        }
    }
    
    func disconnect() {
        positionProvider.disconnect()
        
    }
    
    func connectToTracelet() async {
        isConnecting = true
        do {
            let _ = try await positionProvider.connectTraceletAndStart()
            isConnecting = false
        } catch {
            isConnecting = false
            print("Error connecting to Tracelet: \(error)")
        }
    }
    
    func isConnected () -> Bool {
        return positionProvider.connectionState == .CONNECTED
    }
    
    func setWorldCoordinateReference(lat: Double, lon: Double, azi: Double) {
        // Set World Coordinate Reference
        positionProvider.REF_AZI = azi
        positionProvider.REF_LAT = lat
        positionProvider.REF_LON = lon
        
        showReferenceSheet = false
    }
    
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
        
        ContentView()
            .preferredColorScheme(.dark)
    }
}
