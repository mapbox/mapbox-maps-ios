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
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "zh-Hans-SG")), "zh-Hans")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "zh-CN")), "zh-Hans")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "zh-SG")), "zh-Hans")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "zh-TW")), "zh-Hant")
        XCTAssertEqual(style.getLocaleValue(locale: Locale(identifier: "zh-HK")), "zh-Hant")
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

    func testPreferredMapboxStreetsv7Localization() {
        let style = mapView.mapboxMap.style
        let supportedLanguageCodesv7 = ["ar", "en", "es", "fr", "de", "pt", "ru", "ja", "ko", "zh", "zh_Hans"]

        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["de"], from: supportedLanguageCodesv7), "de")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["en", "de"], from: supportedLanguageCodesv7), "en")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["rett", "de", "en"], from: supportedLanguageCodesv7), "de")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["rett", "de", "zh-Hans"], from: supportedLanguageCodesv7), "de")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["rett", "der", "zh-Hans"], from: supportedLanguageCodesv7), "zh-Hans")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["rett", "der", "zh"], from: supportedLanguageCodesv7), "zh")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["rett", "der", "zh", "zh-Hant"], from: supportedLanguageCodesv7), "zh")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["rett", "der", "zh-Hant", "zh-Hans"], from: supportedLanguageCodesv7), "zh-Hans")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["ar", "en", "es", "fr", "de", "it", "pt", "ru", "zh-Hans", "zh-Hant", "ja", "ko", "vi"], from: supportedLanguageCodesv7), "ar")
        XCTAssertNil(style.preferredMapboxStreetsLocalization(among: ["rett", "der", "ffzh"], from: supportedLanguageCodesv7))
        XCTAssertNil(style.preferredMapboxStreetsLocalization(among: [""], from: supportedLanguageCodesv7))
        XCTAssertNil(style.preferredMapboxStreetsLocalization(among: ["vi", "it"], from: supportedLanguageCodesv7))
        XCTAssertNil(style.preferredMapboxStreetsLocalization(among: ["it"], from: supportedLanguageCodesv7))
        XCTAssertNil(style.preferredMapboxStreetsLocalization(among: ["vi"], from: supportedLanguageCodesv7))
    }

    func testPreferredMapboxStreetsv8Localization() {
        let style = mapView.mapboxMap.style
        let supportedLanguageCodesv8 = ["ar", "en", "es", "fr", "de", "it", "pt", "ru", "zh_Hans", "zh_Hant", "ja", "ko", "vi"]

        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["de"], from: supportedLanguageCodesv8), "de")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["en", "de"], from: supportedLanguageCodesv8), "en")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["rett", "de", "en"], from: supportedLanguageCodesv8), "de")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["rett", "de", "zh-Hans"], from: supportedLanguageCodesv8), "de")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["rett", "der", "zh-Hans"], from: supportedLanguageCodesv8), "zh-Hans")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["rett", "der", "zh"], from: supportedLanguageCodesv8), "zh-Hans")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["rett", "der", "zh", "zh-Hant"], from: supportedLanguageCodesv8), "zh-Hans")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["rett", "der", "zh-hant", "zh-Hans"], from: supportedLanguageCodesv8), "zh-Hant")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["vi", "ko"], from: supportedLanguageCodesv8), "vi")
        XCTAssertEqual(style.preferredMapboxStreetsLocalization(among: ["ar", "en", "es", "fr", "de", "it", "pt", "ru", "zh-Hans", "zh-Hant", "ja", "ko", "vi"], from: supportedLanguageCodesv8), "ar")
        XCTAssertNil(style.preferredMapboxStreetsLocalization(among: ["rett", "der", "ffzh"], from: supportedLanguageCodesv8))
        XCTAssertNil(style.preferredMapboxStreetsLocalization(among: [""], from: supportedLanguageCodesv8))
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
