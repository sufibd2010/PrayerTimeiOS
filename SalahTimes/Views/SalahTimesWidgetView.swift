import SwiftUI

struct MediumWidgetView: View {
    let entry: SalahTimesEntry
    
    var nextPrayer: PrayerTime? {
        entry.prayerTimes.first { $0.isNextPrayer }
    }
    
    var timeRemaining: (hours: Int, minutes: Int, seconds: Int)? {
        guard let prayer = nextPrayer else { return nil }
        let difference = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: prayer.time)
        return (
            hours: difference.hour ?? 0,
            minutes: difference.minute ?? 0,
            seconds: difference.second ?? 0
        )
    }
    
    var progress: Double {
        guard let prayer = nextPrayer else { return 0 }
        let totalSeconds = Calendar.current.dateComponents([.second], from: Date(), to: prayer.time).second ?? 0
        let maxSeconds = 5 * 60 * 60 // 5 hours as max time difference
        return Double(totalSeconds) / Double(maxSeconds)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side with circular progress
            if let prayer = nextPrayer, let time = timeRemaining {
                CircularProgressView(
                    progress: progress,
                    nextPrayer: prayer.name,
                    remainingTime: String(format: "%02d:%02d:%02d", time.hours, time.minutes, time.seconds)
                )
                .frame(width: 105, height: 105)
            }
            
            // Right side with prayer times list
            VStack(alignment: .leading, spacing: 4) {
                ForEach(entry.prayerTimes) { prayer in
                    HStack {
                        Text(prayer.name)
                            .font(.system(size: 15))
                            .foregroundColor(prayer.isNextPrayer ? .primary : .gray)
                            .frame(width: 60, alignment: .leading)
                        
                        Text(formatTime(prayer.time))
                            .font(.system(size: 15))
                            .foregroundColor(prayer.isNextPrayer ? .primary : .gray)
                    }
                    .padding(.vertical, 1)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(prayer.isNextPrayer ? Color(red: 0.2, green: 0.5, blue: 0.4).opacity(0.2) : Color.clear)
                            .padding(.horizontal, -4)
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 8)
        }
        .padding(8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma"
        return formatter.string(from: date).lowercased()
    }
}


struct SmallWidgetView: View {
    let entry: SalahTimesEntry
    
    var nextPrayer: PrayerTime? {
        entry.prayerTimes.first { $0.isNextPrayer }
    }
    
    var timeRemaining: (hours: Int, minutes: Int, seconds: Int)? {
        guard let prayer = nextPrayer else { return nil }
        let difference = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: prayer.time)
        return (
            hours: difference.hour ?? 0,
            minutes: difference.minute ?? 0,
            seconds: difference.second ?? 0
        )
    }
    
    var progress: Double {
        guard let prayer = nextPrayer else { return 0 }
        let totalSeconds = Calendar.current.dateComponents([.second], from: Date(), to: prayer.time).second ?? 0
        let maxSeconds = 5 * 60 * 60 // 5 hours as max time difference
        return Double(totalSeconds) / Double(maxSeconds)
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .opacity(0.95)
            
            VStack(spacing: 8) {
                if let prayer = nextPrayer, let time = timeRemaining {
                    Text(prayer.name)
                        .font(.system(size: 28, weight: .bold))
                        .padding(.top, 20)
                    
                    Text("Remaining Time")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                    
                    Text(String(format: "%02d:%02d:%02d", time.hours, time.minutes, time.seconds))
                        .font(.system(size: 32, weight: .medium))
                        .monospacedDigit()
                        .padding(.top, 2)
                    
                    CircularProgressView(
                        progress: progress,
                        nextPrayer: prayer.name,
                        remainingTime: String(format: "%02d:%02d:%02d", time.hours, time.minutes, time.seconds)
                    )
                    .frame(width: 200, height: 200)
                    .padding(.top, 10)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
