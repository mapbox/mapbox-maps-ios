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

    /// Filters through source to determine supported locale styles.
    /// This is needed for v7 support
    internal func getLocaleValue(locale: Locale) -> String? {
        // Docs for language, region, and script codes  https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/LanguageandLocaleIDs/LanguageandLocaleIDs.html
        let supportedLocaleIdentifiers = ["ar", "de", "en", "es", "fr", "it", "ja", "ko", "pt", "ru", "vi", "zh", "zh-Hans", "zh-Hant", "zh-Hant-TW"]

        // Do nothing if we do not support the locale
        if !supportedLocaleIdentifiers.contains(locale.languageCode!) {
            return nil
        }

        let vectorSources = allSourceIdentifiers.filter { source in
            return source.type == .vector
        }

        for sourceInfo in vectorSources {
            if locale.identifier.starts(with: "zh") {
                // Force unwrapping since `allSourceIdentifiers` is getting a fresh list of valid sources
                let vectorSource = try! source(withId: sourceInfo.id, type: VectorSource.self)

                if vectorSource.url?.contains("mapbox.mapbox-streets-v7") == true {
                    // v7 styles does not support value of "name_zh-Hant"
                    if locale.identifier == "zh-Hant" {
                        return "zh"
                    }
                } else if vectorSource.url?.contains("mapbox.mapbox-streets-v8") == true {
                    // Return traditional chinese if the Locale is Taiwan
                    if locale.identifier == "zh-Hant-TW" {
                        return "zh-Hant"
                    }
                }
            }
        }

        return supportedLocaleIdentifiers.contains(locale.identifier) ? locale.identifier : locale.languageCode!
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

        if var stringExpression = String(data: try JSONEncoder().encode(symbolLayer.textField), encoding: .utf8),
           stringExpression != "null" {
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
