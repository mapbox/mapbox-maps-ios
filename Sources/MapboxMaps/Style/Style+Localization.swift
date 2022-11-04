@_implementationOnly import MapboxCommon_Private

/// Support for localization of labels
extension Style {

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
    internal func preferredMapboxStreetsLocalization(among preferences: [String]) -> String? {
        let supportedLocaleIdentifiersv8 = ["ar", "en", "es", "fr", "de", "it", "pt", "ru", "zh-Hans", "zh-Hant", "ja", "ko", "vi"].map(Locale.init(identifier:))

        let preferredLocales = preferences.map(Locale.init(identifier:))

        let mostSpecificLanguage = Bundle.preferredLocalizations(from: supportedLocaleIdentifiersv8.map { $0.identifier },
                                                                 forPreferences: preferences)
            .max { $0.count > $1.count }

        // `Bundle.preferredLocalizations(from:forPreferences:)` is just returning the first localization it could find.
        if let mostSpecificLanguage = mostSpecificLanguage, !preferredLocales.contains(where: { $0.languageCode == Locale(identifier: mostSpecificLanguage).languageCode }) {
            return nil
        }
        return mostSpecificLanguage
    }

    /// Returns the shortened language identifier string representing a supported Mapbox Streets Localization
    /// List of supported language identifiers: https://docs.mapbox.com/data/tilesets/reference/mapbox-streets-v8/#common-fields
    internal func getLocaleValue(locale: Locale) -> String? {
        var localeValue: String?

        // Lists those supported by either v7 or v8
        let supportedLocaleIdentifiers = ["ar", "en", "es", "fr", "de", "it", "pt", "ru", "zh-Hans", "zh-Hant", "ja", "ko", "vi", "zh"]

        // Do nothing if we do not support the locale
        guard supportedLocaleIdentifiers.contains(locale.languageCode!) else {
            return nil
        }

        // Check for streets v7
        let vectorSources = allSourceIdentifiers.filter { source in
            return source.type == .vector
        }
        for sourceInfo in vectorSources {
            // Force unwrapping since `allSourceIdentifiers` is getting a fresh list of valid sources
            let vectorSource = try! source(withId: sourceInfo.id, type: VectorSource.self)

            if vectorSource.url?.contains("mapbox.mapbox-streets-v7") == true {
                // v7 styles do not support value of "name_zh-Hant"
                if locale.identifier == "zh-Hant" {
                    return "zh"
                }
                // v7 styles do not support Italian or Vietnamese
                if locale.identifier == "it" || locale.identifier == "vi" {
                    return nil
                } else {
                    localeValue = supportedLocaleIdentifiers.contains(locale.identifier) ? locale.identifier : locale.languageCode!
                    return localeValue
                }
            }
        }

        localeValue = preferredMapboxStreetsLocalization(among: [locale.identifier]) ?? nil

        return localeValue
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

        if case .expression(let textField) = symbolLayer.textField,
           var stringExpression = String(data: try JSONEncoder().encode(textField), encoding: .utf8) {
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
