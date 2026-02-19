import SwiftUI

/// Displays a simple map Marker at the specified coordinate.
///
/// `Marker` is a convenience struct which creates a simple `MapViewAnnotation` with limited customization options.
/// Use `Marker` to quickly add a pin annotation at the specific coordinates when using SwiftUI.
/// If you need greater customization use `MapViewAnnotation` directly.
///
/// ```swift
/// Map {
///   Marker(coordinate: CLLocationCoordinate2D(...))
///     .text("My marker")
///     .color(.blue)
///     .stroke(.purple)
///     .innerColor(.white)
///     .animation(.wiggle, when: .appear)
///     .onTapGesture {
///         print("Marker tapped!")
///     }
/// }
/// ```
///
/// - Note: `Marker`s are great for displaying unique interactive features. However, they may be suboptimal for large amounts of data and don't support clustering.
/// Each marker creates a SwiftUI view, so for scenarios with 100+ markers, consider using ``PointAnnotation``.
/// Additionally, `Marker`s appear above all content of MapView (e.g. layers, annotations, puck). If you need to display annotation between layers or below a puck, use ``PointAnnotation``.
@_documentation(visibility: public)
@_spi(Experimental)
public struct Marker {

    /// The geographic location of the Marker
    var coordinate: CLLocationCoordinate2D

    /// The optional text the Marker will display
    var text: String?

    /// The color of the outerImage
    var outerColor = Color(red: 207/255, green: 218/255, blue: 247/255, opacity: 1.0)

    /// The color of the innerImage
    var innerColor = Color(red: 1, green: 1, blue: 1, opacity: 1.0)

    /// The color of optional strokes
    var strokeColor: Color? = Color(red: 58/255, green: 89/255, blue: 250/255, opacity: 1.0)

    /// Animation effects keyed by trigger. Wrapped in AlwaysEqual to prevent unnecessary reconciliation.
    var animations: AlwaysEqual<[MarkerAnimationTrigger: [MarkerAnimationEffect.Effect]]>?

    /// The tap action to perform when marker is tapped
    var tapAction: (() -> Void)?

    /// Set text for the Marker
    public func text(_ text: String?) -> Self {
        with(self, setter(\.text, text))
    }

    /// Set a color for the Marker
    public func color(_ color: Color) -> Self {
        with(self, setter(\.outerColor, color))
    }

    /// Set a color for the Marker's inner circle
    public func innerColor(_ color: Color) -> Self {
        with(self, setter(\.innerColor, color))
    }

    /// Set a color for the Marker's strokes. Set nil to remove the strokes.
    public func stroke(_ color: Color?) -> Self {
        with(self, setter(\.strokeColor, color))
    }

    /// Set a tap action for the Marker
    public func onTapGesture(perform action: @escaping () -> Void) -> Self {
        with(self, setter(\.tapAction, action))
    }

    /// Applies animation effects to the marker
    public func animation(_ effects: MarkerAnimationEffect..., when trigger: MarkerAnimationTrigger) -> Self {
        with(self) { marker in
            var copy = marker
            var animationsDict = copy.animations?.value ?? [:]
            animationsDict[trigger] = effects.map { $0.value }
            copy.animations = AlwaysEqual(value: animationsDict)
            return copy
        }
    }

    /// Build a `MapViewAnnotation` with the current Marker properties
    private var mapViewAnnotation: MapViewAnnotation {
        let appearAnimation = animations?.value[.appear]
        let disappearAnimation = animations?.value[.disappear]

        let markerView = MarkerView(
            text: text,
            outerColor: outerColor,
            innerColor: innerColor,
            strokeColor: strokeColor,
            appearAnimation: appearAnimation,
            tapAction: tapAction
        )

        var annotation = MapViewAnnotation(coordinate: coordinate) {
            markerView
        }
        .allowOverlap(true)
        .allowHitTesting(tapAction != nil)
        .variableAnchors([ViewAnnotationAnchorConfig(anchor: .top, offsetY: 40)])

        if let disappearAnimation = disappearAnimation {
            annotation.disappearEffects = disappearAnimation
        }

        return annotation
    }

    /// Create a marker at the specific coordinate
    public init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

extension Marker: MapContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedViewAnnotation(mapViewAnnotation: mapViewAnnotation))
    }
}

/// The SwiftUI View that renders the marker's visual content.
///
/// `MarkerView` contains both the animated pin and the static text label.
struct MarkerView: View {
    let text: String?
    let outerColor: Color
    let innerColor: Color
    let strokeColor: Color?
    let appearAnimation: [MarkerAnimationEffect.Effect]?
    let tapAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 4) {
            // Animated pin component
            AnimatableMarkerPin(
                outerColor: outerColor,
                innerColor: innerColor,
                strokeColor: strokeColor,
                appearEffects: appearAnimation,
                tapAction: tapAction
            )

            // Static text (no animation applied)
            ZStack(alignment: .top) {
                if let text {
                    markerText(text)
                }
            }
            .frame(minWidth: 120, minHeight: 60, alignment: .top)
            .allowsHitTesting(text != nil)
        }
    }

    @ViewBuilder
    private func markerText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15))
            .fontWeight(.medium)
            .foregroundColor(.black)
            .lineLimit(3)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 120)
            .fixedSize(horizontal: false, vertical: true)
            .shadow(color: .white, radius: 0, x: -1, y: -1)
            .shadow(color: .white, radius: 0, x: 1, y: -1)
            .shadow(color: .white, radius: 0, x: -1, y: 1)
            .shadow(color: .white, radius: 0, x: 1, y: 1)
    }
}

