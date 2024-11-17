import SwiftUI
import Foundation

struct CircularProgressView: View {
    let progress: Double
    let nextPrayer: String
    let remainingTime: String
    let lineWidth: CGFloat = 6
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .trim(from: progress, to: 1)
                .stroke(
                    Color.gray.opacity(0.15),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color(red: 0.2, green: 0.5, blue: 0.4),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
            // Text content
            VStack(spacing: 2) {
                Text(nextPrayer)
                    .font(.system(size: 14, weight: .medium))
                Text("Remaining Time")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                Text(remainingTime)
                    .font(.system(size: 13, weight: .medium))
                    .monospacedDigit()
            }
        }
    }
}