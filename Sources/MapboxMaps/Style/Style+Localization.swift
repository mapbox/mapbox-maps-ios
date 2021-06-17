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
        let expression = Exp(.format) {
            Exp(.coalesce) {
                Exp(.get) {
                    "name_\(locale.identifier)"
                }
                Exp(.get) {
                    "name"
                }
            }
        }

        for layerInfo in symbolLayers {
            do {
                let tempLayer = try layer(withId: layerInfo.id) as SymbolLayer

                try updateLayer(withId: tempLayer.id) { (layer: inout SymbolLayer) throws in
                    layer.textField = .expression(expression)
                }
            } catch {
                Log.error(forMessage: "Error localizing textField for Symbol Layer with ID: \(layerInfo.id)", category: "Style")
            }
        }
    }
}
