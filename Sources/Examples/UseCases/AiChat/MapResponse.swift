import CoreLocation
import MapboxMaps

struct Pin: Identifiable {
    var id = UUID()
    var location: CLLocationCoordinate2D
    var name: String
    var icon: String
    var rating: String?
    var details: String?
    var tags = [String]()
    var image: String?
    var isActive = false
}

struct MapResponse: Identifiable {
    var id = UUID()
    var pins: [Pin]
    var camera: CameraOptions?
}
