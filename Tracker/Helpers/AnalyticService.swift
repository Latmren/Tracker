//
//  AnalyticService.swift
//  Tracker
//
//  Created by Dmitry Zherebyatnikov on 07.11.2026.
//

import AppMetricaCore
import Foundation

struct AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "859f2182-bbf0-4b95-b793-9b20d0d60f02") else { return }

        AppMetrica.activate(with: configuration)
    }

    func report(event: String, params : [AnyHashable : Any]) {
        print("Analytics:", event, params)
        
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: \(error.localizedDescription)")
        })
    }
}
