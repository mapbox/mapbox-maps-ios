import UIKit
import MapboxMaps

/// Initial geometry shared by the UIKit ``DraggableViewAnnotationExample``
/// and SwiftUI ``DraggableViewAnnotationsExample``.
enum DraggableViewAnnotationData {
    struct Vertex: Identifiable, Equatable {
        let id: String
        var coordinate: CLLocationCoordinate2D
    }

    /// Initial camera framing all the annotations.
    static let cameraOptions = CameraOptions(
        center: CLLocationCoordinate2D(latitude: 47.409798800000004, longitude: 10.988386700000035),
        zoom: 12.283,
        bearing: 355.938
    )

    /// Standalone draggable pin.
    static let point = CLLocationCoordinate2D(latitude: 47.42106057168621, longitude: 10.98631883452245)

    /// Vertices of the editable polygon.
    static let polygon: [Vertex] = [
        .init(id: "top", coordinate: CLLocationCoordinate2D(latitude: 47.395938254568335, longitude: 10.98813208900475)),
        .init(id: "bottomRight", coordinate: CLLocationCoordinate2D(latitude: 47.40125517429638, longitude: 11.008414122492837)),
        .init(id: "bottomLeft", coordinate: CLLocationCoordinate2D(latitude: 47.40086930423814, longitude: 10.970155003200773)),
    ]

    /// Vertices of the editable polyline.
    static let polyline: [Vertex] = [
        .init(id: "start", coordinate: CLLocationCoordinate2D(latitude: 47.410496910404845, longitude: 10.974784668681195)),
        .init(id: "end", coordinate: CLLocationCoordinate2D(latitude: 47.40650006265324, longitude: 11.004886147140041)),
    ]
}
