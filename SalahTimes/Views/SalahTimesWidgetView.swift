import SwiftUI
import WidgetKit

struct SalahTimesWidgetView: View {
    let entry: SalahTimesEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let error = entry.error {
            ErrorView(message: error)
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

struct SmallWidgetView: View {
    let entry: SalahTimesEntry
    
    var nextPrayer: PrayerTime? {
        entry.prayerTimes.first { $0.isNextPrayer }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Next Prayer")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "gear")
                    .foregroundColor(.secondary)
            }
            
            if let prayer = nextPrayer {
                Spacer()
                HStack {
                    Image(systemName: prayer.iconName)
                        .font(.title)
                    VStack(alignment: .leading) {
                        Text(prayer.name)
                            .font(.headline)
                        Text(prayer.time, style: .time)
                            .font(.subheadline)
                    }
                }
                Spacer()
            }
            
            if let location = entry.location {
                Text(location)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct MediumWidgetView: View {
    let entry: SalahTimesEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Prayer Times")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                if let location = entry.location {
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Image(systemName: "gear")
                    .foregroundColor(.secondary)
            }
            
            ForEach(entry.prayerTimes) { prayer in
                PrayerTimeRow(prayer: prayer)
            }
        }
        .padding()
    }
} 
