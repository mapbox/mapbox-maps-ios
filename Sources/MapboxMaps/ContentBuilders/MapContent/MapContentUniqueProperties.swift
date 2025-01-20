@_implementationOnly import MapboxCommon_Private
import os

/// The style properties that can be applied once in the whole style.
/// If multiple properties are applied, the last wins.
struct MapContentUniqueProperties: Decodable {
    struct Lights: Encodable, Equatable {
        var flat: FlatLight?
        var directional: DirectionalLight?
        var ambient: AmbientLight?
    }

    var terrain: Terrain?
    var atmosphere: Atmosphere?
    var projection: StyleProjection?
    var snow: Snow?
    var rain: Rain?
    var colorTheme: ColorTheme?
    var transition: TransitionOptions?
    var location: LocationOptions?

    var lights = Lights()

    private func update<T: Equatable & Encodable>(_ label: String, old: T?, new: T?, initial: T?, setter: (Any) -> Expected<NSNull, NSString>) {
        guard old != new else { return }
        wrapStyleDSLError {
            let value: Any
            if let new {
                os_log(.debug, log: .contentDSL, "set %s", label)
                value = try new.toJSON()
            } else {
                os_log(.debug, log: .contentDSL, "set back to initial %s", label)
                value = try initial.toJSON()
            }
            try handleExpected {
                setter(value)
            }
        }
    }

    func update(from old: Self, style: StyleManagerProtocol, initial: Self?, locationManager: LocationManager?) {
        update("atmosphere", old: old.atmosphere, new: atmosphere, initial: initial?.atmosphere, setter: style.setStyleAtmosphereForProperties(_:))
        update("projection", old: old.projection, new: projection, initial: initial?.projection, setter: style.setStyleProjectionForProperties(_:))
        update("terrain", old: old.terrain, new: terrain, initial: initial?.terrain, setter: style.setStyleTerrainForProperties(_:))
        update("snow", old: old.snow, new: snow, initial: initial?.snow, setter: style.setStyleSnowForProperties(_:))
        update("rain", old: old.rain, new: rain, initial: initial?.rain, setter: style.setStyleRainForProperties(_:))
        lights.update(from: old.lights, style: style, initialLights: initial?.lights)
        update(from: old.colorTheme, to: colorTheme, style: style)

        if old.location != location {
            locationManager?.options = location ?? LocationOptions()
        }

        if old.transition != transition {
            wrapStyleDSLError {
                let transitionToSet: TransitionOptions = transition ?? initial?.transition ?? TransitionOptions()
                style.setStyleTransitionFor(transitionToSet.coreOptions)
            }
        }
    }
}

extension MapContentUniqueProperties {
    enum CodingKeys: String, CodingKey {
        case terrain
        case atmosphere = "fog"
        case projection
        case snow
        case rain
        case lights = "lights"
    }

    /// Decode  from a StyleJSON
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.terrain = try container.decodeIfPresent(Terrain.self, forKey: .terrain)
        self.atmosphere = try container.decodeIfPresent(Atmosphere.self, forKey: .atmosphere)
        self.projection = try container.decodeIfPresent(StyleProjection.self, forKey: .projection)
        self.snow = try container.decodeIfPresent(Snow.self, forKey: .snow)
        self.rain = try container.decodeIfPresent(Rain.self, forKey: .rain)
        if var lightContainer = try? container.nestedUnkeyedContainer(forKey: .lights) {
            while !lightContainer.isAtEnd {
                var lightInfoContainer = lightContainer
                let lightInfo = try lightInfoContainer.decode(LightInfo.self)

                switch lightInfo.type {
                case .ambient:
                    lights.ambient = try? lightContainer.decode(AmbientLight.self)
                case .directional:
                    lights.directional = try? lightContainer.decode(DirectionalLight.self)
                case .flat:
                    lights.flat = try? lightContainer.decode(FlatLight.self)
                default:
                    Log.warning("Incorrect light configuration. Specify both directional and ambient lights OR flat light.", category: "StyleDSL")
                }
            }
        }
    }
}

private extension MapContentUniqueProperties {
    func update(from oldColorTheme: ColorTheme?, to newColorTheme: ColorTheme?, style: StyleManagerProtocol) {
        wrapStyleDSLError {
            if newColorTheme != oldColorTheme {
                if let newColorTheme {
                    try handleExpected { style.setStyleColorThemeFor(newColorTheme.core) }
                } else {
                    style.setInitialStyleColorTheme()
                }
            }
        }
    }
}

private extension MapContentUniqueProperties.Lights {
    func update(from old: Self, style: StyleManagerProtocol, initialLights: Self?) {
        if self != old {
            wrapStyleDSLError {
                if let directional = directional, let ambient = ambient {
                    os_log(.debug, log: .contentDSL, "set 3d lights")
                    try style.setLights(ambient: ambient, directional: directional)
                } else if directional != nil || ambient != nil {
                    Log.warning("Incorrect 3D light configuration. Specify both directional and ambient lights.", category: "StyleDSL")
                } else if let flat = flat {
                    os_log(.debug, log: .contentDSL, "set flat light")
                    try style.setLights(flat)
                } else {
                    os_log(.debug, log: .contentDSL, "set initial lights")
                    try setInitialLights(style: style, initialLights: initialLights)
                }
            }
        }
    }

    func setInitialLights(style: StyleManagerProtocol, initialLights: Self?) throws {
        if let initialDirectional = initialLights?.directional,
           let initialAmbient = initialLights?.ambient {
            os_log(.debug, log: .contentDSL, "re-set initial 3d lights")
            try style.setLights(ambient: initialAmbient, directional: initialDirectional)
        } else if let initialFlat = initialLights?.flat {
            os_log(.debug, log: .contentDSL, "re-set initial flat lights")
            try style.setLights(initialFlat)
        } else {
            os_log(.debug, log: .contentDSL, "remove lights")
            try handleExpected { style.setStyleLightsForLights(NSNull()) }
        }
    }
}
