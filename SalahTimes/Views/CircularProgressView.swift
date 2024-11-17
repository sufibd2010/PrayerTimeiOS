import SwiftUI
import Foundation

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat = 6
    
    private func indicatorPosition(in geometry: GeometryProxy) -> CGPoint {
        let radius = min(geometry.size.width, geometry.size.height) / 2 - lineWidth
        let angle = 2 * Double.pi * progress - Double.pi / 2
        
        return CGPoint(
            x: geometry.size.width / 1.5 + radius * CGFloat(cos(angle)),
            y: geometry.size.height / 2.3 + radius * CGFloat(sin(angle))
        )
    }
    
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
                    Color.green.opacity(0.9),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
            
            GeometryReader { geometry in
                Circle()
                    .fill(Color.white)
                    .frame(width: lineWidth * 1.2, height: lineWidth * 1.2)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .position(indicatorPosition(in: geometry))
            }
        }
    }
} 