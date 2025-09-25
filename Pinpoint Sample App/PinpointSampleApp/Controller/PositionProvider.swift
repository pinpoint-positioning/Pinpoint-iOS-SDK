//
//  PositionProvider.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 24.09.25.
//

import Foundation
import EasylocateSDK
import SwiftUI
import CoreBluetooth

class PositionProvider: ObservableObject {
    let api = EasylocateAPI.shared
    private var connectedTracelet: CBPeripheral?
    @Published var localPostion: LocalPosition?
    @Published var connectionState: ConnectionState = .DISCONNECTED
    
    
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
    
    func connectTraceletAndStart() async throws -> Bool {
        let devices = try await withCheckedThrowingContinuation { continuation in
            var hasResumed = false
            api.scan(timeout: 3.0) { devices in
                guard !hasResumed else { return }
                hasResumed = true
                continuation.resume(returning: devices)
            }
        }
        
        guard let tracelet = devices.first else { return false }
        
        let success = try await connectToTraceletAndStartPositioning(tracelet)
        if success {
            connectedTracelet = tracelet.peripheral
        }
        return success
    }

    
   private func connectToTraceletAndStartPositioning(_ tracelet: DiscoveredTracelet) async throws -> Bool {
        let success = try await api.connectAndStartPositioning(device: tracelet.peripheral)
        return success
    }
    
    
    func showMe() async -> Bool {
        if let tracelet = connectedTracelet {
            let success = await api.showMe(tracelet: tracelet)
            return success
        } else {
            return false
        }
    }
    
    func disconnect() {
        Task {
            await api.disconnect()
        }
    }
    
    private func handleNewPosition(_ position: LocalPosition?) {
        localPostion = position
    }
    
    
    func getConnectionState() -> ConnectionState {
        return api.connectionState
    }
  
}
