@_implementationOnly import MapboxCommon_Private

/// Support for localization of labels
extension Style {

    /// This function creates an expression that will localize the `textField` property of a `SymbolLayer`
    /// - Parameter locale: A `SupportedLanguage` based `Locale`
    public func localizeLabels(into locale: Locale, for layerIds: [String]? = nil) throws {

        /// Do nothing if we do not support the locale
        if !supportedLocales.contains(locale) {
            return
        }

        /// Get all symbol layers that are currently on the map
        var symbolLayers = allLayerIdentifiers.filter { layer in
            return layer.type == .symbol
        }

        /// Filters for specific Ids if a list is provided
        if let layerIds = layerIds {
            symbolLayers = symbolLayers.filter { layer in
                return layerIds.contains(layer.id)
            }
        }

        /// Expression to be applied to the `SymbolLayer.textField`to localize the language
        /// Sample Expression JSON: `["format",["coalesce",["get","name_en"],["get","name"]],{}]`
        let replacement = "[\"get\",\"name_\(getLocaleValue(locale: locale))\"]"

        let expressionCoalesce = try NSRegularExpression(pattern: "\\[\"get\",\\s*\"(name_.{2,7})\"\\]",
                                                         options: .caseInsensitive)
        let expressionAbbr = try NSRegularExpression(pattern: "\\[\"get\",\\s*\"abbr\"\\]",
                                                     options: .caseInsensitive)

        for layerInfo in symbolLayers {
            let tempLayer = try layer(withId: layerInfo.id) as SymbolLayer

            if var stringExpression = String(data: try JSONEncoder().encode(tempLayer.textField), encoding: .utf8),
               stringExpression != "null" {
                stringExpression.updateExpression(replacement: replacement, regex: expressionCoalesce)
                stringExpression.updateExpression(replacement: replacement, regex: expressionAbbr)

                // Turn the new json string back into an Expression
                let data = stringExpression.data(using: .utf8)
                let convertedExpression = try JSONSerialization.jsonObject(with: data!, options: [])

                try setLayerProperty(for: tempLayer.id, property: "text-field", value: convertedExpression)
            }
        }
    }

    /// Filters through source to determine supported locale styles.
    /// This is needed for v7 support
    internal func getLocaleValue(locale: Locale) -> String {
        let vectorSources = allSourceIdentifiers.filter { source in
            return source.type == .vector
        }

        for sourceInfo in vectorSources {
            do {
                if locale.identifier.starts(with: "zh") {
                    let tempSource = try source(withId: sourceInfo.id) as VectorSource

                    if tempSource.url?.contains("mapbox.mapbox-streets-v7") == true {
                        // v7 styles does not support value of "name_zh-Hant"
                        if locale.identifier == "zh-Hant" {
                            return "zh"
                        }
                    } else if tempSource.url?.contains("mapbox.mapbox-streets-v8") == true {
                        /// Return simplified chinese if the Locale is Taiwan
                        if locale.identifier == "zh_Hant_TW" {
                            return "zh-Hans"
                        }
                    }
                }
            } catch {
                Log.warning(forMessage: "Error localizing textField for Symbol Layer", category: "Style")
            }
        }

        return locale.identifier
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
}