/// View that animates the marker pin independently from the text.
struct AnimatableMarkerPin: View {
    let outerColor: Color
    let innerColor: Color
    let strokeColor: Color?
    let appearEffects: [MarkerAnimationEffect.Effect]?
    let tapAction: (() -> Void)?

    @State private var scale: Double = 1.0
    @State private var opacity: Double = 1.0
    @State private var rotationAngle: Double = 0.0
    @State private var wiggleTask: Task<Void, Never>?

    var body: some View {
        markerImageStack
            .scaleEffect(scale, anchor: .bottom)
            .rotationEffect(.degrees(rotationAngle), anchor: .bottom)
            .opacity(opacity)
            .onAppear {
                handleAppear()
            }
            .onDisappear {
                wiggleTask?.cancel()
            }
            .onTapGesture {
                tapAction?()
            }
    }

    @ViewBuilder
    private var markerImageStack: some View {
        let outerImage = Image("default_marker_outer", bundle: .mapboxMaps)
        let innerImage = Image("default_marker_inner", bundle: .mapboxMaps)
        let outerStroke = Image("default_marker_outer_stroke", bundle: .mapboxMaps)
        let innerStroke = Image("default_marker_inner_stroke", bundle: .mapboxMaps)

        ZStack {
            applyColor(outerImage, color: outerColor)
                .frame(width: 32, height: 40)
                .shadow(color: .black.opacity(0.17), radius: 1, x: 0, y: 2)
                .shadow(color: .black.opacity(0.15), radius: 0.5, x: 0, y: 0)
            if let strokeColor {
                applyColor(outerStroke, color: strokeColor)
            }
            applyColor(innerImage, color: innerColor)
                .frame(width: 32, height: 40)
            if let strokeColor {
                applyColor(innerStroke, color: strokeColor)
            }
        }
    }

    private func handleAppear() {
        guard let effects = appearEffects else { return }

        // Set initial state without animation
        withAnimation(nil) {
            setInitialValues(for: effects)
        }

        // Animate after yielding to ensure initial state is rendered
        Task { @MainActor in
            await Task.yield()
            animateEffects(effects, isAppear: true)
        }
    }

    private func animateEffects(_ effects: [MarkerAnimationEffect.Effect], isAppear: Bool = false) {
        let hasWiggle = effects.contains { if case .wiggle = $0 { return true }; return false }

        if hasWiggle {
            animateWiggle()
        }

        for effect in effects {
            switch effect {
            case .scale(_, let to):
                withAnimation(.spring(response: 1.1, dampingFraction: 0.6)) {
                    self.scale = to
                }
            case .fade(_, let to):
                // Appear: Slower, gentle fade-in. Tap: Quick fade for responsiveness
                let fadeDuration = isAppear ? 1.2 : 0.5
                withAnimation(.easeInOut(duration: fadeDuration)) {
                    self.opacity = to
                }
            case .wiggle:
                break
            }
        }
    }

    private func animateWiggle() {
        // Cancel any in-flight wiggle animation
        wiggleTask?.cancel()

        let wiggleSequence = MarkerWiggleSequence()

        // Set initial state without animation
        withAnimation(nil) {
            rotationAngle = wiggleSequence.initialAngle
        }

        // Animate through keyframes using structured approach
        wiggleTask = Task { @MainActor in
            for keyframe in wiggleSequence.keyframes {
                // Check for cancellation before each keyframe
                if Task.isCancelled { return }

                // Wait for the specified duration before this keyframe
                if keyframe.duration > 0 {
                    try? await Task.sleep(nanoseconds: UInt64(keyframe.duration * 1_000_000_000))
                }

                // Check for cancellation after sleep
                if Task.isCancelled { return }

                // Apply animation with spring parameters
                withAnimation(.spring(response: keyframe.response, dampingFraction: keyframe.dampingFraction)) {
                    rotationAngle = keyframe.angle
                }
            }

            // Clear task reference when complete
            wiggleTask = nil
        }
    }

    /// Sets the initial "from" values for animation effects
    private func setInitialValues(for effects: [MarkerAnimationEffect.Effect]) {
        for effect in effects {
            switch effect {
            case .wiggle: break  // Initial rotation set in animateWiggle
            case .scale(let from, _): scale = from
            case .fade(let from, _): opacity = from
            }
        }
    }

    /// Apply color using foregroundStyle (iOS 15+) or foregroundColor (iOS 14-)
    @ViewBuilder
    private func applyColor(_ image: Image, color: Color) -> some View {
        if #available(iOS 15.0, *) {
            image.foregroundStyle(color)
        } else {
            image.foregroundColor(color)
        }
    }
}
