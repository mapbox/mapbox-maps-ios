import Foundation
import UIKit

extension MapboxScaleBarOrnamentView {
    struct Constants {
        internal static let primaryColor: UIColor = #colorLiteral(red: 0.07058823529, green: 0.1764705882, blue: 0.06666666667, alpha: 1)
        internal static let secondaryColor: UIColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        internal static let borderWidth: CGFloat = 1

        internal static let feetPerMile: Double = 5280
        internal static let feetPerMeter: Double = 3.28084

        internal static let barHeight: CGFloat = 4
        internal static let scaleBarLabelWidthHint: CGFloat = 30.0
        internal static let scaleBarMinimumBarWidth: CGFloat = 30.0 // Arbitrary

        internal static let metricTable: [Row] = [
            (distance: 1, numberOfBars: 2),
            (distance: 2, numberOfBars: 2),
            (distance: 4, numberOfBars: 2),
            (distance: 10, numberOfBars: 2),
            (distance: 20, numberOfBars: 2),
            (distance: 50, numberOfBars: 2),
            (distance: 75, numberOfBars: 3),
            (distance: 100, numberOfBars: 2),
            (distance: 150, numberOfBars: 2),
            (distance: 200, numberOfBars: 2),
            (distance: 300, numberOfBars: 3),
            (distance: 500, numberOfBars: 2),
            (distance: 1_000, numberOfBars: 2),
            (distance: 1_500, numberOfBars: 2),
            (distance: 3_000, numberOfBars: 3),
            (distance: 5_000, numberOfBars: 2),
            (distance: 10_000, numberOfBars: 2),
            (distance: 20_000, numberOfBars: 2),
            (distance: 30_000, numberOfBars: 3),
            (distance: 50_000, numberOfBars: 2),
            (distance: 100_000, numberOfBars: 2),
            (distance: 200_000, numberOfBars: 2),
            (distance: 300_000, numberOfBars: 3),
            (distance: 400_000, numberOfBars: 2),
            (distance: 500_000, numberOfBars: 2),
            (distance: 600_000, numberOfBars: 3),
            (distance: 800_000, numberOfBars: 2),
            (distance: 1_000_000, numberOfBars: 2),
            (distance: 2_000_000, numberOfBars: 2),
            (distance: 3_000_000, numberOfBars: 3),
            (distance: 4_000_000, numberOfBars: 2),
            (distance: 5_000_000, numberOfBars: 2),
            (distance: 6_000_000, numberOfBars: 3),
            (distance: 8_000_000, numberOfBars: 2),
            (distance: 10_000_000, numberOfBars: 2),
            (distance: 12_000_000, numberOfBars: 2),
            (distance: 15_000_000, numberOfBars: 2)
        ]

        internal static let imperialTable: [Row] = [
            (distance: 1, numberOfBars: 1),
            (distance: 4, numberOfBars: 2),
            (distance: 6, numberOfBars: 2),
            (distance: 10, numberOfBars: 2),
            (distance: 20, numberOfBars: 2),
            (distance: 30, numberOfBars: 2),
            (distance: 50, numberOfBars: 2),
            (distance: 75, numberOfBars: 3),
            (distance: 100, numberOfBars: 2),
            (distance: 200, numberOfBars: 2),
            (distance: 300, numberOfBars: 3),
            (distance: 400, numberOfBars: 2),
            (distance: 600, numberOfBars: 3),
            (distance: 800, numberOfBars: 2),
            (distance: 1000, numberOfBars: 2),
            (distance: 0.25*feetPerMile, numberOfBars: 2),
            (distance: 0.5*feetPerMile, numberOfBars: 2),
            (distance: 1*feetPerMile, numberOfBars: 2),
            (distance: 2*feetPerMile, numberOfBars: 2),
            (distance: 3*feetPerMile, numberOfBars: 3),
            (distance: 4*feetPerMile, numberOfBars: 2),
            (distance: 8*feetPerMile, numberOfBars: 2),
            (distance: 12*feetPerMile, numberOfBars: 2),
            (distance: 15*feetPerMile, numberOfBars: 3),
            (distance: 20*feetPerMile, numberOfBars: 2),
            (distance: 30*feetPerMile, numberOfBars: 3),
            (distance: 40*feetPerMile, numberOfBars: 2),
            (distance: 80*feetPerMile, numberOfBars: 2),
            (distance: 120*feetPerMile, numberOfBars: 2),
            (distance: 200*feetPerMile, numberOfBars: 2),
            (distance: 300*feetPerMile, numberOfBars: 3),
            (distance: 400*feetPerMile, numberOfBars: 2),
            (distance: 600*feetPerMile, numberOfBars: 3),
            (distance: 1000*feetPerMile, numberOfBars: 2),
            (distance: 1500*feetPerMile, numberOfBars: 3),
            (distance: 2000*feetPerMile, numberOfBars: 2),
            (distance: 3000*feetPerMile, numberOfBars: 2),
            (distance: 4000*feetPerMile, numberOfBars: 2),
            (distance: 5000*feetPerMile, numberOfBars: 2),
            (distance: 6000*feetPerMile, numberOfBars: 3),
            (distance: 8000*feetPerMile, numberOfBars: 2),
            (distance: 10000*feetPerMile, numberOfBars: 2)
        ]

        private init() {}
    }
}
