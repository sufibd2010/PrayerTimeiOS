//
//  AppIntent.swift
//  SalahTimes
//
//  Created by Md. Abu Sufian Sufi on 11/17/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Prayer Times Configuration" }
    static var description: IntentDescription { "Configure your prayer times widget." }

    @Parameter(title: "Calculation Method", default: "Karachi")
    var calculationMethod: String
    
    @Parameter(title: "Location", default: "Auto")
    var location: String
}
