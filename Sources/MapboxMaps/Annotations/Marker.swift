import SwiftUI

/// Displays a simple map Marker at the specified coordinated.
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
/// }
/// ```
///
/// - Note: `Marker`s  are great for displaying unique interactive features. However, they may be suboptimal for large amounts of data and don't support clustering.
/// Each marker creates a SwiftUI view, so for scenarios with 100+ markers, consider using ``PointAnnotation``,
/// Additionally, `Marker`s appear above all content of MapView (e.g. layers, annotations, puck). If you need to display annotation between layers or below a puck, use ``PointAnnotation``.
@_spi(Experimental)
public struct Marker {

    /// The `MapViewAnnotation` which will be displayed on the map
    var mapViewAnnotation: MapViewAnnotation {
        build()
    }

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

    /// The outer image of the Marker
    private let outerImage = Image("default_marker_outer", bundle: .mapboxMaps)

    /// The inner image of the Marker
    private let innerImage = Image("default_marker_inner", bundle: .mapboxMaps)

    /// The outer stroke of the Marker
    private let outerStroke = Image("default_marker_outer_stroke", bundle: .mapboxMaps)

    /// The inner stroke of the Marker
    private let innerStroke = Image("default_marker_inner_stroke", bundle: .mapboxMaps)

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

    /// Build a `MapViewAnnotation` with the current Marker properties
    private func build() -> MapViewAnnotation {
        MapViewAnnotation(coordinate: coordinate) {
            ZStack(alignment: .top) {
                markerImage
                if let text {
                    markerText(text)
                }
            }
        }
        .allowOverlap(true)
    }

    /// Returns the compiled Marker image
    @ViewBuilder
    private var markerImage: some View {
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
        .offset(y: -20) // Center marker on coordinate (half of 40pt height)
    }

    /// Returns the Marker text
    @ViewBuilder
    private func markerText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15))
            .fontWeight(.medium)
            .foregroundColor(.black)
            .lineLimit(3)
            .frame(width: 200)
            .multilineTextAlignment(.center)
            .offset(y: 24) // Position text below marker (20pt + 4pt spacing)
            .shadow(color: .white, radius: 0, x: -1, y: -1)
            .shadow(color: .white, radius: 0, x: 1, y: -1)
            .shadow(color: .white, radius: 0, x: -1, y: 1)
            .shadow(color: .white, radius: 0, x: 1, y: 1)
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
