import XCTest
@testable import MapboxMaps

class UIColorTintedTests: XCTestCase {

    private let blue = UIColor(hue: 0.6, saturation: 1, brightness: 1, alpha: 1)

    func testTakesTheTintHue() {
        let tinted = UIColor(white: 1, alpha: 1).tinted(with: blue, maxChroma: 0.2)
        XCTAssertEqual(tinted.hue, 0.6, accuracy: 0.001)
    }

    func testKeepsBrightnessAndAlpha() {
        let base = UIColor(white: 0.8, alpha: 0.5)
        let tinted = base.tinted(with: blue, maxChroma: 0.2)
        XCTAssertEqual(tinted.brightness, base.brightness, accuracy: 0.001)
        XCTAssertEqual(tinted.alpha, base.alpha, accuracy: 0.001)
    }

    func testCapsChroma() {
        let tinted = UIColor(white: 1, alpha: 1).tinted(with: blue, maxChroma: 0.2)
        XCTAssertEqual(tinted.chroma, 0.2, accuracy: 0.001)
    }

    func testWeakTintIsNotAmplified() {
        let pale = UIColor(hue: 0.6, saturation: 0.05, brightness: 1, alpha: 1)
        let tinted = UIColor(white: 1, alpha: 1).tinted(with: pale, maxChroma: 0.2)
        XCTAssertEqual(tinted.chroma, 0.05, accuracy: 0.001)
    }

    /// Otherwise a dark brand color would give a weaker tint than a light one of the same hue.
    func testTintBrightnessIsIgnored() {
        let navy = UIColor(hue: 0.6, saturation: 0.9, brightness: 0.12, alpha: 1)
        let bright = UIColor(hue: 0.6, saturation: 0.9, brightness: 1, alpha: 1)
        let base = UIColor(white: 1, alpha: 1)
        XCTAssertEqual(base.tinted(with: navy, maxChroma: 0.2),
                       base.tinted(with: bright, maxChroma: 0.2))
    }

    func testChromaIsIndependentOfBaseBrightness() {
        let bright = UIColor(white: 1, alpha: 1).tinted(with: blue, maxChroma: 0.2)
        let dim = UIColor(white: 0.5, alpha: 1).tinted(with: blue, maxChroma: 0.2)
        XCTAssertEqual(dim.chroma, bright.chroma, accuracy: 0.001)
    }

    /// Chroma can't exceed brightness.
    func testBaseDarkerThanTheCapSaturatesInstead() {
        let tinted = UIColor(white: 0.1, alpha: 1).tinted(with: blue, maxChroma: 0.2)
        XCTAssertEqual(tinted.saturation, 1, accuracy: 0.001)
        XCTAssertEqual(tinted.chroma, 0.1, accuracy: 0.001)
    }

    func testBlackIsReturnedUnchanged() {
        let black = UIColor(white: 0, alpha: 1)
        XCTAssertEqual(black.tinted(with: blue, maxChroma: 0.2), black)
    }

    func testPatternColorIsReturnedUnchanged() {
        let pattern = UIColor(patternImage: UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
            .image { $0.fill(CGRect(x: 0, y: 0, width: 1, height: 1)) })
        XCTAssertEqual(pattern.tinted(with: blue, maxChroma: 0.2), pattern)
    }

    func testGrayTintLeavesTheColorGray() {
        let tinted = UIColor(white: 1, alpha: 1).tinted(with: .gray, maxChroma: 0.2)
        XCTAssertEqual(tinted.chroma, 0, accuracy: 0.001)
    }
}

private extension UIColor {
    var hue: CGFloat { component { getHue(&$0, saturation: nil, brightness: nil, alpha: nil) } }
    var saturation: CGFloat { component { getHue(nil, saturation: &$0, brightness: nil, alpha: nil) } }
    var brightness: CGFloat { component { getHue(nil, saturation: nil, brightness: &$0, alpha: nil) } }
    var alpha: CGFloat { component { getHue(nil, saturation: nil, brightness: nil, alpha: &$0) } }

    var chroma: CGFloat { saturation * brightness }

    private func component(_ read: (inout CGFloat) -> Bool) -> CGFloat {
        var value: CGFloat = 0
        _ = read(&value)
        return value
    }
}
