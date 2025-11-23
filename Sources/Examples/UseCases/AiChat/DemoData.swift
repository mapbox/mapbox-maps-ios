import CoreLocation
import MapboxMaps

struct Demo {
    var flow: [Message]
    
    static var dateNightRestaurants: Demo {
        Demo(flow: [
            Message(content: "Show me the best restaurants in San Francisco for a date tonight", isUser: true),
            Message(content: "Here are the bset places for a date tonight in San Franciso.", isUser: false, map: MapResponse(pins: .restaurants())),
            Message(content: "Which ones have vegan options?", isUser: true),
            Message(content: "Here are some great vegan-friendly options for a date night in San Francisco!", isUser: false, map: MapResponse(pins: .restaurants(onlyVegan: true))),
            Message(content: "Which ones also have a waterfront view?", isUser: true),
            Message(
                content: "The following vegan-friendly restaurant also has a beautiful waterfront view. A perfect setting for a date night!",
                isUser: false,
                map: MapResponse(
                    pins: .restaurants(best: true),
                    camera: CameraOptions(
                        center: CLLocationCoordinate2D(latitude:37.7954469, longitude: -122.393536),
                        zoom: 16.9,
                        bearing: -94,
                        pitch: 75
                    )
                ),
            ),
        ])
    }
}

struct Message: Identifiable {
    var id = UUID()
    var content: String
    var isUser: Bool
    var mapResponse: MapResponse?
    var lastMapResponse = false

    init(content: String, isUser: Bool, map: MapResponse? = nil) {
        self.content = content
        self.isUser = isUser
        self.mapResponse = map
    }
}


extension Array where Element == Pin {
    static func restaurants(onlyVegan: Bool = false, best: Bool = false) -> [Pin] {
        [
            Pin(
                location: CLLocationCoordinate2D(latitude: 37.7904917, longitude: -122.3890914),
                name: "Waterbar",
                icon: "fork.knife",
                rating: "4",
                details: "A seafood-focused restaurant with panoramic views of the San Francisco skyline, Treasure Island, and the Bay Bridge. 399...",
                tags: ["🌊 Waterfront"],
                image: "2"
            ),
            Pin(
                location: CLLocationCoordinate2D(latitude: 37.79499953, longitude: -122.39571908),
                name: "Harborview Restaurant & Bar",
                icon: "fork.knife",
                rating: "3.8",
                details: "Harborview Restaurant & Bar",
                tags: ["🌱 Vegan"],
                image: "1"
            ),
            Pin(
                location: CLLocationCoordinate2D(latitude: 37.8068818, longitude: -122.4322241),
                name: "Greens Restaurant",
                icon: "fork.knife",
                rating: "4.9",
                details: "An upscale vegetarian restaurant offering seasonal dishes with prime bay views from floor-to-ceiling windows. 2 Marina B...",
                tags: ["🌊 Waterfront", "🌱 Vegan"],
                image: "9"
            ),
            Pin(
                location: CLLocationCoordinate2D(latitude: 37.79338653, longitude: -122.42256002),
                name: "The House of Prime Rib",
                icon: "fork.knife",
                rating: "4.4",
                details: "A classic spot renowned for its prime rib carved tableside and extra cold martinis. 1906 Van Ness Avenue, San Francisco,...",
                tags: [],
                image: "8"
            ),
            
            Pin(
                location: CLLocationCoordinate2D(latitude: 37.77629463, longitude: -122.39671496),
                name: "Petit Marlowe",
                icon: "fork.knife",
                rating: "3.9",
                details: "A Parisian-inspired wine and oyster bar in SoMa, perfect for an intimate date night.",
                tags: [],
                image: "10"
            ),
            Pin(
                location: CLLocationCoordinate2D(latitude: 37.79548494, longitude: -122.39369323),
                name: "The Slanted Door",
                icon: "fork.knife",
                rating: "5",
                details: "Located in the Ferry Building, this restaurant offers organic Vietnamese cuisine with waterfront views.",
                tags: ["🌊 Waterfront", "🌱 Vegan", "📍 Route Available"],
                image: "26"
            ),
        ].filter { pin in
            if onlyVegan {
                pin.tags.contains(where: { $0.contains("🌱") })
            } else {
                true
            }
        }.filter { pin in
            if best {
                pin.rating == "5"
            } else {
                true
            }
        }

        
    }
}
