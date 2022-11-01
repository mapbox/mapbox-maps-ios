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
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "en-US")), "en", "Extraneous region codes should be removed.")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "en-Latn")), "en", "Extraneous script codes should be removed.")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "zh")), "zh-Hans")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "zh-Hans")), "zh-Hans")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "zh-Hant")), "zh-Hant")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "zh-Hans-CN")), "zh-Hans", "Extraneous region codes should be removed.")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "zh-Hant-TW")), "zh-Hant")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "zh-Hant-HK")), "zh-Hant", "Extraneous region codes should be removed.")
    }
    
    // Test iOS 16 Locale Components
    func testLocaleComponents() {
        if #available(iOS 16, *) {
            let fullLocaleHK = Locale(languageCode: "zh", script: "Hant", languageRegion: "HK")
            XCTAssertEqual(style.getLocaleValue(locale: fullLocaleHK), "zh-Hant")
            let partialLocaleHK = Locale(languageCode: "zh", script: "Hant")
            XCTAssertEqual(style.getLocaleValue(locale: partialLocaleHK), "zh-Hant")
            let partialLocaleHK2 = Locale(languageCode: "zh", languageRegion: "HK")
            XCTAssertEqual(style.getLocaleValue(locale: partialLocaleHK2), "zh-Hant")
            let onlyZHLanguage = Locale(languageCode: "zh")
            XCTAssertEqual(style.getLocaleValue(locale: onlyZHLanguage), "zh-Hans")
        }
    }

    func testGetLocaleValueDoesNotExist() {
        let style = mapView.mapboxMap.style
        XCTAssertNil(style.getLocaleValue(locale: Locale(identifier: "FAKE")))
    }

    func testLocalizeLabelsThrowsCase() {
        let style = mapView.mapboxMap.style

        XCTAssertThrowsError(try style.localizeLabels(into: Locale(identifier: "tlh")))
        XCTAssertThrowsError(try style.localizeLabels(into: Locale(identifier: "frm")), "Exact string needs to match, not just prefix")
    }

    func testOnlyLocalizesFirstLocalization() throws {
        var source = GeoJSONSource()
        source.data = .feature(Feature(geometry: Point(CLLocationCoordinate2D(latitude: 0, longitude: 0))))
        try style.addSource(source, id: "a")

        var symbolLayer = SymbolLayer(id: "a")
        symbolLayer.source = "a"
        symbolLayer.textField = .expression(
            Exp(.format) {
                Exp(.coalesce) {
                    Exp(.get) {
                        "name_en"
                    }
                    Exp(.get) {
                        "name_fr"
                    }
                    Exp(.get) {
                        "name"
                    }
                }
                FormatOptions()
            }
        )

        try style.addLayer(symbolLayer)

        try style.localizeLabels(into: Locale(identifier: "de"))

        let updatedLayer = try style.layer(withId: "a", type: SymbolLayer.self)

        XCTAssertEqual(updatedLayer.textField, .expression(
            Exp(.format) {
                Exp(.coalesce) {
                    Exp(.get) {
                        "name_de"
                    }
                    Exp(.get) {
                        "name_fr"
                    }
                    Exp(.get) {
                        "name"
                    }
                }
                FormatOptions()
            }
        ))
    }

    func testSkipsSymbolLayersWhereTextFieldIsNil() throws {
        var source = GeoJSONSource()
        source.data = .feature(Feature(geometry: Point(CLLocationCoordinate2D(latitude: 0, longitude: 0))))
        try style.addSource(source, id: "a")

        var symbolLayer = SymbolLayer(id: "a")
        symbolLayer.source = "a"

        try style.addLayer(symbolLayer)

        try style.localizeLabels(into: Locale(identifier: "de"))

        let updatedLayer = try style.layer(withId: "a", type: SymbolLayer.self)

        XCTAssertNil(updatedLayer.textField)
    }
}
