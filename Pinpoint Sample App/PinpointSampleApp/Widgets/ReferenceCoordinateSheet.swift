//
//  ReferenceCoordinateSheet.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 30.09.25.
//

import Foundation
import SwiftUI

struct ReferenceCoordinateSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var azimuth: String = ""
    var onSave: (Double, Double, Double) -> Void
    
    private var isValid: Bool {
        guard let lat = Double(latitude),
              let lon = Double(longitude),
              let azi = Double(azimuth) else {
            return false
        }
        return lat >= -90 && lat <= 90 &&
               lon >= -180 && lon <= 180 &&
               azi >= 0 && azi <= 360
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Latitude")
                            .frame(width: 100, alignment: .leading)
                        TextField("e.g., 47.123456", text: $latitude)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Longitude")
                            .frame(width: 100, alignment: .leading)
                        TextField("e.g., 8.123456", text: $longitude)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Azimuth")
                            .frame(width: 100, alignment: .leading)
                        TextField("e.g., 90.0", text: $azimuth)
                            .keyboardType(.decimalPad)
                    }
                } header: {
                    Text("World Coordinate Reference")
                } footer: {
                    Text("Set the reference point for converting local coordinates to WGS84. Azimuth is in degrees (0-360).")
                }
            }
            .navigationTitle("Set Reference")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let lat = Double(latitude),
                           let lon = Double(longitude),
                           let azi = Double(azimuth) {
                            onSave(lat, lon, azi)
                        }
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}
