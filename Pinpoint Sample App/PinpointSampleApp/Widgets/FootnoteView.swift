//
//  FootnoteView.swift
//  PinpointSampleApp
//
//  Created by Christoph Scherbeck on 24.09.25.
//


import SwiftUI

struct FootnoteView: View {
    let text: String
    let icon: String?
    
    init(_ text: String, icon: String? = "info.circle") {
        self.text = text
        self.icon = icon
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .frame(width: 12, height: 12)
            }
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
        )
    }
}
