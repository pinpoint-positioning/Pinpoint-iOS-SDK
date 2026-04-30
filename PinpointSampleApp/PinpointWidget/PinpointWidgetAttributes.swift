//
//  PinpointWidgetAttributes.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 27.04.26.
//

import ActivityKit
import WidgetKit
import SwiftUI


struct PinpointWidgetAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var x: Double
        var y: Double
        var acc: Double
    }
}
