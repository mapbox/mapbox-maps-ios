import Foundation

struct LocationChange: Equatable {
    var location: Location
    var heading: Heading?

    init?(locations: [Location]? = nil, heading: Heading? = nil) {
        guard let location = locations?.last else { return nil }
        self.location = location
        self.heading = heading
    }
}
