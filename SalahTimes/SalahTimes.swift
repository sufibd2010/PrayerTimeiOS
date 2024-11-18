//
//  SalahTimes.swift
//  SalahTimes
//
//  Created by Md. Abu Sufian Sufi on 11/17/24.
//

import WidgetKit
import SwiftUI
import Adhan
import CoreLocation

class Provider: AppIntentTimelineProvider {
    typealias Entry = SalahTimesEntry
    typealias Configuration = ConfigurationAppIntent
    
    let locationManager = CLLocationManager()
    let userDefaults = UserDefaults(suiteName: "group.com.yourapp.prayertime")
    
    private var locationCache: [Coordinates: String] = [:]
    private var lastGeocodingRequest: Date?
    private var lastKnownLocation: String?
    
    func placeholder(in context: Context) -> Entry {
        SalahTimesEntry(
            date: Date(),
            prayerTimes: getMockPrayerTimes(),
            location: "Loading...",
            error: nil
        )
    }

    func snapshot(for configuration: Configuration, in context: Context) async -> Entry {
        SalahTimesEntry(
            date: Date(),
            prayerTimes: getMockPrayerTimes(),
            location: "Sample City",
            error: nil
        )
    }
    
    func timeline(for configuration: Configuration, in context: Context) async -> Timeline<Entry> {
        var entries: [Entry] = []
        let currentDate = Date()
        let coordinates = await getCoordinates(location: configuration.location)
        
        // Create entries for next 30 minutes with 5-minute intervals
        for minuteOffset in stride(from: 0, to: 30, by: 5) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            
            if let coordinates = coordinates {
                // Set calculation method based on configuration
                var params: CalculationParameters
                switch configuration.calculationMethod {
                    case .muslimWorldLeague:
                        params = CalculationMethod.muslimWorldLeague.params
                    case .egyptian:
                        params = CalculationMethod.egyptian.params
                    case .northAmerica:
                        params = CalculationMethod.northAmerica.params
                    case .kuwait:
                        params = CalculationMethod.kuwait.params
                    case .qatar:
                        params = CalculationMethod.qatar.params
                    case .singapore:
                        params = CalculationMethod.singapore.params
                    case .karachi:
                        params = CalculationMethod.karachi.params
                }
                
                // Set madhab
                params.madhab = configuration.madhab == .hanafi ? .hanafi : .shafi
                
                // Set high latitude rule
                switch configuration.highLatitudeRule {
                    case .seventhOfTheNight:
                        params.highLatitudeRule = .seventhOfTheNight
                    case .twilightAngle:
                        params.highLatitudeRule = .twilightAngle
                    case .middleOfTheNight:
                        params.highLatitudeRule = .middleOfTheNight
                }
                
                // Set prayer time adjustments
                let adjustments = PrayerAdjustments(
                    fajr: configuration.fajrAdjustment,
                    sunrise: configuration.sunriseAdjustment,
                    dhuhr: configuration.dhuhrAdjustment,
                    asr: configuration.asrAdjustment,
                    maghrib: configuration.maghribAdjustment,
                    isha: configuration.ishaAdjustment
                )
                params.adjustments = adjustments
                
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: entryDate)
                let prayerTimes = try? PrayerTimes(coordinates: coordinates.toAdhanCoordinates(), date: dateComponents, calculationParameters: params)
                
                let prayers = createPrayerTimesList(from: prayerTimes)
                entries.append(SalahTimesEntry(
                    date: entryDate,
                    prayerTimes: prayers,
                    location: await getLocationName(coordinates: coordinates),
                    error: nil
                ))
            } else {
                entries.append(SalahTimesEntry(
                    date: entryDate,
                    prayerTimes: [],
                    location: nil,
                    error: "Location unavailable"
                ))
            }
        }
        
        return Timeline(entries: entries, policy: .after(Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!))
    }
    
    private func getCoordinates(location: String) async -> Coordinates? {
        // If location is set to "Auto", use saved coordinates
        if location == "Auto" {
            if let lat = userDefaults?.double(forKey: "latitude"),
               let lng = userDefaults?.double(forKey: "longitude") {
                return Coordinates(latitude: lat, longitude: lng)
            }
            return Coordinates(latitude: 23.777176, longitude: 90.399452) // Default to Dhaka
        }
        
        // Otherwise, geocode the location string
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(location)
            if let location = placemarks.first?.location {
                return Coordinates(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
        } catch {
            print("Geocoding error: \(error)")
        }
        
        return nil
    }
    
    private func createPrayerTimesList(from prayerTimes: PrayerTimes?) -> [PrayerTime] {
        guard let times = prayerTimes else { return [] }
        
        let prayers: [(String, Date?)] = [
            ("Fajr", times.fajr),
            ("Sunrise", times.sunrise),
            ("Dhuhr", times.dhuhr),
            ("Asr", times.asr),
            ("Maghrib", times.maghrib),
            ("Isha", times.isha)
        ]
        
        let now = Date()
        var prayerTimesList = prayers.compactMap { name, time -> PrayerTime? in
            guard let time = time else { return nil }
            return PrayerTime(name: name, time: time)
        }
        
        // Mark next prayer
        if let nextPrayerIndex = prayerTimesList.firstIndex(where: { $0.time > now }) {
            prayerTimesList[nextPrayerIndex].isNextPrayer = true
        }
        
        return prayerTimesList
    }
    
    private func getMockPrayerTimes() -> [PrayerTime] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            PrayerTime(name: "Fajr", time: calendar.date(byAdding: .hour, value: -2, to: now)!),
            PrayerTime(name: "Dhuhr", time: calendar.date(byAdding: .hour, value: 2, to: now)!, isNextPrayer: true),
            PrayerTime(name: "Asr", time: calendar.date(byAdding: .hour, value: 5, to: now)!),
            PrayerTime(name: "Maghrib", time: calendar.date(byAdding: .hour, value: 8, to: now)!),
            PrayerTime(name: "Isha", time: calendar.date(byAdding: .hour, value: 10, to: now)!)
        ]
    }
    
    private func getLocationName(coordinates: Coordinates) async -> String {
        // First check if we have a cached name for these coordinates
        if let cachedName = locationCache[coordinates] {
            return cachedName
        }
        
        // Check if enough time has passed since last geocoding request
        let currentTime = Date()
        if let lastGeocodingTime = lastGeocodingRequest,
           currentTime.timeIntervalSince(lastGeocodingTime) < 60 { // Wait at least 60 seconds between requests
            return lastKnownLocation ?? "Unknown Location"
        }
        
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geocoder = CLGeocoder()
        
        do {
            lastGeocodingRequest = currentTime
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                let locationName = placemark.locality ?? "Unknown Location"
                // Cache the result
                locationCache[coordinates] = locationName
                lastKnownLocation = locationName
                return locationName
            }
        } catch {
            print("Geocoding error: \(error)")
        }
        return lastKnownLocation ?? "Unknown Location"
    }
}

struct SalahTimesWidgetEntryView: View {
    var entry: SalahTimesEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let error = entry.error {
            Text(error)
        } else {
            switch family {
            case .systemSmall:
                SmallWidgetView(entry: entry)
            case .systemMedium:
                MediumWidgetView(entry: entry)
            default:
                Text("Unsupported widget size")
            }
        }
    }
}

struct SalahTimes: Widget {
    private let kind: String = "SalahTimes"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            SalahTimesWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}



#Preview(as: .systemSmall) {
    SalahTimes()
} timeline: {
    SalahTimesEntry(
        date: .now,
        prayerTimes: [
            PrayerTime(name: "Fajr", time: Date(), isNextPrayer: true)
        ],
        location: "Sample City",
        error: nil
    )
}
