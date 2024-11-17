import SwiftUI

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.title)
            Text(message)
                .font(.caption)
        }
        .padding()
    }
} 