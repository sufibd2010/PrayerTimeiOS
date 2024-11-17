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
        let coordinates = await getCoordinates()
        
        // Create entries for next 30 minutes with 5-minute intervals
        for minuteOffset in stride(from: 0, to: 30, by: 5) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            
            if let coordinates = coordinates {
                var params = CalculationMethod.karachi.params
                params.madhab = .hanafi
                params.highLatitudeRule = .middleOfTheNight
                
                // Create adjustments
                let adjustments = PrayerAdjustments(
                    fajr: 0,
                    sunrise: 0,
                    dhuhr: 0,
                    asr: 0,
                    maghrib: 0,
                    isha: 0
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
    
    private func getCoordinates() async -> Coordinates? {
        // First try to get saved coordinates from UserDefaults
        if let lat = userDefaults?.double(forKey: "latitude"),
           let lng = userDefaults?.double(forKey: "longitude") {
            return Coordinates(latitude: lat, longitude: lng)
        }
        
        // Fallback to default coordinates (Dhaka, Bangladesh)
        return Coordinates(latitude: 23.777176, longitude: 90.399452)
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
