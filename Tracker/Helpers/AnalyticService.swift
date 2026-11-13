//
//  AnalyticService.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 07.11.2026.
//

import AppMetricaCore
import Foundation
import Logging

enum AnalyticsEvent: String {
    case open, close, click
}

enum AnalyticsScreen: String {
    case main = "Main"
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track, filter, edit, delete
}

struct AnalyticsService {

    private static let logger = Logger(label: "Tracker.AnalyticsService")

    static func activate() {
        guard
            let apiKey = Bundle.main.object(
                forInfoDictionaryKey: "AppMetricaAPIKey"
            ) as? String,
            !apiKey.isEmpty,
            let configuration = AppMetricaConfiguration(apiKey: apiKey)
        else {
            logger.error("AppMetrica API key is missing or invalid")
            return
        }

        AppMetrica.activate(with: configuration)
    }

    static func report(
        event: AnalyticsEvent,
        screen: AnalyticsScreen,
        item: AnalyticsItem? = nil
    ) {

        var params: [AnyHashable: Any] = [
            "screen": screen.rawValue
        ]

        if let item {
            params["item"] = item.rawValue
        }

        logger.debug(
            "Reporting analytics event",
            metadata: [
                "event": "\(event.rawValue)",
                "parameters": "\(params)",
            ]
        )
        AppMetrica.reportEvent(
            name: event.rawValue,
            parameters: params,
            onFailure: { error in
                Self.logger.error(
                    "Analytics reporting failed",
                    metadata: [
                        "error": "\(error.localizedDescription)"
                    ]
                )
            }
        )
    }
}
