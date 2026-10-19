import SwiftUI
import CoreLocation

// MARK: - InteractivePinView

/// A pin that lifts while dragged, swings with the movement and bounces on drop.
struct InteractivePinView: View {
    /// Horizontal position of the pin on screen, drives the swing so it doesn't depend on zoom.
    let screenX: CGFloat
    let distance: CLLocationDistance
    let isDragging: Bool

    private let liftHeight: CGFloat = 24
    // Degrees of tilt per point moved in one update.
    private let tiltPerPoint = 2.0
    private let maxTilt = 30.0

    @State private var tilt = 0.0
    @State private var previousScreenX: CGFloat?
    @State private var tiltResetTask: Task<Void, Never>?
    @State private var dropCount = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            if dropCount > 0 {
                RippleView().id(dropCount)
            }

            VStack(spacing: 6) {
                DistanceBadge(distance: distance, isDragging: isDragging)

                // Crop the baked-in shadow so the pin tip sits exactly on the coordinate.
                Image(uiImage: UIImage(named: "dest-pin")!)
                    .frame(width: 40, height: 40, alignment: .top)
                    .clipped()
                    .rotationEffect(.degrees(tilt), anchor: .top)
            }
            .offset(y: isDragging ? -liftHeight : 0)
        }
        .frame(width: 120, height: 120, alignment: .bottom)
        .animation(
            isDragging ? .spring(response: 0.25, dampingFraction: 0.7) : .spring(response: 0.35, dampingFraction: 0.45),
            value: isDragging
        )
        .onChange(of: isDragging) { dragging in
            previousScreenX = nil
            if !dragging {
                dropCount += 1
            }
        }
        .onChange(of: screenX) { x in
            updateTilt(screenX: x)
        }
    }

    private func updateTilt(screenX: CGFloat) {
        defer { previousScreenX = screenX }
        guard isDragging, let previousScreenX else { return }

        let target = min(max(Double(screenX - previousScreenX) * tiltPerPoint, -maxTilt), maxTilt)
        withAnimation(.interactiveSpring()) { tilt = tilt * 0.5 + target * 0.5 }

        // Swing back to vertical once the finger stops moving.
        tiltResetTask?.cancel()
        tiltResetTask = Task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.3)) { tilt = 0 }
        }
    }
}

// MARK: - DistanceBadge

/// Capsule with the distance from the start point that turns red while the pin is dragged.
private struct DistanceBadge: View {
    let distance: CLLocationDistance
    let isDragging: Bool

    private var text: String {
        switch distance {
        case ..<1: return "Drag me"
        case ..<1000: return "\(Int(distance)) m"
        default: return String(format: "%.1f km", distance / 1000)
        }
    }

    var body: some View {
        Text(text)
            .font(.system(.footnote, design: .rounded).weight(.semibold).monospacedDigit())
            .contentTransition(.numericText())
            .foregroundStyle(isDragging ? Color.white : Color.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isDragging ? AnyShapeStyle(Color(.systemRed)) : AnyShapeStyle(.regularMaterial), in: Capsule())
            .shadow(color: .black.opacity(0.2), radius: isDragging ? 6 : 2, y: isDragging ? 4 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: text)
    }
}

// MARK: - RippleView

/// Expanding ring on the ground that plays once when the pin lands.
private struct RippleView: View {
    @State private var isExpanded = false

    var body: some View {
        Ellipse()
            .stroke(Color(.systemRed), lineWidth: 2)
            .frame(width: 24, height: 8)
            .scaleEffect(isExpanded ? 4 : 0.5)
            .opacity(isExpanded ? 0 : 0.8)
            .onAppear {
                withAnimation(.easeOut(duration: 0.7)) { isExpanded = true }
            }
    }
}

// MARK: - Previews

#Preview("Pin") {
    HStack {
        InteractivePinView(screenX: 0, distance: 0, isDragging: false)
        InteractivePinView(screenX: 0, distance: 1250, isDragging: true)
    }
}

#Preview("Distance Badge") {
    VStack(spacing: 8) {
        DistanceBadge(distance: 0, isDragging: false)
        DistanceBadge(distance: 350, isDragging: true)
        DistanceBadge(distance: 1250, isDragging: false)
    }
    .padding()
}

#Preview("Ripple") {
    RippleView()
}
