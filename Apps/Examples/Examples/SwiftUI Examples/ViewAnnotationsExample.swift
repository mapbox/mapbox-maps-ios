import SwiftUI
import Turf
@_spi(Experimental) import MapboxMaps

extension Point: Identifiable {
    public var id: String { "\(coordinates)" }
}

@available(iOS 14.0, *)
struct ViewAnnotationsExample: View {
    @State var points: [Point] = []
    @State var allowOverlap: Bool = false
    @State var anchor: ViewAnnotationAnchor = .bottom

    var body: some View {
        MapReader { proxy in
            Map(initialViewport: .camera(center: .helsinki, zoom: 5)) {
                let citiesCoordinates = [CLLocationCoordinate2D.helsinki, .berlin]
                CircleAnnotationGroup(citiesCoordinates, id: \.latitude) { coordinate in
                    CircleAnnotation(centerCoordinate: coordinate)
                        .circleColor(StyleColor(.red))
                        .circleRadius(9)
                }

                ForEvery(points) { point in
                    ViewAnnotation(
                        point.coordinates,
                        allowOverlap: allowOverlap,
                        anchor: anchor
                    ) {
                        ViewAnnotationContent(point: point) {
                            points.removeAll(where: { $0 == point })
                        }
                    }
                }
            }
            .mapStyle(.streets)
            .onMapTapGesture { context in
                points.append(Point(context.coordinate))
            }
            .ignoresSafeArea(edges: [.leading, .trailing, .bottom])
            .safeOverlay(alignment: .bottom) {
                VStack(spacing: 10) {
                    Toggle("Allow overlap", isOn: $allowOverlap)
                    HStack {
                        Text("Anchor")
                        Spacer()
                        Picker("Anchor", selection: $anchor) {
                            Text("Bottom").tag(ViewAnnotationAnchor.bottom)
                            Text("Center").tag(ViewAnnotationAnchor.center)
                            Text("Top").tag(ViewAnnotationAnchor.top)
                            Text("Left").tag(ViewAnnotationAnchor.left)
                            Text("Right").tag(ViewAnnotationAnchor.right)
                        }.pickerStyle(.segmented)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .floating(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 30)
            }
        }
    }
}

@available(iOS 14.0, *)
private struct ViewAnnotationContent: View {
    var point: Point
    var onRemove: () -> Void

    @State var appeared = false

    var body: some View {
        let latlon = String(format: "%.2f, %.2f", point.coordinates.latitude, point.coordinates.longitude)
        HStack(alignment: .firstTextBaseline) {
            Text("(\(latlon))")
                .font(.safeMonospaced)
            Image(systemName: "clear.fill")
                .onTapGesture(perform: onRemove)
        }
        .padding(5)
        .background(Color.random)
        .foregroundColor(.white)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.2)
        .animation(.spring(), value: appeared)
        .onAppear {
            appeared = true
        }
    }
}

@available(iOS 14.0, *)
struct ViewAnnotationsExample_Previews: PreviewProvider {
    static var previews: some View {
        ViewAnnotationsExample()
    }
}
