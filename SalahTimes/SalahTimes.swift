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

struct Provider: AppIntentTimelineProvider {
    typealias Entry = SalahTimesEntry
    typealias Configuration = ConfigurationAppIntent
    
    let locationManager = CLLocationManager()
    let userDefaults = UserDefaults(suiteName: "group.com.yourapp.prayertime")
    
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
        
        for hourOffset in 0..<24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: entryDate)
            
            if let coordinates = coordinates {
                let params = CalculationMethod.muslimWorldLeague.params
                let adhanCoordinates = coordinates.toAdhanCoordinates()
                let prayerTimes = try? PrayerTimes(coordinates: adhanCoordinates, date: dateComponents, calculationParameters: params)
                
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
        
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    private func getCoordinates() async -> Coordinates? {
        // First try to get saved coordinates from UserDefaults
        if let lat = userDefaults?.double(forKey: "latitude"),
           let lng = userDefaults?.double(forKey: "longitude") {
            return Coordinates(latitude: lat, longitude: lng)
        }
        
        // Fallback to default coordinates (Mecca)
        return Coordinates(latitude: 21.4225, longitude: 39.8262)
    }
    
    private func createPrayerTimesList(from prayerTimes: PrayerTimes?) -> [PrayerTime] {
        guard let times = prayerTimes else { return [] }
        
        let prayers: [(String, Date?)] = [
            ("Fajr", times.fajr),
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
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                return placemark.locality ?? "Unknown Location"
            }
        } catch {
            print("Geocoding error: \(error)")
        }
        return "Unknown Location"
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
