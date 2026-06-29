//
//  PinpointWidgetLiveActivity.swift
//  PinpointWidget
//
//  Created by Christoph Scherbeck on 27.04.26.
//

import ActivityKit
import WidgetKit
import SwiftUI


// MARK: - Widget Style

private enum WidgetStyle {
    static let accentColor = Color(red: 0.0, green: 0.75, blue: 1.0)
    static let accentSecondary = Color(red: 0.4, green: 0.9, blue: 0.6)
    static let bgDark = Color(red: 0.06, green: 0.08, blue: 0.12)
    static let bgCard = Color(white: 1.0, opacity: 0.06)
    static let labelFont: Font = .system(size: 10, weight: .semibold, design: .monospaced)
    static let valueFont: Font = .system(size: 15, weight: .bold, design: .monospaced)
    static let tinyFont:  Font = .system(size: 9,  weight: .medium, design: .monospaced)
}

// MARK: - Axis Row

private struct AxisRow: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(WidgetStyle.labelFont)
                .foregroundStyle(color)
                .frame(width: 20, alignment: .leading)

            Text(String(format: "%.2f", value))
                .font(WidgetStyle.valueFont)
                .foregroundStyle(.white)
                .monospacedDigit()
                .frame(minWidth: 52, alignment: .trailing)

        }
    }
}

// MARK: - Lock Screen / Banner (content view)

private struct LockScreenContentView: View {
    let x: Double
    let y: Double
    let acc:Double

    var body: some View {
        HStack(spacing: 16) {
                Image("pinpoint-circle")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(WidgetStyle.accentColor)
            

            VStack(alignment: .leading, spacing: 3) {
                Text("INDOOR POSITION")
                    .font(.system(size: 9, weight: .bold, design: .default))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.45))

                HStack(spacing: 6) {
                    AxisRow(label: "X", value: x, color: WidgetStyle.accentColor)
                    AxisRow(label: "Y", value: y, color: WidgetStyle.accentSecondary)
                    AxisRow(label: "Acc", value: acc, color: WidgetStyle.accentSecondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(WidgetStyle.bgDark)
    }
}

// MARK: - Dynamic Island — Expanded

private struct ExpandedContentView: View {
    let x: Double
    let y: Double
    private let axisData: [(String, Double, Color)] = []

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "location.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(WidgetStyle.accentColor)
                Text("INDOOR POSITION")
                    .font(.system(size: 10, weight: .bold, design: .default))
                    .tracking(1.1)
                    .foregroundStyle(.white.opacity(0.55))
                Spacer()
                LiveDot()
            }
            .padding(.bottom, 8)

            HStack(spacing: 0) {
                CoordBlock(label: "X", value: x, color: WidgetStyle.accentColor)
                divider
                CoordBlock(label: "Y", value: y, color: WidgetStyle.accentSecondary)

            }
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(WidgetStyle.bgCard)
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(width: 1)
            .padding(.vertical, 8)
    }
}

private struct CoordBlock: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundStyle(color)
            Text(String(format: "%.2f", value))
                .font(.system(size: 17, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .monospacedDigit()
            Text("m")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Dynamic Island — Compact

private struct CompactLeadingView: View {
    let x: Double
    let y: Double

    var body: some View {
        HStack(spacing: 3) {
            
            Image("pinpoint-circle")
                .resizable()
                .scaledToFit()
        }
        .padding(.leading, 4)
    }
}

private struct CompactTrailingView: View {
    let x: Double
    let y: Double

    var body: some View {
        HStack(spacing: 6) {
            
            Text("X:\(String(format: "%.1f", x))")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(WidgetStyle.accentColor)
                .monospacedDigit()
            Text("Y:\(String(format: "%.1f", y))")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(WidgetStyle.accentSecondary)
                .monospacedDigit()

        }
        .padding(.trailing, 4)
    }
}

private struct MinimalView: View {
    var body: some View {
            Image("pinpoint-circle")
                .resizable()
                .scaledToFit()
    }
}

// MARK: - Live Dot

private struct LiveDot: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(WidgetStyle.accentColor.opacity(0.3))
                .frame(width: 12, height: 12)
                .scaleEffect(pulse ? 1.6 : 1.0)
                .opacity(pulse ? 0 : 0.6)
            Circle()
                .fill(WidgetStyle.accentColor)
                .frame(width: 6, height: 6)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                pulse = true
            }
        }
    }
}

// MARK: - Widget Entry Point

struct PinpointWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PinpointWidgetAttributes.self) { context in

            LockScreenContentView(
                x: context.state.x,
                y: context.state.y,
                acc: context.state.acc
            )

        } dynamicIsland: { context in
            let x = context.state.x
            let y = context.state.y


            return DynamicIsland {

                DynamicIslandExpandedRegion(.center) {
                    ExpandedContentView(x: x, y: y)
                }
            } compactLeading: {
                CompactLeadingView(x: x, y: y)

            } compactTrailing: {
                CompactTrailingView(x: x, y: y)

            } minimal: {
                MinimalView()
            }
        }
    }
}

// MARK: - Previews

#Preview("Lock Screen", as: .content, using: PinpointWidgetAttributes()) {
    PinpointWidgetLiveActivity()
} contentStates: {
    PinpointWidgetAttributes.ContentState(x: 12.45, y: 7.83, acc: 1)
    PinpointWidgetAttributes.ContentState(x: 22.10, y: 14.56, acc: 1)
}

#Preview("Dynamic Island Expanded", as: .dynamicIsland(.expanded), using: PinpointWidgetAttributes()) {
    PinpointWidgetLiveActivity()
} contentStates: {
    PinpointWidgetAttributes.ContentState(x: 12.45, y: 7.83, acc: 1)
}

#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: PinpointWidgetAttributes()) {
    PinpointWidgetLiveActivity()
} contentStates: {
    PinpointWidgetAttributes.ContentState(x: 12.45, y: 7.83, acc: 1)
}

#Preview("Dynamic Island Minimal", as: .dynamicIsland(.minimal), using: PinpointWidgetAttributes()) {
    PinpointWidgetLiveActivity()
} contentStates: {
    PinpointWidgetAttributes.ContentState(x: 12.45, y: 7.83, acc: 1)
}
