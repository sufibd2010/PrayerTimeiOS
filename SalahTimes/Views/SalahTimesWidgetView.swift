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
        HStack(spacing: 12) {
            // Left side with circular progress
            VStack(spacing: 4) {
                if let prayer = nextPrayer {
                    Text(prayer.name)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Remaining Time")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    if let time = timeRemaining {
                        Text(String(format: "%02d:%02d:%02d", time.hours, time.minutes, time.seconds))
                            .font(.system(size: 14, weight: .medium))
                            .monospacedDigit()
                    }
                    
                    CircularProgressView(progress: progress)
                        .frame(width: 60, height: 60)
                }
            }
            .frame(maxWidth: 100)
            
            // Right side with prayer times list
            VStack(alignment: .leading, spacing: 4) {
                ForEach(entry.prayerTimes) { prayer in
                    HStack {
                        Text(prayer.name)
                            .font(.system(size: 12))
                            .foregroundColor(prayer.isNextPrayer ? .primary : .gray)
                            .frame(width: 50, alignment: .leading)
                        
                        Text(formatTime(prayer.time))
                            .font(.system(size: 12))
                            .foregroundColor(prayer.isNextPrayer ? .primary : .gray)
                    }
                    .padding(.vertical, 1)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(prayer.isNextPrayer ? Color.green.opacity(0.2) : Color.clear)
                            .padding(.horizontal, -4)
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
        VStack(spacing: 5) {
            Text("Remaining Time")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.top, 8)
            
            if let time = timeRemaining {
                Text(String(format: "%02d:%02d:%02d", time.hours, time.minutes, time.seconds))
                    .font(.system(size: 18, weight: .medium))
                    .monospacedDigit()
            }
            
            Spacer()
            
            ZStack {
                CircularProgressView(progress: progress)
                    .frame(width: 100, height: 100)
            }
            
            Spacer()
        }
        .padding(10)
    }
} 
