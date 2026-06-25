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

    // Published Variables
    @Published private(set) var api: PinpointAPI?
    @Published var localPosition: LocalPosition?
    @Published var connectionState: ConnectionState = .DISCONNECTED
    @Published var initializationError: String? = nil
    
    // Private vars
    private let widgets = WidgetManager()
    private var connectedTracelet: CBPeripheral?
    private var locationManager:CLLocationManager
    
   
    init() {
        self.locationManager = CLLocationManager()
    }
    
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
    // Request permissions according Swift docs: https://developer.apple.com/documentation/nearbyinteraction/dl-tdoa-ranging
    
    func startPositionStream(siteID:UInt32, blob:Data, forceTracelet:Bool) async  {
        locationManager.requestWhenInUseAuthorization()
        let authStatus = locationManager.authorizationStatus
        guard authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways else {
            print("Location authorization required for DL-TDOA.")
            return
        }
        guard let api = self.api else { return }
        await api.startPositionStream(siteId: siteID, forceTracelet:forceTracelet, blob: blob)
        widgets.startLiveActivity(position: localPosition)
        

    }
    
    
    
    // Lights up the LED on connected TRACElets for identification
    
    func showMe() async -> Bool {
        guard let api = self.api else {
            return false
        }
            let success = await api.showMe()
            return success
    }
    
    // Stops the Position Stream
    func stopPositionStream() async {
        widgets.endLiveActivity()
        await api?.stopPositionStream()
            
    }
    
    private func handleNewPosition(_ position: LocalPosition?) {
        DispatchQueue.main.async {
            if let p = position {
                self.localPosition = p
                self.widgets.updateLiveActivityScore(position: p)
            }
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
            print("new state \(state)")
            self.connectionState = state
        }
    }
    
    func pinpointAPI(_ api: PinpointSDKFramework.PinpointAPI, didChangeLicenseState expiry: Date) {
        print("License expires on: \(expiry.formatted())")
    }
    
}
