import XCTest
@testable import MapboxMaps

final class StyleLocalizationTests: MapViewIntegrationTestCase {

    func testGetLocaleValueBaseCase() {
        let style = mapView.mapboxMap.style

        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "ar")), "ar")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "de")), "de")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "en")), "en")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "es")), "es")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "fr")), "fr")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "it")), "it")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "ja")), "ja")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "ko")), "ko")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "pt")), "pt")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "ru")), "ru")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "vi")), "vi")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "zh")), "zh")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "zh-Hans")), "zh-Hans")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "zh-Hant")), "zh-Hant")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "zh-Hant-TW")), "zh-Hant-TW")
    }

    func testGetLocaleValueDoesNotExist() {
        let style = mapView.mapboxMap.style
        XCTAssertNil(style.getLocaleValue(locale: Locale(identifier: "FAKE")))
    }

    func testLocalizeLabelsThrowsCase() {
        let style = mapView.mapboxMap.style
        
        XCTAssertThrowsError(try style.localizeLabels(into: Locale(identifier: "tlh")))
    }
}
