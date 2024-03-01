@_implementationOnly import MapboxCommon_Private
import os

/// The style properties that can be applied once in the whole style.
/// If multiple properties are applied, the last wins.
struct MapStyleUniqueProperties {
    struct Lights: Encodable, Equatable {
        var flat: FlatLight?
        var directional: DirectionalLight?
        var ambient: AmbientLight?
    }

    var terrain: Terrain?
    var atmosphere: Atmosphere?
    var projection: StyleProjection?
    var lights = Lights()

    private func update<T: Equatable & Encodable>(_ label: String, old: T?, new: T?, setter: (Any) -> Expected<NSNull, NSString>) {
        guard old != new else { return }
        wrapStyleDSLError {
            let value: Any
            if let new {
                os_log(.debug, log: .styleDsl, "set %s", label)
                value = try new.toJSON()
            } else {
                os_log(.debug, log: .styleDsl, "remove %s", label)
                value = NSNull()
            }
            try handleExpected {
                setter(value)
            }
        }
    }

    func update(from old: Self, style: StyleManagerProtocol) {
        update("atmosphere", old: old.atmosphere, new: atmosphere, setter: style.setStyleAtmosphereForProperties(_:))
        update("projection", old: old.projection, new: projection, setter: style.setStyleProjectionForProperties(_:))
        update("terrain", old: old.terrain, new: terrain, setter: style.setStyleTerrainForProperties(_:))

        guard old.lights != lights else { return }

        wrapStyleDSLError {
            if let directional = lights.directional, let ambient = lights.ambient {
                os_log(.debug, log: .styleDsl, "set 3d lights")
                try style.setLights(ambient: ambient, directional: directional)
            } else if lights.directional != nil || lights.ambient != nil {
                Log.warning(forMessage: "Incorrect 3D light configuration. Specify both directional and ambient lights.", category: "StyleDSL")
            } else if let flat = lights.flat {
                os_log(.debug, log: .styleDsl, "set flat light")
                try style.setLights(flat)
            } else {
                os_log(.debug, log: .styleDsl, "remove lights")
                try handleExpected { style.setStyleLightsForLights(NSNull()) }
            }
        }
    }
}
