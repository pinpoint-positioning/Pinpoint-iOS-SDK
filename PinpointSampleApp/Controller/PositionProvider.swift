//
//  PositionProvider.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 24.09.25.
//

import Foundation
import PinpointSDK
import SwiftUI
import CoreBluetooth
import CoreLocation

class PositionProvider: ObservableObject, PinpointAPIDelegate {

    
    @Published private(set) var api: PinpointAPI?
    private var connectedTracelet: CBPeripheral?
    @Published var connectionState: ConnectionState = .DISCONNECTED
    
    // Published Positions
    @Published var localPosition: LocalPosition?
    @Published var worldPosition: CLLocationCoordinate2D?
    
    // Example WGS84 references
    // Used for converting local coordinates to World Coordinates (WGS84)
    var REF_LAT:Double?
    var REF_LON:Double?
    var REF_AZI:Double?
    
        
    init() { }
    
    func setup() async {
        await initializeSDK()

    }
    

    @MainActor
    private func initializeSDK() async {
        do {
            let sdk = try await PinpointAPI(apiKey: "YOUR-API-KEY")
            self.api = sdk
            self.api?.delegate = self   // assign self as delegate
            print("SDK initialized successfully")
        } catch {
            self.api = nil
            print("SDK initialization failed:", error)
            
        }
    }
    
    
    // Start the TRACElet connection flow
    func startPositionStream() async  {
        guard let api = self.api else { return }
        do {
            try await api.startPositionStream()
        }
        catch {
            print(error)
        }
    }
    
    
    
    // Lights up the LED on connected TRACElets for identification
    func showMe() async -> Bool {
        guard let api = self.api else {
            return false
        }
            let success = await api.showMe()
            return success
    }
    
    // Disconnects the TRACElet
    func stopPositionStream() async {
            await api?.stopPositionStream()
    }
    
    private func handleNewPosition(_ position: LocalPosition?) {
        localPosition = position
        generateWorldPosition()
    }
    
    
    
    // Converts local positions to WGS84 Positions
    func generateWorldPosition() {
        if let localPos = self.localPosition,
           let lat = REF_LAT,
           let lon = REF_LON,
           let azi = REF_AZI {
            
            let uwbPosition = CGPoint(x: localPos.x, y: localPos.y)
            self.worldPosition = WGS84Position(refLatitude: lat, refLongitude: lon, refAzimuth: azi)
                .getWGS84Position(uwbPosition: uwbPosition)
        }
    }
    
    
    //MARK: - Delegate Implementation
    
    func pinpointAPI(_ api: PinpointSDK.PinpointAPI, didUpdatePosition position: PinpointSDK.LocalPosition) {
        self.handleNewPosition(position)
    }
    
    func pinpointAPI(_ api: PinpointAPI, didChangeBLEState state: BLEState) {
        print(state)
    }
    
    
    func pinpointAPI(_ api: PinpointAPI, didChangeConnectionState state: ConnectionState) {
        DispatchQueue.main.async {
            self.connectionState = state
        }
    }
    
}
