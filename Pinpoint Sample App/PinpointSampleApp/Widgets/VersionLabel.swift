//
//  VersionLabel.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 01.10.25.
//

import SwiftUI
import Foundation

struct VersionLabel: View {
    var body: some View {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
           
            Text("v\(BuildInfo.tag) (\(BuildInfo.commit)) • \(version) (\(build))")
                .font(.footnote)
                .foregroundColor(.secondary)
        } else {
            Text("Version unavailable")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}
