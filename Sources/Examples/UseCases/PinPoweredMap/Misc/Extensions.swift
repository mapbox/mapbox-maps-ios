import MapboxMaps
import SwiftUI

extension FeaturesetFeature: @retroactive Identifiable { }

extension FeaturesetFeature {
    var rating: Double {
        guard let id = self.id?.id, let numericId = Int(id) else {
            return Double.random(in: 0.0..<Double(PinPoweredMapConstants.ratings.count))
        }

        return PinPoweredMapConstants.ratings[numericId % PinPoweredMapConstants.ratings.count]
    }
}
