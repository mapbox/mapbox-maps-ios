import MapboxMaps

struct FeatureCollectionWrapper: Codable {
    let features: [FeatureDetails]
}

struct FeatureDetails: Codable, Equatable {
    let properties: Properties
    let geometry: Geometry?

    struct Properties: Codable, Equatable {
        let name: String?
        let address: String?
        let mapboxId: String?
        let categories: [String]?
        let metadata: Metadata?
        let maki: String?

        enum CodingKeys: String, CodingKey {
            case name, address = "full_address", mapboxId = "mapbox_id", categories = "poi_category", metadata, maki
        }

        struct Metadata: Codable, Equatable {
            let phone: String?
            let website: String?
            let rating: Double?
            let openHours: OpenHours?
            let weather: Weather?
            let photos: [Photos]?
            let primaryPhoto: String?
            let detailedDescription: String?

            struct Photos: Codable, Equatable {
                let url: String?
            }

            struct OpenHours: Codable, Equatable {
                let periods: [Period]?

                struct Period: Codable, Equatable {
                    let open: Time?
                    let close: Time?

                    struct Time: Codable, Equatable {
                        let day: Int? // day of week
                        let time: String? // e.g. "1430"
                    }
                }
            }

            struct Weather: Codable, Equatable {
                let temperature: Int?
                let high: Int?
                let low: Int?
                let condition: String?
            }

            enum CodingKeys: String, CodingKey {
                case phone, website, rating, openHours = "open_hours", weather, photos, primaryPhoto = "primary_photo", detailedDescription = "detailed_description"
            }
        }
    }
}
