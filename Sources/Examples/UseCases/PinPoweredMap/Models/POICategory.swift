enum POICategory: Int, CaseIterable, Identifiable, Equatable {
    case restaurant
    case bar
    case cafe
    case fastFood
    case nightclub
    case beer
    case specialty

    var id: String {
        return switch self {
        case .restaurant: "restaurant"
        case .bar: "bar"
        case .beer: "brewery"
        case .specialty: "specialty_shop"
        case .fastFood: "fast_food"
        case .cafe: "cafe"
        case .nightclub: "nightclub"
        }
    }

    var name: String {
        return switch self {
        case .restaurant: "Restaurant"
        case .bar: "Bar"
        case .beer: "Beer"
        case .specialty: "Specialty Shop"
        case .fastFood: "Fast Food"
        case .cafe: "Cafe"
        case .nightclub: "Nightclub"
        }
    }

    var icon: String {
        return switch self {
        case .restaurant: "restaurant"
        case .bar: "beer"
        case .cafe: "cafe"
        case .fastFood: "restaurant-pizza"
        case .nightclub: "bar"
        case .beer: "beer"
        case .specialty: "ice-cream"
        }
    }
}
