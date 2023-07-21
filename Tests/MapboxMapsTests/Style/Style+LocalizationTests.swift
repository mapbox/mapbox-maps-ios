import XCTest
@testable import MapboxMaps

final class StyleLocalizationTests: MapViewIntegrationTestCase {

    func testGetLocaleValueBaseCase() {
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "ar")), "ar")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "de")), "de")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "en")), "en")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "es")), "es")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "fr")), "fr")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "it")), "it")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "ja")), "ja")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "ko")), "ko")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "pt")), "pt")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "ru")), "ru")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "vi")), "vi")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "en-US")), "en", "Extraneous region codes should be removed.")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "en-Latn")), "en", "Extraneous script codes should be removed.")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "zh")), "zh-Hans")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "zh-Hans")), "zh-Hans")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "zh-Hant")), "zh-Hant")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "zh-Hans-CN")), "zh-Hans", "Extraneous region codes should be removed.")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "zh-Hant-TW")), "zh-Hant")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "zh-Hant-HK")), "zh-Hant", "Extraneous region codes should be removed.")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "zh-Hans-SG")), "zh-Hans")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "zh-CN")), "zh-Hans")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "zh-SG")), "zh-Hans")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "zh-TW")), "zh-Hant")
        XCTAssertEqual(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "zh-HK")), "zh-Hant")
    }

    func testGetLocaleValueDoesNotExist() {
        XCTAssertNil(mapView.mapboxMap.getLocaleValue(locale: Locale(identifier: "FAKE")))
    }

    func testLocalizeLabelsThrowsCase() {
        XCTAssertThrowsError(try mapView.mapboxMap.localizeLabels(into: Locale(identifier: "tlh")))
        XCTAssertThrowsError(try mapView.mapboxMap.localizeLabels(into: Locale(identifier: "frm")), "Exact string needs to match, not just prefix")
    }

    func testPreferredMapboxStreetsv7Localization() {
        let supportedLanguageCodesv7 = ["ar", "en", "es", "fr", "de", "pt", "ru", "ja", "ko", "zh", "zh_Hans"]

        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["de"], from: supportedLanguageCodesv7), "de")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["en", "de"], from: supportedLanguageCodesv7), "en")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["rett", "de", "en"], from: supportedLanguageCodesv7), "de")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["rett", "de", "zh-Hans"], from: supportedLanguageCodesv7), "de")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["rett", "der", "zh-Hans"], from: supportedLanguageCodesv7), "zh-Hans")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["rett", "der", "zh"], from: supportedLanguageCodesv7), "zh")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["rett", "der", "zh", "zh-Hant"], from: supportedLanguageCodesv7), "zh")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["rett", "der", "zh-Hant", "zh-Hans"], from: supportedLanguageCodesv7), "zh-Hans")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["ar", "en", "es", "fr", "de", "it", "pt", "ru", "zh-Hans", "zh-Hant", "ja", "ko", "vi"], from: supportedLanguageCodesv7), "ar")
        XCTAssertNil(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["rett", "der", "ffzh"], from: supportedLanguageCodesv7))
        XCTAssertNil(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: [""], from: supportedLanguageCodesv7))
        XCTAssertNil(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["vi", "it"], from: supportedLanguageCodesv7))
        XCTAssertNil(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["it"], from: supportedLanguageCodesv7))
        XCTAssertNil(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["vi"], from: supportedLanguageCodesv7))
    }

    func testPreferredMapboxStreetsv8Localization() {
        let supportedLanguageCodesv8 = ["ar", "en", "es", "fr", "de", "it", "pt", "ru", "zh_Hans", "zh_Hant", "ja", "ko", "vi"]

        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["de"], from: supportedLanguageCodesv8), "de")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["en", "de"], from: supportedLanguageCodesv8), "en")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["rett", "de", "en"], from: supportedLanguageCodesv8), "de")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["rett", "de", "zh-Hans"], from: supportedLanguageCodesv8), "de")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["rett", "der", "zh-Hans"], from: supportedLanguageCodesv8), "zh-Hans")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["rett", "der", "zh"], from: supportedLanguageCodesv8), "zh-Hans")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["rett", "der", "zh", "zh-Hant"], from: supportedLanguageCodesv8), "zh-Hans")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["rett", "der", "zh-hant", "zh-Hans"], from: supportedLanguageCodesv8), "zh-Hant")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["vi", "ko"], from: supportedLanguageCodesv8), "vi")
        XCTAssertEqual(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["ar", "en", "es", "fr", "de", "it", "pt", "ru", "zh-Hans", "zh-Hant", "ja", "ko", "vi"], from: supportedLanguageCodesv8), "ar")
        XCTAssertNil(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: ["rett", "der", "ffzh"], from: supportedLanguageCodesv8))
        XCTAssertNil(mapView.mapboxMap.preferredMapboxStreetsLocalization(among: [""], from: supportedLanguageCodesv8))
    }

    func testOnlyLocalizesFirstLocalization() throws {
        var source = GeoJSONSource(id: "a")
        source.data = .feature(Feature(geometry: Point(CLLocationCoordinate2D(latitude: 0, longitude: 0))))
        try mapView.mapboxMap.addSource(source)

        var symbolLayer = SymbolLayer(id: "a", source: "a")
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

        try mapView.mapboxMap.addLayer(symbolLayer)

        try mapView.mapboxMap.localizeLabels(into: Locale(identifier: "de"))

        let updatedLayer = try mapView.mapboxMap.layer(withId: "a", type: SymbolLayer.self)

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
        var source = GeoJSONSource(id: "a")
        source.data = .feature(Feature(geometry: Point(CLLocationCoordinate2D(latitude: 0, longitude: 0))))
        try mapView.mapboxMap.addSource(source)

        let symbolLayer = SymbolLayer(id: "a", source: "a")

        try mapView.mapboxMap.addLayer(symbolLayer)

        try mapView.mapboxMap.localizeLabels(into: Locale(identifier: "de"))

        let updatedLayer = try mapView.mapboxMap.layer(withId: "a", type: SymbolLayer.self)

        XCTAssertNil(updatedLayer.textField)
    }
}
