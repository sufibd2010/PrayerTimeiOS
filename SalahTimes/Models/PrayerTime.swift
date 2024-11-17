import Foundation
import WidgetKit

struct PrayerTime: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let time: Date
    var isNextPrayer: Bool = false
    
    var iconName: String {
        switch name {
        case "Fajr": return "sunrise.fill"
        case "Dhuhr": return "sun.max.fill"
        case "Asr": return "sun.min.fill"
        case "Maghrib": return "sunset.fill"
        case "Isha": return "moon.stars.fill"
        default: return "clock.fill"
        }
    }
}

struct SalahTimesEntry: TimelineEntry {
    let date: Date
    let prayerTimes: [PrayerTime]
    let location: String?
    let error: String?
} 