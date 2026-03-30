//
//  PositionProvider.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 24.09.25.
//

import Foundation
import PinpointSDKFramework
import SwiftUI
import CoreBluetooth
import CoreLocation

class PositionProvider: ObservableObject, PinpointStateDelegate, PinpointPositionDelegate {

    
    @Published private(set) var api: PinpointAPI?
    private var connectedTracelet: CBPeripheral?
    
    // Published Variables
    @Published var localPosition: LocalPosition?
    @Published var worldPosition: CLLocationCoordinate2D?
    @Published var connectionState: ConnectionState = .DISCONNECTED
    @Published var initializationError: String? = nil
    
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
            self.api?.positionDelegate = self   // assign self as delegate
            self.api?.stateDelegate = self   // assign self as delegate
            print("SDK initialized successfully")
        } catch {
            self.api = nil
            self.initializationError = "License invalid or missing. Please check your API key."
            print("SDK initialization failed:", error)
        }
    }
    
    
    // Start the postion stream
    func startPositionStream(siteID:UInt32, blob:Data) async  {
        guard let api = self.api else { return }
            await api.startPositionStream(siteId: siteID, blob: blob)
    }
    
    
    
    // Lights up the LED on connected TRACElets for identification
    // Removed for native positioning example
    
//    func showMe() async -> Bool {
//        guard let api = self.api else {
//            return false
//        }
//            let success = await api.showMe()
//            return success
//    }
    
    // Stops the Position Stream
    func stopPositionStream() async {
            await api?.stopPositionStream()
    }
    
    private func handleNewPosition(_ position: LocalPosition?) {
        DispatchQueue.main.async {
            self.localPosition = position
            self.generateWorldPosition()
        }

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
    
    func pinpointAPI(_ api: PinpointAPI, didUpdatePosition position: LocalPosition) {
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
