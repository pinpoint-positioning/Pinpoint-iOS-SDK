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

class PositionProvider: ObservableObject {
    let api = PinpointApi.shared
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
 
    
    // Set up listeners for state and position changes
    init() {
        setUpStateListener()
        setUpPositionListener()
    }
    
    
    func setUpPositionListener() {
        api.onPositionUpdate = { position in
            self.handleNewPosition(position)
        }
    }
    
    
    func setUpStateListener() {
        api.onStateChange = { state in
            self.connectionState = state
        }
    }
    
    
    // Scans and connects to a TRACElet and start the local position stream
    func connectTraceletAndStart() async throws -> Bool {
        guard isBleReady() else { return false}
        
        let devices = try await withCheckedThrowingContinuation { continuation in
            var hasResumed = false
            // The `scan()` function returns a sorted list by RSSI of Pinpoint TRACElets
            // Usually it is fine to connect to the first one in the list (the only one / closest one)
            api.scan(timeout: 3.0) { devices in
                guard !hasResumed else { return }
                hasResumed = true
                continuation.resume(returning: devices)
            }
        }
        
        guard let tracelet = devices.first else { return false }
        // Store connected Tracelet
        connectedTracelet = tracelet.peripheral
        
        let success = try await connectToTraceletAndStartPositioning(tracelet)
        return success
    }

    
   private func connectToTraceletAndStartPositioning(_ tracelet: DiscoveredTracelet) async throws -> Bool {
        let success = try await api.connectAndStartPositioning(device: tracelet.peripheral)
        return success
    }
    
    
    // Lights up the LED on connected TRACElets for identification
    func showMe() async -> Bool {
        if let tracelet = connectedTracelet {
            let success = await api.showMe(tracelet: tracelet)
            return success
        } else {
            return false
        }
    }
    
    // Disconnects the TRACElet
    func disconnect() {
        Task {
            await api.disconnect()
        }
    }
    
    private func handleNewPosition(_ position: LocalPosition?) {
        localPosition = position
        generateWorldPosition()
    }
    
    
    func getConnectionState() -> ConnectionState {
        return api.connectionState
    }
    
    func isBleReady() -> Bool {
        return api.bleState == .BT_OK
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
 
}
