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
    
    private let defaults = UserDefaults(suiteName: UserDefaultsKeys.suiteName)
    
    // Add initializer to load values from UserDefaults
    init() {
        if let defaults = UserDefaults(suiteName: UserDefaultsKeys.suiteName) {
            // Load calculation method
            if let methodStr = defaults.string(forKey: UserDefaultsKeys.calculationMethod),
               let method = CalculationMethodOption(rawValue: methodStr) {
                calculationMethod = method
            }
            
            // Load madhab
            if let madhabStr = defaults.string(forKey: UserDefaultsKeys.madhab),
               let madhabOption = MadhabOption(rawValue: madhabStr) {
                madhab = madhabOption
            }
            
            // Load high latitude rule
            if let ruleStr = defaults.string(forKey: UserDefaultsKeys.highLatitudeRule),
               let rule = HighLatitudeRuleOption(rawValue: ruleStr) {
                highLatitudeRule = rule
            }
            
            // Load adjustments
            fajrAdjustment = defaults.integer(forKey: UserDefaultsKeys.fajrAdjustment)
            sunriseAdjustment = defaults.integer(forKey: UserDefaultsKeys.sunriseAdjustment)
            dhuhrAdjustment = defaults.integer(forKey: UserDefaultsKeys.dhuhrAdjustment)
            asrAdjustment = defaults.integer(forKey: UserDefaultsKeys.asrAdjustment)
            maghribAdjustment = defaults.integer(forKey: UserDefaultsKeys.maghribAdjustment)
            ishaAdjustment = defaults.integer(forKey: UserDefaultsKeys.ishaAdjustment)
            location = defaults.string(forKey: UserDefaultsKeys.location) ?? "Auto"
        }
    }
    
    // Add method to save values to UserDefaults
    func saveToUserDefaults() {
        guard let defaults = UserDefaults(suiteName: UserDefaultsKeys.suiteName) else { return }
        
        defaults.set(calculationMethod.rawValue, forKey: UserDefaultsKeys.calculationMethod)
        defaults.set(madhab.rawValue, forKey: UserDefaultsKeys.madhab)
        defaults.set(highLatitudeRule.rawValue, forKey: UserDefaultsKeys.highLatitudeRule)
        defaults.set(fajrAdjustment, forKey: UserDefaultsKeys.fajrAdjustment)
        defaults.set(sunriseAdjustment, forKey: UserDefaultsKeys.sunriseAdjustment)
        defaults.set(dhuhrAdjustment, forKey: UserDefaultsKeys.dhuhrAdjustment)
        defaults.set(asrAdjustment, forKey: UserDefaultsKeys.asrAdjustment)
        defaults.set(maghribAdjustment, forKey: UserDefaultsKeys.maghribAdjustment)
        defaults.set(ishaAdjustment, forKey: UserDefaultsKeys.ishaAdjustment)
        defaults.set(location, forKey: UserDefaultsKeys.location)
    }
    
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
