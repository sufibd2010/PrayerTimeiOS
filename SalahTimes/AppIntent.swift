//
//  AppIntent.swift
//  SalahTimes
//
//  Created by Md. Abu Sufian Sufi on 11/17/24.
//

import WidgetKit
import AppIntents

// Define enums for each dropdown
enum CalculationMethodOption: String, AppEnum {
    case karachi = "Karachi"
    case muslimWorldLeague = "Muslim World League"
    case egyptian = "Egyptian"
    case northAmerica = "North America"
    case kuwait = "Kuwait"
    case qatar = "Qatar"
    case singapore = "Singapore"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Calculation Method"
    static var caseDisplayRepresentations: [CalculationMethodOption: DisplayRepresentation] = [
        .karachi: "Karachi",
        .muslimWorldLeague: "Muslim World League",
        .egyptian: "Egyptian",
        .northAmerica: "North America",
        .kuwait: "Kuwait",
        .qatar: "Qatar",
        .singapore: "Singapore"
    ]
}

enum MadhabOption: String, AppEnum {
    case hanafi = "Hanafi"
    case shafi = "Shafi"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Madhab"
    static var caseDisplayRepresentations: [MadhabOption: DisplayRepresentation] = [
        .hanafi: "Hanafi",
        .shafi: "Shafi"
    ]
}

enum HighLatitudeRuleOption: String, AppEnum {
    case middleOfTheNight = "Middle of the Night"
    case seventhOfTheNight = "Seventh of the Night"
    case twilightAngle = "Twilight Angle"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "High Latitude Rule"
    static var caseDisplayRepresentations: [HighLatitudeRuleOption: DisplayRepresentation] = [
        .middleOfTheNight: "Middle of the Night",
        .seventhOfTheNight: "Seventh of the Night",
        .twilightAngle: "Twilight Angle"
    ]
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Prayer Times Configuration" }
    static var description: IntentDescription { "Configure your prayer times widget." }

    // Calculation Method
    @Parameter(title: "Calculation Method", default: .karachi)
    var calculationMethod: CalculationMethodOption
    
    // Madhab
    @Parameter(title: "Madhab", default: .hanafi)
    var madhab: MadhabOption
    
    // High Latitude Rule
    @Parameter(title: "High Latitude Rule", default: .middleOfTheNight)
    var highLatitudeRule: HighLatitudeRuleOption
    
    // Prayer Time Adjustments
    @Parameter(title: "Fajr Adjustment", default: 0)
    var fajrAdjustment: Int
    
    @Parameter(title: "Sunrise Adjustment", default: 0)
    var sunriseAdjustment: Int
    
    @Parameter(title: "Dhuhr Adjustment", default: 0)
    var dhuhrAdjustment: Int
    
    @Parameter(title: "Asr Adjustment", default: 0)
    var asrAdjustment: Int
    
    @Parameter(title: "Maghrib Adjustment", default: 0)
    var maghribAdjustment: Int
    
    @Parameter(title: "Isha Adjustment", default: 0)
    var ishaAdjustment: Int
    
    // Location
    @Parameter(title: "Location", default: "Auto")
    var location: String
}
