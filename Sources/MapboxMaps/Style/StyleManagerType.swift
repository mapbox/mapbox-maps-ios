import Foundation
import MapboxCoreMaps
@_implementationOnly import MapboxCommon_Private

internal protocol StyleManagerType {
    func asStyleManager() -> StyleManager

    /**
     * Get the URI of the current style in use.
     *
     * @return A string containing a style URI.
     */
    func getStyleURI() -> String


    /**
     * Load style from provided URI.
     *
     * This is an asynchronous call. To check the result of this operation the user must register an observer observing
     * `MapLoaded` or `MapLoadingError` events. In case of successful style load, `StyleLoaded` event will be also emitted.
     *
     * @param uri URI where the style should be loaded from.
     */
    func setStyleURIForUri(_ uri: String)


    /**
     * Get the JSON serialization string of the current style in use.
     *
     * @return A JSON string containing a serialized style.
     */
    func getStyleJSON() -> String


    /**
     * Load the style from a provided JSON string.
     *
     * @param json A JSON string containing a serialized style.
     */
    func setStyleJSONForJson(_ json: String)


    /**
     * Returns the map style's default camera, if any, or a default camera otherwise.
     * The map style's default camera is defined as follows:
     * - [center](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-center)
     * - [zoom](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-zoom)
     * - [bearing](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-bearing)
     * - [pitch](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-pitch)
     *
     * The style default camera is re-evaluated when a new style is loaded.
     *
     * @return The default `camera options` of the current style in use.
     */
    func getStyleDefaultCamera() -> MapboxCoreMaps.CameraOptions


    /**
     * Returns the map style's transition options. By default, the style parser will attempt
     * to read the style default transition options, if any, fallbacking to an immediate transition
     * otherwise. Transition options can be overriden via `setStyleTransition`, but the options are
     * reset once a new style has been loaded.
     *
     * The style transition is re-evaluated when a new style is loaded.
     *
     * @return The `transition options` of the current style in use.
     */
    func getStyleTransition() -> MapboxCoreMaps.TransitionOptions


    /**
     * Overrides the map style's transition options with user-provided options.
     *
     * The style transition is re-evaluated when a new style is loaded.
     *
     * @param transitionOptions The `transition options`.
     */
    func setStyleTransitionFor(_ transitionOptions: MapboxCoreMaps.TransitionOptions)


    /**
     * Checks whether a given style layer exists.
     *
     * @param layerId Style layer identifier.
     *
     * @return A `true` value if the given style layer exists, `false` otherwise.
     */
    func styleLayerExists(forLayerId layerId: String) -> Bool


    /**
     * Returns the existing style layers.
     *
     * @return The list containing the information about existing style layer objects.
     */
    func getStyleLayers() -> [MapboxCoreMaps.StyleObjectInfo]


    /**
     * Gets the value of style layer property.
     *
     * @param layerId A style layer identifier.
     * @param property The style layer property name.
     * @return The `style property value`.
     */
    func getStyleLayerProperty(forLayerId layerId: String, property: String) -> MapboxCoreMaps.StylePropertyValue


    /**
     * Gets the default value of style layer property
     *
     * @param layerType A style [layer type](https://docs.mapbox.com/mapbox-gl-js/style-spec/#layers).
     * @param property The style layer property name.
     * @return The default `style property value` for a given `layerType` and `property` name.
     */
    static func getStyleLayerPropertyDefaultValue(forLayerType layerType: String, property: String) -> MapboxCoreMaps.StylePropertyValue


    /**
     * Gets the value of style source property.
     *
     * @param sourceId A style source identifier.
     * @param property The style source property name.
     * @return The value of a `property` in the source with a `sourceId`.
     */
    func getStyleSourceProperty(forSourceId sourceId: String, property: String) -> MapboxCoreMaps.StylePropertyValue


    /**
     * Gets the default value of style source property.
     *
     * @param sourceType A style source type.
     * @param property The style source property name.
     * @return The default value of a `property` for the sources with of a `sourceType` type.
     */
    static func getStyleSourcePropertyDefaultValue(forSourceType sourceType: String, property: String) -> MapboxCoreMaps.StylePropertyValue


    /**
     * Checks whether a given style source exists.
     *
     * @param sourceId A style source identifier.
     *
     * @return `true` if the given source exists, `false` otherwise.
     */
    func styleSourceExists(forSourceId sourceId: String) -> Bool


    /**
     * Returns the existing style sources.
     *
     * @return The list containing the information about existing style source objects.
     */
    func getStyleSources() -> [MapboxCoreMaps.StyleObjectInfo]


    /**
     * Gets the value of a style light property.
     *
     * @param property The style light property name.
     * @return The style light property value.
     */
    func getStyleLightProperty(forProperty property: String) -> MapboxCoreMaps.StylePropertyValue


    /**
     * Gets the value of a style terrain property.
     *
     * @param property The style terrain property name.
     * @return The style terrain property value.
     */
    func getStyleTerrainProperty(forProperty property: String) -> MapboxCoreMaps.StylePropertyValue


    /**
     * Gets the value of a style projection property.
     *
     * @param property The style projection property name.
     * @return The style projection property value.
     */
    func getStyleProjectionProperty(forProperty property: String) -> MapboxCoreMaps.StylePropertyValue


    /**
     * Get an `image` from the style.
     *
     * @param imageId The identifier of the `image`.
     *
     * @return The `image` for the given `imageId`, or empty if no image is associated with the `imageId`.
     */
    func getStyleImage(forImageId imageId: String) -> MapboxCoreMaps.Image?


    /**
     * Checks whether an image exists.
     *
     * @param imageId The identifier of the image.
     *
     * @return True if image exists, false otherwise.
     */
    func hasStyleImage(forImageId imageId: String) -> Bool


    /**
     * Check if the style is completely loaded.
     *
     * Note: The style specified sprite would be marked as loaded even with sprite loading error (An error will be emitted via `MapLoadingError`).
     * Sprite loading error is not fatal and we don't want it to block the map rendering, thus the function will still return `true` if style and sources are fully loaded.
     *
     * @return `true` iff the style JSON contents, the style specified sprite and sources are all loaded, otherwise returns `false`.
     *
     */
    func isStyleLoaded() -> Bool
}

// MARK: Conformance

extension StyleManager: StyleManagerType {

    func asStyleManager() -> StyleManager {
        return self
    }
}
