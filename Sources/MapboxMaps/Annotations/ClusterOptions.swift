import UIKit

/// Options to configure point annotation clustering with PointAnnotationManager.
///
/// ClusterOptions exposes a minimal of configuration options, a more advanced setup can be created manually with
/// using CircleLayer and SymbolLayers directly.

public struct ClusterOptions: Equatable, Sendable {
    /// The circle radius of the cluster items, 18 by default. Units in pixels.
    var circleRadius: Value<Double>

    /// The circle color, black by default.
    var circleColor: Value<StyleColor>

    /// The text color of cluster item, white by default
    var textColor: Value<StyleColor>

    /// The text size of cluster item, 12 by default. Units in pixels.
    var textSize: Value<Double>

    /// Value to use for a text label of the cluster. `get("point_count")` by default which
    /// will show the count of points in the cluster
    var textField: Value<String>

    /// Radius of each cluster if clustering is enabled. A value of 512 indicates a radius equal
    /// to the width of a tile, 50 by default. Value must be greater than or equal to 0.
    var clusterRadius: Double

    /// Max zoom on which to cluster points if clustering is enabled. Defaults to one zoom less
    /// than maxzoom (so that last zoom features are not clustered). Clusters are re-evaluated at integer zoom
    /// levels so setting clusterMaxZoom to 14 means the clusters will be displayed until z15.
    var clusterMaxZoom: Double

    /// Minimum number of points necessary to form a cluster if clustering is enabled. Defaults to `2`.
    var clusterMinPoints: Double

    /// An object defining custom properties on the generated clusters if clustering is enabled, aggregating values from
    /// clustered points. Has the form `{"property_name": [operator, map_expression]}`.
    /// `operator` is any expression function that accepts at
    /// least 2 operands (e.g. `"+"` or `"max"`) — it accumulates the property value from clusters/points the
    /// cluster contains; `map_expression` produces the value of a single point. Example:
    ///
    /// ``Exp`` syntax:
    /// ```
    /// let expression = Exp(.sum) {
    ///     Exp(.get) { "scalerank" }
    /// }
    /// clusterProperties: ["sum": expression]
    /// ```
    ///
    /// JSON syntax:
    /// `{"sum": ["+", ["get", "scalerank"]]}`
    ///
    /// For more advanced use cases, in place of `operator`, you can use a custom reduce expression that references a special `["accumulated"]` value. Example:
    ///
    /// ``Exp`` syntax:
    /// ```
    /// let expression = Exp {
    ///     Exp(.sum) {
    ///         Exp(.accumulated)
    ///         Exp(.get) { "sum" }
    ///     }
    ///     Exp(.get) { "scalerank" }
    /// }
    /// clusterProperties: ["sum": expression]
    /// ```
    ///
    /// JSON syntax:
    /// `{"sum": [["+", ["accumulated"], ["get", "sum"]], ["get", "scalerank"]]}`
    var clusterProperties: [String: Exp]?

    /// Define a set of cluster options to determine how to cluster annotations.
    /// Providing clusterOptions when initializing a ``PointAnnotationManager``
    /// will turn on clustering for that ``PointAnnotationManager``.
    public init(circleRadius: Value<Double> = .constant(18),
                circleColor: Value<StyleColor> = .constant(StyleColor(.black)),
                textColor: Value<StyleColor> = .constant(StyleColor(.white)),
                textSize: Value<Double> = .constant(12),
                textField: Value<String> = .expression(Exp(.get) { "point_count" }),
                clusterRadius: Double = 50,
                clusterMaxZoom: Double = 14,
                clusterMinPoints: Double = 2,
                clusterProperties: [String: Exp]? = nil) {
        self.circleRadius = circleRadius
        self.circleColor = circleColor
        self.textColor = textColor
        self.textSize = textSize
        self.textField = textField
        self.clusterRadius = clusterRadius
        self.clusterMaxZoom = clusterMaxZoom
        self.clusterMinPoints = clusterMinPoints
        self.clusterProperties = clusterProperties
    }
}
