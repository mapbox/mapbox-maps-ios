@_spi(Experimental) import MapboxMaps
import SwiftUI

/// Shows collision box observing: marking, moving, hiding and removing marked subviews updates the
/// collision boxes of the annotation automatically. An active box is visible as a hole in the "✕"
/// grid, because the symbols under the box are not drawn.
///
/// The last switch adds a second annotation with a higher priority just below the red box.
/// Shifting the red box into it hides the pin, which is the only way in this example to trigger
/// collision-based hiding. The UIKit and Android examples use an avoid region for the same purpose;
/// SwiftUI has no public API for avoid regions, and two annotations colliding is the common case in
/// an application anyway.
///
/// Mirrors the UIKit ``ViewAnnotationCollisionObservingExample`` and the Android
/// `ViewAnnotationCollisionObservingActivity`, so the three can be compared side by side.
struct ViewAnnotationsCollisionObservingExample: View {
    @State private var markBlue = false
    @State private var removeRed = false
    @State private var swiftUIHiddenRed = false
    @State private var transparentRed = false
    @State private var shiftRed = false
    @State private var competitor = false

    var body: some View {
        Map(initialViewport: .camera(center: .newYork, zoom: CollisionObservingDemo.zoom)) {
            CollisionObservingDemo.styleContent

            MapViewAnnotation(coordinate: .newYork) {
                HStack(spacing: 30) {
                    if !removeRed {
                        circle(Color(.systemRed))
                            .mbxViewAnnotationCollisionBox(true)
                            .hidden(swiftUIHiddenRed)
                            .opacity(transparentRed ? 0 : 1)
                            .offset(y: shiftRed ? 20 : 0)
                    }
                    circle(Color(.systemBlue))
                        .mbxViewAnnotationCollisionBox(markBlue)
                }
                .padding(10)
            }
            .enableSymbolLayerCollision(true)

            if competitor {
                // A higher priority annotation is placed first, so the pin is the one that loses
                // when their collision boxes overlap.
                MapViewAnnotation(coordinate: .newYork) {
                    // Transparent on purpose: the UIKit and Android avoid region is invisible too.
                    Color.clear
                        .frame(width: 40, height: 30)
                }
                // Both annotations need this flag. Annotations that enable it are placed in a
                // separate pass with higher priority, so without it the two are never compared
                // with each other and the pin always wins.
                .enableSymbolLayerCollision(true)
                .priority(1)
                .variableAnchors([ViewAnnotationAnchorConfig(anchor: .center, offsetY: -Constants.competitorOffset)])
            }
        }
        .mapStyle(.empty)
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            VStack(alignment: .leading) {
                Toggle("Mark blue as collision box", isOn: $markBlue)
                Toggle("Shift red box down", isOn: $shiftRed)
                Toggle("Red box opacity 0 (still collides)", isOn: $transparentRed)
                Toggle("Remove red box (falls back to full bounds)", isOn: $removeRed)
                Toggle("Red box .hidden() (still collides)", isOn: $swiftUIHiddenRed)
                Toggle("Competing annotation below red box", isOn: $competitor)
            }
            // Same panel look as the UIKit and Android examples.
            .font(.system(size: 12))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    private enum Constants {
        /// Puts the competing annotation just below the red box, so the box only reaches it
        /// once it is shifted down.
        static let competitorOffset: CGFloat = 45
    }

    private func circle(_ color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 30, height: 30)
    }
}

private extension View {
    /// Toggleable `.hidden()`: the view stays in the hierarchy and keeps its layout.
    @ViewBuilder
    func hidden(_ isHidden: Bool) -> some View {
        if isHidden { hidden() } else { self }
    }
}

/// Shared between the SwiftUI and UIKit variants of the demo, so their behavior can be compared 1:1.
/// Lives here because this file is compiled for both iOS and visionOS, the UIKit example is iOS-only.
enum CollisionObservingDemo {
    static let zoom = 14.79

    @MapStyleContentBuilder
    static var styleContent: some MapStyleContent {
        BackgroundLayer(id: "bg")
            .backgroundColor(.white)
        GeoJSONSource(id: "grid")
            .data(.featureCollection(grid(around: .newYork)))
        SymbolLayer(id: "grid-symbols", source: "grid")
            .textField("✕")
            .textSize(14)
            .textColor(.darkGray)
    }

    private static func grid(around center: CLLocationCoordinate2D) -> FeatureCollection {
        var features: [Feature] = []
        for row in -20...20 {
            for column in -12...12 {
                let coordinate = CLLocationCoordinate2D(
                    latitude: center.latitude + Double(row) * 0.0004,
                    longitude: center.longitude + Double(column) * 0.0006)
                features.append(Feature(geometry: Point(coordinate)))
            }
        }
        return FeatureCollection(features: features)
    }
}
