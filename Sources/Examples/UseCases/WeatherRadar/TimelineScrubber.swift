import SwiftUI

struct TimelineScrubber: View {
    let itemCount: Int
    @Binding var currentIndex: Int
    let onInteractionStart: () -> Void
    @State private var dragLocation: CGPoint = .zero

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Track background
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(.quaternary)
                    .frame(height: 4)

                // Progress indicator
                HStack(spacing: 0) {
                    let padding: CGFloat = 16
                    let availableWidth = geometry.size.width - (padding * 2)
                    let progressWidth = currentIndex == itemCount - 1 ?
                        geometry.size.width :
                        padding + (availableWidth * CGFloat(currentIndex) / CGFloat(itemCount - 1))

                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(.primary)
                        .frame(width: progressWidth)
                    Spacer(minLength: 0)
                }
                .frame(height: 4)

                // Layer markers
                ForEach(0..<itemCount, id: \.self) { index in
                    let padding: CGFloat = 16
                    let availableWidth = geometry.size.width - (padding * 2)
                    let xPosition = padding + (availableWidth * CGFloat(index) / CGFloat(itemCount - 1))

                    Circle()
                        .fill(index == currentIndex ? Color.primary.opacity(0.7) :
                                index < currentIndex ? Color.primary.opacity(1) : Color.secondary.opacity(0.6))
                        .frame(width: index == currentIndex ? 12 : 8, height: index == currentIndex ? 12 : 8)
                        .position(x: xPosition, y: geometry.size.height / 2)
                        .animation(.easeInOut(duration: 0.2), value: currentIndex)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        onInteractionStart()
                        let padding: CGFloat = 16
                        let availableWidth = geometry.size.width - (padding * 2)
                        let adjustedX = max(0, min(availableWidth, value.location.x - padding))
                        let normalizedX = adjustedX / availableWidth
                        let newLayer = min(itemCount - 1, Int(normalizedX * CGFloat(itemCount)))
                        if newLayer != currentIndex {
                            currentIndex = newLayer
                            // Haptic feedback on layer change
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    }
            )
        }
    }
}

extension Color {
    func safeMix(with color: Color, by fraction: Double) -> Color {
        if #available(iOS 18.0, *) {
            return self.mix(with: color, by: fraction)
        }

        return self
    }
}
