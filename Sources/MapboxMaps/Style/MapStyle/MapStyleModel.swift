struct MapStyleModel {
    var layers = [String: LayerWrapper]()
    var sources = [String: SourceWrapper]()
    var images = [String: StyleImage]()
    var terrain: Terrain?
    var atmosphere: Atmosphere?
    var projection: StyleProjection?
    var transition: TransitionOptions?
    var importConfigurations = [StyleImportConfiguration]()
}

final class MapStyleContentVisitor {
    private(set) var id: [AnyHashable] = []
    var model = MapStyleModel()
}
