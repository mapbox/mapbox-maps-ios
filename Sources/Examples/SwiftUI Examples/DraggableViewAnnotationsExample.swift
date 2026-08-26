import SwiftUI
@_spi(Experimental) import MapboxMaps

// MARK: - Draggable View Annotations Example

/// Shows how to make view annotations draggable: bind a coordinate via
/// `MapViewAnnotation(coordinate:content:onDraggingChanged:)` and use the updated
/// coordinates to edit map geometry (a polygon or polyline) as the user drags.
///
/// SwiftUI analog for the UIKit ``DraggableViewAnnotationExample``.
struct DraggableViewAnnotationsExample: View {
    // View
    @State private var viewAnnotationCoordinate = DraggableViewAnnotationData.point
    @State private var isViewAnnotationDragging = false

    // Polygon
    @State private var polygonVertices = DraggableViewAnnotationData.polygon
    @State private var draggedPolygonVertexId: String?

    // Polyline
    @State private var polylineVertices = DraggableViewAnnotationData.polyline
    @State private var draggedPolylineVertexId: String?

    var body: some View {
        Map(initialViewport: .camera(DraggableViewAnnotationData.cameraOptions)) {
            viewAnnotationContent
            editPolygonContent
            editPolylineContent
        }
        .mapStyle(.outdoors)
        .ignoresSafeArea()
    }

    // MARK: View Annotation

    @MapContentBuilder
    private var viewAnnotationContent: some MapContent {
        MapViewAnnotation(coordinate: $viewAnnotationCoordinate) {
            CustomPinView(isDragging: isViewAnnotationDragging)
        } onDraggingChanged: { dragging in
            isViewAnnotationDragging = dragging
        }
        .allowOverlap(true)
        .variableAnchors([ViewAnnotationAnchorConfig(anchor: .bottom)])
    }

    // MARK: Edit Polygon

    @MapContentBuilder
    private var editPolygonContent: some MapContent {
        PolygonAnnotation(polygon: Polygon([closedRing(polygonVertices.map(\.coordinate))]))
            .fillColor(StyleColor(.systemGreen))
            .fillOpacity(0.4)

        ForEvery(polygonVertices) { vertex in
            MapViewAnnotation(coordinate: coordinateBinding(in: $polygonVertices, for: vertex.id)) {
                CustomCircleView(isDragging: draggedPolygonVertexId == vertex.id, color: Color(uiColor: .systemGreen))
            } onDraggingChanged: { dragging in
                draggedPolygonVertexId = dragging ? vertex.id : nil
            }
            .allowOverlap(true)
        }
    }

    // MARK: Edit Polyline

    @MapContentBuilder
    private var editPolylineContent: some MapContent {
        PolylineAnnotation(lineCoordinates: polylineVertices.map(\.coordinate))
            .lineColor(StyleColor(.systemIndigo))
            .lineWidth(4)

        ForEvery(polylineVertices) { vertex in
            MapViewAnnotation(coordinate: coordinateBinding(in: $polylineVertices, for: vertex.id)) {
                CustomCircleView(isDragging: draggedPolylineVertexId == vertex.id, color: Color(uiColor: .systemIndigo))
            } onDraggingChanged: { dragging in
                draggedPolylineVertexId = dragging ? vertex.id : nil
            }
            .allowOverlap(true)
        }
    }

    // MARK: Helpers

    private func coordinateBinding(
        in vertices: Binding<[DraggableViewAnnotationData.Vertex]>,
        for id: String
    ) -> Binding<CLLocationCoordinate2D> {
        Binding(
            get: { vertices.wrappedValue.first(where: { $0.id == id })?.coordinate ?? CLLocationCoordinate2D() },
            set: { newValue in
                if let index = vertices.wrappedValue.firstIndex(where: { $0.id == id }) {
                    vertices.wrappedValue[index].coordinate = newValue
                }
            }
        )
    }

    private func closedRing(_ coordinates: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        guard let first = coordinates.first else { return coordinates }
        return coordinates + [first]
    }
}

private extension Viewport {
    static func camera(_ options: CameraOptions) -> Viewport {
        .camera(
            center: options.center,
            anchor: options.anchor,
            zoom: options.zoom,
            bearing: options.bearing,
            pitch: options.pitch
        )
    }
}

// MARK: - Helper Views

private struct CustomPinView: View {
    let isDragging: Bool

    var body: some View {
        Image(uiImage: UIImage(named: "dest-pin")!)
            .scaleEffect(isDragging ? 1.2 : 1.0)
            .animation(.interactiveSpring(), value: isDragging)
    }
}

private struct CustomCircleView: View {
    let isDragging: Bool
    let color: Color

    var body: some View {
        Circle()
            .fill(.white)
            .overlay(Circle().stroke(color, lineWidth: 2))
            .frame(
                width: isDragging ? 30 : 22,
                height: isDragging ? 30 : 22
            )
            .animation(.interactiveSpring(), value: isDragging)
            .frame(width: 44, height: 44)
    }
}
