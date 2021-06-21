@_implementationOnly import MapboxCommon_Private

/// Support for localization of labels
extension Style {

    /// This function creates an expression that will localize the `textField` property of a `SymbolLayer`
    /// - Parameter locale: A `SupportedLanguage` based `Locale`
    internal func localizeLabels(into locale: Locale) {

        /// Get all symbol layers that are currently on the map
        let symbolLayers = allLayerIdentifiers.filter { layer in
            return layer.type == .symbol
        }

        /// Expression to be applied to the `SymbolLayer.textField`to localize the language
        /// Sample Expression JSON: `["format",["coalesce",["get","name_en"],["get","name"]],{}]`
        let newVal = "[\"get\",\"name_\(getLocaleValue(locale: locale))\"]"

        let EXPRESSION_REGEX = try! NSRegularExpression(pattern: "\\[\"get\",\\s*\"(name|name_.{2,7})\"\\]",
                                                        options: .caseInsensitive)
        let EXPRESSION_ABBR_REGEX = try! NSRegularExpression(pattern: "\\[\"get\",\\s*\"abbr\"\\]",
                                                             options: .caseInsensitive)

        for layerInfo in symbolLayers {
            do {
                let tempLayer = try layer(withId: layerInfo.id) as SymbolLayer

                let encoder = JSONEncoder()
                let jsonData = try encoder.encode(tempLayer.textField)

                if var stringExpression = String(data: jsonData, encoding: .utf8) {
                    stringExpression = EXPRESSION_REGEX.stringByReplacingMatches(in: stringExpression,
                                                                                 options: [],
                                                                                 range: NSMakeRange(0, stringExpression.count),
                                                                                 withTemplate: newVal)

                    stringExpression = EXPRESSION_ABBR_REGEX.stringByReplacingMatches(in: stringExpression,
                                                                                      options: [],
                                                                                      range: NSMakeRange(0, stringExpression.count),
                                                                                      withTemplate: newVal)

                    let data = stringExpression.data(using: .utf8)
                    let decodedExpression = try JSONDecoder().decode(Expression.self, from: data!)
                    try updateLayer(withId: tempLayer.id) { (layer: inout SymbolLayer) throws in
                        layer.textField = .expression(decodedExpression)
                    }
                }
            } catch {
                Log.error(forMessage: "Error localizing textField for Symbol Layer with ID: \(layerInfo.id)", category: "Style")
            }
        }
    }

    /// Filters through source to determine supported locale styles.
    internal func getLocaleValue(locale: Locale) -> String {
        let vectorSources = allSourceIdentifiers.filter { source in
            return source.type == .vector
        }

        for sourceInfo in vectorSources {
            do {
                let tempSource = try source(withId: sourceInfo.id) as VectorSource

                if tempSource.url?.contains("mapbox.mapbox-streets-v7") == true{
                    if locale.identifier.contains("zh") {
                        // v7 styles does not support value of "name_zh-Hant"
                        if locale.identifier == SupportedLanguage.traditionalChinese.rawValue {
                            return SupportedLanguage.chinese.rawValue
                        }
                    }
                }
            } catch {
                Log.error(forMessage: "Error localizing textField for Symbol Layer", category: "Style")
            }
        }

        return locale.identifier
    }
}
