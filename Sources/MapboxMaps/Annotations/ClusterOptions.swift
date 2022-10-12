/// Options to show and configure symbol clustering with using SymbolManager.
///
/// It exposes a minimal of configuration options, a more advanced setup can be created manually with
/// using CircleLayer and SymbolLayers directly.

public struct ClusterOptions {

    public init(clusterRadius: Double = 50,
                circleRadius: Value<Double> = .constant(18),
                textColor: Value<StyleColor> = .constant(StyleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))),
                textSize: Value<Double> = .constant(12),
                textField: Value<String> = .expression(Exp(.get) { "point_count" }),
                clusterMaxZoom: Double = 14,
                colorLevels: [(Int, StyleColor)] = [(0, StyleColor(.blue))],
                clusterProperties: [String: Expression]? = nil) {
        self.clusterRadius = clusterRadius
        self.circleRadius = circleRadius
        self.textColor = textColor
        self.textSize = textSize
        self.textField = textField
        self.clusterMaxZoom = clusterMaxZoom
        self.colorLevels = colorLevels
        self.clusterProperties = clusterProperties
    }

    /// Radius of each cluster if clustering is enabled. A value of 512 indicates a radius equal
    /// to the width of a tile, 50 by default.
    var clusterRadius: Double

    /// The circle radius of the cluster items, 18 by default
    var circleRadius: Value<Double>

    /// The text color of cluster item, white by default
    var textColor: Value<StyleColor>

    /// The text size of cluster item, 12 by default.
    var textSize: Value<Double>

    /// The text field of a cluster item in expression, get("point_count") by default.
    var textField: Value<String>

    /// Max zoom on which to cluster points if clustering is enabled. Defaults to one zoom less
    /// than maxzoom (so that last zoom features are not clustered). Clusters are re-evaluated at integer zoom
    /// levels so setting clusterMaxZoom to 14 means the clusters will be displayed until z15.
    var clusterMaxZoom: Double

    /// The cluster color levels
    var colorLevels: [(Int, StyleColor)]

    /// An object defining custom properties on the generated clusters if clustering is enabled, aggregating values from
    /// clustered points. Has the form `{"property_name": [operator, map_expression]}`. `operator` is any expression function that accepts at
    /// least 2 operands (e.g. `"+"` or `"max"`) — it accumulates the property value from clusters/points the
    /// cluster contains; `map_expression` produces the value of a single point.
    ///
    /// Example: `{"sum": ["+", ["get", "scalerank"]]}`.
    ///
    /// For more advanced use cases, in place of `operator`, you can use a custom reduce expression
    /// that references a special `["accumulated"]` value, e.g.:
    /// `{"sum": [["+", ["accumulated"], ["get", "sum"]], ["get", "scalerank"]]}`
    var clusterProperties: [String: Expression]?
}
