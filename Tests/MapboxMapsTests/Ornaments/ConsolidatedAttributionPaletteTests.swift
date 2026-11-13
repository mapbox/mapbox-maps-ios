import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class ConsolidatedAttributionPaletteTests: XCTestCase {
    private let vivid = UIColor(hue: 0.6, saturation: 1, brightness: 1, alpha: 1)

    private func pill(
        _ material: ConsolidatedAttributionMaterial = .solid,
        tint: UIColor? = nil,
        style: UIUserInterfaceStyle = .light
    ) -> UIColor {
        ConsolidatedAttributionPalette.pill(material, tint: tint)
            .resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
    }

    // MARK: - Tint

    func testUntintedPillIsNeutral() {
        XCTAssertEqual(pill(style: .light).saturation, 0, accuracy: 0.001)
        XCTAssertEqual(pill(style: .dark).saturation, 0, accuracy: 0.001)
    }

    func testTintShiftsHueWithoutChangingBrightnessOrAlpha() {
        let untinted = pill()
        let tinted = pill(tint: .systemBlue)

        XCTAssertGreaterThan(tinted.saturation, 0, "The tint must be visible at all")
        XCTAssertEqual(tinted.hsbBrightness, untinted.hsbBrightness, accuracy: 0.001)
        XCTAssertEqual(tinted.alpha, untinted.alpha, accuracy: 0.001)
    }

    func testTintChromaIsCapped() {
        XCTAssertLessThanOrEqual(pill(tint: vivid).chroma, 0.15)
    }

    func testDarkAppearanceIsNeverTinted() {
        XCTAssertEqual(pill(tint: vivid, style: .dark), pill(style: .dark))
    }

    func testTintWeakerThanTheCapIsPassedThrough() {
        let pale = UIColor(hue: 0.6, saturation: 0.05, brightness: 1, alpha: 1)

        XCTAssertEqual(pill(tint: pale).saturation, 0.05, accuracy: 0.005)
    }

    func testTintResolvesDynamicColorsPerInterfaceStyle() {
        let dynamicTint = UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(hue: 0.9, saturation: 1, brightness: 1, alpha: 1)
                : UIColor(hue: 0.3, saturation: 1, brightness: 1, alpha: 1)
        }

        XCTAssertEqual(pill(tint: dynamicTint, style: .light).hue, 0.3, accuracy: 0.01)
        XCTAssertEqual(pill(tint: dynamicTint, style: .dark).chroma, 0, accuracy: 0.001)
    }

    func testTranslucentMaterialTakesTintAtLeastAsStrongly() {
        XCTAssertGreaterThan(pill(.translucent, tint: vivid).saturation, pill(.solid, tint: vivid).saturation)
    }

    // MARK: - Interface style

    func testPillFollowsUserInterfaceStyle() {
        let light = pill(style: .light)
        let dark = pill(style: .dark)

        XCTAssertNotEqual(light, dark)
        XCTAssertGreaterThan(light.brightness, dark.brightness)
    }

    func testTranslucentMaterialIsMoreTransparentThanSolid() {
        XCTAssertGreaterThan(pill(.solid).alpha, pill(.translucent).alpha)
    }
}

private extension UIColor {
    var alpha: CGFloat {
        var value: CGFloat = 0
        getWhite(nil, alpha: &value)
        return value
    }

    var brightness: CGFloat {
        var value: CGFloat = 0
        getWhite(&value, alpha: nil)
        return value
    }

    var hue: CGFloat {
        var value: CGFloat = 0
        getHue(&value, saturation: nil, brightness: nil, alpha: nil)
        return value
    }

    var chroma: CGFloat { saturation * hsbBrightness }

    var saturation: CGFloat {
        var value: CGFloat = 0
        getHue(nil, saturation: &value, brightness: nil, alpha: nil)
        return value
    }

    /// `brightness` reads the grayscale channel, which a tinted color lacks.
    var hsbBrightness: CGFloat {
        var value: CGFloat = 0
        getHue(nil, saturation: nil, brightness: &value, alpha: nil)
        return value
    }
}
