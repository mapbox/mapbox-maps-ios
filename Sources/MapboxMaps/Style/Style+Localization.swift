@_implementationOnly import MapboxCommon_Private

/// Support for localization of labels
extension Style {

    /// This function creates an expression that will localize the `textField` property of a `SymbolLayer`
    /// - Parameter locale: A `SupportedLanguage` based `Locale`
    internal func localizeLabels(into locale: Locale) throws {

        /// Get all symbol layers that are currently on the map
        let symbolLayers = allLayerIdentifiers.filter { layer in
            return layer.type == .symbol
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
                let tempSource = try source(withId: sourceInfo.id) as VectorSource

                if tempSource.url?.contains("mapbox.mapbox-streets-v7") == true {
                    if locale.identifier.contains("zh") {
                        // v7 styles does not support value of "name_zh-Hant"
                        if locale.identifier == SupportedLanguage.traditionalChinese.rawValue {
                            return SupportedLanguage.chinese.rawValue
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
        let range = NSMakeRange(0, self.count)

        self = regex.stringByReplacingMatches(in: self,
                                              options: [],
                                              range: range,
                                              withTemplate: replacement)
    }
}
