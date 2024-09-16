@_implementationOnly import MapboxCommon_Private

/// Support for localization of labels
extension StyleManager {

    /// This function creates an expression that will localize the `textField` property of a `SymbolLayer`
    /// - Parameter locale: The`Locale` to update the map to
    /// - Parameter layerIds: An optional list of ids that need to be localized. If `nil` is provided, all layers will be updated
    public func localizeLabels(into locale: Locale, forLayerIds layerIds: [String]? = nil) throws {
        guard let localeValue = getLocaleValue(locale: locale) else {
            throw MapError(coreError: NSString(string: "Locale: \(String(describing: locale)) is currently not supported"))
        }

        // Get all symbol layers that are currently on the map
        var symbolLayers = allLayerIdentifiers.filter { layer in
            return layer.type == .symbol
        }

        // Filters for specific Ids if a list is provided
        if let layerIds = layerIds {
            symbolLayers = symbolLayers.filter { layer in
                return layerIds.contains(layer.id)
            }
        }

        for layerInfo in symbolLayers {
            let symbolLayer = try layer(withId: layerInfo.id, type: SymbolLayer.self)
            if let convertedExpression = try! convertExpressionForLocalization(symbolLayer: symbolLayer, localeValue: localeValue) {
                try setLayerProperty(for: symbolLayer.id, property: "text-field", value: convertedExpression)
            }
        }
    }

    /// Returns the BCP 47 language tag supported by Mapbox Streets source v8 that is most preferred according to the given preferences.
    /// Docs for language, region, and script codes: https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/LanguageandLocaleIDs/LanguageandLocaleIDs.html
    internal func preferredMapboxStreetsLocalization(among preferences: [String], from supportedCodes: [String]) -> String? {
        let availableCodes = supportedCodes.filter { languageCode in
            return Locale.availableIdentifiers.contains(languageCode)
        }
        let supportedLanguageCodes = availableCodes.map(Locale.init(identifier:))
        let preferredLocales = preferences.map(Locale.init(identifier:))

        // `Bundle.preferredLocalizations(from:forPreferences:)` returns locale identifiers for
        // which a bundle would provide localized content,
        // given a specified list of candidates for a user's language preferences.
        // https://developer.apple.com/documentation/foundation/bundle/1409418-preferredlocalizations
        // Note that generally one locale identifier is returned, unless compatible entries are available.
        // If none of the user-preferred localizations are available,
        // this method returns one of the values in supportedLanguageCodes ("en" if available).
        let mostSpecificLanguage = Bundle.preferredLocalizations(from: supportedLanguageCodes.map(\.identifier),
                                                                 forPreferences: preferences).first
        let mostSpecificLocale = mostSpecificLanguage.map { Locale(identifier: $0) }
        guard preferredLocales.contains(where: { $0.languageCode == mostSpecificLocale?.languageCode }) else {
            return nil
        }

        return mostSpecificLanguage
    }

    /// Returns the shortened language identifier string representing a supported Mapbox Streets Localization
    internal func getLocaleValue(locale: Locale) -> String? {
        let preferences: [String]
        // Check if the passed Locale is the system or a created Locale
        if locale == Locale.autoupdatingCurrent || locale == Locale.current {
            preferences = Locale.preferredLanguages
        } else {
            preferences = [locale.identifier]
        }

        // Lists language codes supported by Mapbox Streets Sources 7 and 8
        // https://docs.mapbox.com/data/tilesets/reference/legacy/mapbox-streets-v7/#name-fields
        let supportedLanguageCodesv7 = ["ar", "en", "es", "fr", "de", "pt", "ru", "ja", "ko", "zh", "zh_Hans"]
        // https://docs.mapbox.com/data/tilesets/reference/mapbox-streets-v8/#common-fields
        let supportedLanguageCodesv8 = ["ar", "en", "es", "fr", "de", "it", "pt", "ru", "zh_Hans", "zh_Hant", "ja", "ko", "vi"]

        // Check for Mapbox Streets v7 source, adapt return to match v7 spec
        for sourceInfo in allSourceIdentifiers where sourceInfo.type == .vector {
            // Force unwrapping since `allSourceIdentifiers` is getting a fresh list of valid sources
            let vectorSource = try! source(withId: sourceInfo.id, type: VectorSource.self)
            if vectorSource.url?.contains("mapbox.mapbox-streets-v7") == true {
                // Streets v7 only supports "zh"
                if locale.identifier.contains("Hant") || locale.identifier.contains("HK") || locale.identifier.contains("TW") {
                    return "zh"
                } else if locale.identifier.contains("Hans") || locale.identifier.contains("CN") {
                    return "zh-Hans"
                } else {
                    return preferredMapboxStreetsLocalization(among: preferences, from: supportedLanguageCodesv7) ?? nil
                }
            }
        }

        return preferredMapboxStreetsLocalization(among: preferences, from: supportedLanguageCodesv8) ?? nil
    }

    /// Converts the `SymbolLayer.textField` into the new locale
    /// - Parameters:
    ///   - symbolLayer: The layer that should be localized
    ///   - localeValue: The locale to convert to
    /// - Returns: An update JSON serialized expression with the updated locale
    internal func convertExpressionForLocalization(symbolLayer: SymbolLayer, localeValue: String) throws -> Any? {
        // Expression to be applied to the `SymbolLayer.textField`to localize the language
        // Sample Expression JSON: `["format",["coalesce",["get","name_en"],["get","name"]],{}]`
        let replacement = "[\"get\",\"name_\(localeValue)\"]"

        let expressionCoalesce = try NSRegularExpression(pattern: "\\[\"get\",\\s*\"(name_.{2,7})\"\\]",
                                                         options: .caseInsensitive)
        let expressionAbbr = try NSRegularExpression(pattern: "\\[\"get\",\\s*\"abbr\"\\]",
                                                     options: .caseInsensitive)

        if case .expression(let textField) = symbolLayer.textField {
            var stringExpression = String(data: try JSONEncoder().encode(textField), encoding: .utf8)!
            stringExpression.updateOnceExpression(replacement: replacement, regex: expressionCoalesce)
            stringExpression.updateExpression(replacement: replacement, regex: expressionAbbr)

            // Turn the new json string back into an Expression
            let data = stringExpression.data(using: .utf8)
            let convertedExpression = try JSONSerialization.jsonObject(with: data!, options: [])

            return convertedExpression
        }

        return nil
    }
}

extension String {

    /// Updates string using a regex
    /// - Parameters:
    ///   - replacement: New string to replace the matched pattern
    ///   - regex: The regex pattern that will be matched for replacement
    internal mutating func updateExpression(replacement: String, regex: NSRegularExpression) {
        let range = NSRange(location: 0, length: self.count)

        self = regex.stringByReplacingMatches(in: self,
                                              options: [],
                                              range: range,
                                              withTemplate: replacement)
    }

    /// Updates string once using the first occurrence of a regex
    /// - Parameters:
    ///   - replacement: New string to replace the matched pattern
    ///   - regex: The regex pattern that will be matched for replacement
    internal mutating func updateOnceExpression(replacement: String, regex: NSRegularExpression) {
        var range = NSRange(location: 0, length: NSString(string: self).length)
        range = regex.rangeOfFirstMatch(in: self, options: [], range: range)
        if range.lowerBound == NSNotFound {
            return
        }
        self = regex.stringByReplacingMatches(in: self,
                                              options: [],
                                              range: range,
                                              withTemplate: replacement)
    }
}
