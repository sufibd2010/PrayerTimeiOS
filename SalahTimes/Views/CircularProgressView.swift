import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat = 6
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.gray.opacity(0.1),
                    lineWidth: lineWidth
                )
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.green.opacity(0.8),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
            // Progress indicator circle
            Circle()
                .fill(Color.green)
                .frame(width: lineWidth * 1.5)
                .offset(y: -(50))
                .rotationEffect(.degrees(360 * progress - 90))
        }
    }
} 