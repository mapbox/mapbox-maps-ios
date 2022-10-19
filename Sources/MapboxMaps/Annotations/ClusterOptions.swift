/// Options to show and configure point annotation clustering with using PointAnnotationManager.
///
/// It exposes a minimal of configuration options, a more advanced setup can be created manually with
/// using CircleLayer and SymbolLayers directly.

public struct ClusterOptions {

    /// Define a set of cluster options to determine how to cluster annotations.
    /// Providing clusterOptions when initializing a ``PointAnnotationManager``
    /// will turn on clustering for that ``PointAnnotationManager``.
    public init(clusterRadius: Double = 50,
                circleRadius: Value<Double> = .constant(18),
                textColor: Value<StyleColor> = .constant(StyleColor(.white)),
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
    /// to the width of a tile, 50 by default. Value must be greater than or equal to 0.
    var clusterRadius: Double

    /// The circle radius of the cluster items, 18 by default. Units in pixels.
    var circleRadius: Value<Double>

    /// The text color of cluster item, white by default
    var textColor: Value<StyleColor>

    /// The text size of cluster item, 12 by default. Units in pixels.
    var textSize: Value<Double>

    /// Value to use for a text label of the cluster. `get("point_count")` by default which
    /// will show the count of points in the cluster
    var textField: Value<String>

    /// Max zoom on which to cluster points if clustering is enabled. Defaults to one zoom less
    /// than maxzoom (so that last zoom features are not clustered). Clusters are re-evaluated at integer zoom
    /// levels so setting clusterMaxZoom to 14 means the clusters will be displayed until z15.
    var clusterMaxZoom: Double

    /// An array of tuples each representing a colorLevel
    /// Each colorLevel creates a new ``CircleLayer`` which groups individual points into clusters based on
    /// pointCount and styles them according to clusterColor.
    /// For example, a colorLevels array like this:
    /// `[(pointCount: 100, clusterColor: StyleColor(.red)), (pointCount: 50, clusterColor: StyleColor(.blue)), (pointCount: 0, clusterColor: StyleColor(.green))]`
    /// would create three CircleLayers: one with red circles for clusters with greater than 100 points;
    /// one with blue circles for clusters with 50-100 points;
    /// and one with green circles for clusters with fewer than 50 points.
    var colorLevels: [(pointCount: Int, clusterColor: StyleColor)]

    /// An object defining custom properties on the generated clusters if clustering is enabled, aggregating values from
    /// clustered points. Has the form `{"property_name": [operator, map_expression]}`.
    /// `operator` is any expression function that accepts at
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
