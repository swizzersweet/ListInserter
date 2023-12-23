import SwiftUI

struct PromotionalView: View {
    private let text: String
    private let colors: (Color, Color)
    
    init(text: String = "Promotional View", colors: (Color, Color) = (.blue, .orange)) {
        (self.text, self.colors) = (text, colors)
    }
    
    var body: some View {
        Text(text)
            .padding()
            .foregroundColor(.white)
            .font(.largeTitle)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [colors.0, colors.1]),
                    startPoint: .top,
                    endPoint: .bottom)
            )
    }
}
