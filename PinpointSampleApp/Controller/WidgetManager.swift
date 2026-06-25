//
//  WidgetManager.swift
//  Pinpoint Positioning
//
//  Created by Christoph Scherbeck on 22.04.26.
//


import SwiftUI
import ActivityKit
import PinpointSDKFramework


class WidgetManager {
    
    init() {
        Task {
            await endAllActivities()
        }
    }

    func startLiveActivity(position: LocalPosition?) {
    Task {
            await endAllActivities()
        do {
            let activity = try Activity.request(
                attributes: PinpointWidgetAttributes(),
                content: .init(
                    state: .init(
                        x: position?.x ?? 0.0, y: position?.y ?? 0.0, acc: position?.accuracy ?? 0.0
                    ),
                    staleDate: nil
                ),
                pushType: nil,
            )
                
            print("Started:", activity.id)
           
        } catch {
            print("Error:", error)
        }
    }
}

func updateLiveActivityScore(position: LocalPosition) {
    Task {
        for activity in Activity<PinpointWidgetAttributes>.activities {
            await activity.update(
                .init(
                    state: .init(
                        x: position.x, y: position.y, acc: position.accuracy
                    ),
                    staleDate: Date().addingTimeInterval(30)
                )
            )
        }
    }
}

func endLiveActivity() {
    Task {
        let activities = Activity<PinpointWidgetAttributes>.activities
        for activity in activities {
            await activity.end(
                .init(
                    state: activity.content.state,
                    staleDate: nil
                ),
                dismissalPolicy: .immediate
            )
        }
    }
}
    
    
    func endAllActivities() async {
        // End all avitivites
        for activity in Activity<PinpointWidgetAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
