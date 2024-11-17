import SwiftUI

struct PrayerTimeRow: View {
    let prayer: PrayerTime
    
    var body: some View {
        HStack {
            Image(systemName: prayer.iconName)
                .foregroundColor(.accentColor)
            
            Text(prayer.name)
                .font(.system(.body, design: .rounded))
            
            Spacer()
            
            Text(prayer.time, style: .time)
                .font(.system(.body, design: .rounded))
            
            if prayer.isNextPrayer {
                Image(systemName: "bell.fill")
                    .foregroundColor(.accentColor)
                    .padding(.leading, 4)
            }
        }
        .padding(.vertical, 4)
    }
} 
