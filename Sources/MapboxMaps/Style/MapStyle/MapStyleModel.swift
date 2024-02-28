struct MapStyleModel {
    enum Light: Equatable {
        case flatLight(FlatLight)
        case threeDimensionLights(ambient: AmbientLight?, directional: DirectionalLight?)

        var ambientLight: AmbientLight? {
            guard case let .threeDimensionLights(ambient, _) = self else { return nil }
            return ambient
        }

        var directionalLight: DirectionalLight? {
            guard case let .threeDimensionLights(_, directional) = self else { return nil }
            return directional
        }

        var styleLightProperties: [[String: Any]]? {
            get throws {
                switch self {
                case let .flatLight(light): return try [light.allStyleProperties()]
                case let .threeDimensionLights(ambient?, directional?):
                    return try [ambient.allStyleProperties(), directional.allStyleProperties()]
                default: return nil
                }
            }
        }
    }
    var layers = [LayerWrapper]()
    var sources = [String: SourceWrapper]()
    var images = [String: StyleImage]()
    var models = [String: Model]()
    var terrain: Terrain?
    var atmosphere: Atmosphere?
    var light: Light?
    var projection: StyleProjection?
    var transition: TransitionOptions?
    var importConfigurations = [StyleImportConfiguration]()

    mutating func setLight(_ light: AmbientLight) {
        self.light = .threeDimensionLights(ambient: light, directional: self.light?.directionalLight)
    }

    mutating func setLight(_ light: DirectionalLight) {
        self.light = .threeDimensionLights(ambient: self.light?.ambientLight, directional: light)
    }

    mutating func setLight(_ light: FlatLight) {
        self.light = .flatLight(light)
    }
}

final class MapStyleContentVisitor {
    private(set) var id: [AnyHashable] = []
    var model = MapStyleModel()
}
