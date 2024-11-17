import SwiftUI
import Foundation

struct CircularProgressView: View {
    let progress: Double
    let nextPrayer: String
    let remainingTime: String
    let lineWidth: CGFloat = 6 // Made thinner
    
    private func indicatorPosition(in geometry: GeometryProxy) -> CGPoint {
        let radius = min(geometry.size.width, geometry.size.height) / 2 - lineWidth/2
        let angle = 2 * Double.pi * progress - Double.pi / 2
        
        return CGPoint(
            x: geometry.size.width / 2 + radius * CGFloat(cos(angle)),
            y: geometry.size.height / 2 + radius * CGFloat(sin(angle))
        )
    }
    
    var body: some View {
        ZStack {
            // Background circle (grey for remaining time)
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
            
            // Progress circle (green for elapsed time)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color(red: 0.2, green: 0.5, blue: 0.4), // Darker green color
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
            // Indicator dot at the end of progress
            GeometryReader { geometry in
                Circle()
                    .fill(Color(red: 0.2, green: 0.5, blue: 0.4))
                    .frame(width: lineWidth * 1.5, height: lineWidth * 1.5)
                    .position(indicatorPosition(in: geometry))
            }
            
            // Center text
            VStack(spacing: 4) {
                Text(nextPrayer)
                    .font(.system(size: 20, weight: .semibold))
                
                Text("Remaining Time")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Text(remainingTime)
                    .font(.system(size: 16, weight: .medium))
                    .monospacedDigit()
            }
        }
    }
}