import MapboxMaps
import SwiftUI

struct Animated3DModelSourceExample: View {
    @State private var airplane = Airplane()
    @State private var flightRoute: FlightRoute?
    @State private var animationPhase: Double = 0
    @State private var displayLink: DisplayLink?
    @State private var viewport: Viewport = .camera(
        center: CLLocationCoordinate2D(latitude: 37.6199, longitude: -122.3721),
        zoom: 17.457,
        bearing: 141.62,
        pitch: 70.58
    )

    private let sourceId = "3d-model-source"
    private let planeModelKey = "plane"
    private let flightPathSourceId = "flightpath"

    var body: some View {
        MapReader { mapProxy in
            Map(viewport: $viewport) {
                // Flight path line
                GeoJSONSource(id: flightPathSourceId)
                    .data(.url(URL(string: Constants.flightPathJsonUri)!))

                LineLayer(id: "flight-path-line", source: flightPathSourceId)
                    .lineColor(.init(UIColor(red: 0, green: 124/255, blue: 191/255, alpha: 1)))
                    .lineWidth(8.0)
                    .lineEmissiveStrength(1.0)
                    .lineCap(.round)
                    .lineJoin(.round)

                ModelSource(id: sourceId)
                    .models([createAirplaneModel()])

                ModelLayer(id: "3d-model-layer", source: sourceId)
                    .modelType(.locationIndicator)
                    .modelTranslation(
                        Exp(arguments:
                                [.number(0), .number(0), .stringArray(["feature-state", "z-elevation"])]
                           )
                    )
                    .modelScale(
                        Exp(.interpolate) {
                            Exp(.exponential) { 0.5 }
                            Exp(.zoom)
                            2.0
                            [40000.0, 40000.0, 40000.0]
                            16.0
                            [1.0, 1.0, 1.0]
                        }
                    )
                    .modelRotation(
                        Exp(.match) {
                            Exp(.get) { "part" }
                            // Gears
                            "front_gear"
                            Exp(.featureState) { "front-gear-rotation" }
                            "rear_gears"
                            Exp(.featureState) { "rear-gear-rotation" }
                            // Propellers
                            "propeller_left_outer"
                            Exp(.featureState) { "propeller-rotation" }
                            "propeller_left_inner"
                            Exp(.featureState) { "propeller-rotation" }
                            "propeller_right_outer"
                            Exp(.featureState) { "propeller-rotation" }
                            "propeller_right_inner"
                            Exp(.featureState) { "propeller-rotation" }
                            // Blurred propellers
                            "propeller_left_outer_blur"
                            Exp(.featureState) { "propeller-rotation-blur" }
                            "propeller_left_inner_blur"
                            Exp(.featureState) { "propeller-rotation-blur" }
                            "propeller_right_outer_blur"
                            Exp(.featureState) { "propeller-rotation-blur" }
                            "propeller_right_inner_blur"
                            Exp(.featureState) { "propeller-rotation-blur" }
                            [0.0, 0.0, 0.0]
                        }
                    )
                    .modelEmissiveStrength(
                        Exp(.match) {
                            Exp(.get) { "part" }
                            "lights_position_white"
                            Exp(.featureState) { "light-emission-strobe" }
                            "lights_position_white_volume"
                            Exp(.featureState) { "light-emission-strobe" }
                            "lights_anti_collision_red"
                            Exp(.featureState) { "light-emission-strobe" }
                            "lights_anti_collision_red_volume"
                            Exp(.featureState) { "light-emission-strobe" }
                            "lights_position_red"
                            Exp(.featureState) { "light-emission" }
                            "lights_position_red_volume"
                            Exp(.featureState) { "light-emission" }
                            "lights_position_green"
                            Exp(.featureState) { "light-emission" }
                            "lights_position_green_volume"
                            Exp(.featureState) { "light-emission" }
                            "lights_taxi_white"
                            Exp(.featureState) { "light-emission-taxi" }
                            "lights_taxi_white_volume"
                            Exp(.featureState) { "light-emission-taxi" }
                            0.0
                        }
                    )
                    .modelOpacity(
                        Exp(.match) {
                            Exp(.get) { "part" }
                            "lights_position_white_volume"
                            Exp(.product) {
                                Exp(.featureState) { "light-emission-strobe" }
                                0.25
                            }
                            "lights_anti_collision_red_volume"
                            Exp(.product) {
                                Exp(.featureState) { "light-emission-strobe" }
                                0.45
                            }
                            "lights_position_green_volume"
                            Exp(.product) {
                                Exp(.featureState) { "light-emission" }
                                0.25
                            }
                            "lights_position_red_volume"
                            Exp(.product) {
                                Exp(.featureState) { "light-emission" }
                                0.25
                            }
                            "lights_taxi_white"
                            Exp(.product) {
                                Exp(.featureState) { "light-emission-taxi" }
                                0.25
                            }
                            "lights_taxi_white_volume"
                            Exp(.product) {
                                Exp(.featureState) { "light-emission-taxi" }
                                0.25
                            }
                            "propeller_blur"
                            0.2
                            1.0
                        }
                    )
            }
            .debugOptions(.camera)
            .mapStyle(.standard(lightPreset: .dusk, showPointOfInterestLabels: false, showRoadLabels: false))
            .onStyleLoaded { _ in
                startAnimation(mapProxy: mapProxy)
            }
            .task {
                loadFlightRoute { route in
                    flightRoute = route
                }
            }
            .onDisappear {
                displayLink = nil
            }
            .ignoresSafeArea()
        }
    }

    private func createAirplaneModel() -> Model {
        Model(
            id: planeModelKey,
            uri: URL(string: Constants.airplaneModelUri)!,
            position: airplane.position,
            orientation: [airplane.roll, airplane.pitch, airplane.bearing + 90.0]
        )
        .materialOverrideNames(Constants.materialOverrideNames)
        .nodeOverrideNames(Constants.nodeOverrideNames)
    }

    private func startAnimation(mapProxy: MapProxy) {
        guard let map = mapProxy.map else { return }

        displayLink = DisplayLink { deltaTime in
            guard let route = flightRoute else { return }

            let routeElevation = airplane.altitude
            let animFade = Self.clamp((routeElevation - Constants.flightTravelAltitudeMin) /
                                      (Constants.flightTravelAltitudeMax - Constants.flightTravelAltitudeMin))

            let timelapseFactor = Self.mix(0.001, 10.0, animFade * animFade)
            animationPhase += (deltaTime * timelapseFactor) / Constants.animationDuration

            if animationPhase > 1.0 {
                animationPhase = 0
            }

            if let target = route.sample(distance: route.totalLength * animationPhase) {
                airplane = airplane.update(target: target, dtimeMs: deltaTime * 1000.0)

                updateCamera(map: map)
                updateFeatureState(map: map)
            }
        }
    }

    private func updateCamera(map: MapboxMap) {
        let animFade = Self.clamp((airplane.altitude - Constants.flightTravelAltitudeMin) /
                                  (Constants.flightTravelAltitudeMax - Constants.flightTravelAltitudeMin))

        let cameraOffsetLng = Self.mix(-0.003, 0.0, airplane.altitude / 200.0)
        let cameraOffsetLat = Self.mix(0.003, 0.0, airplane.altitude / 200.0)
        let cameraAltitude = airplane.altitude + 150.0 + Self.mix(0.0, 10000000.0, animFade)

        let cameraLocation = CLLocationCoordinate2D(
            latitude: airplane.position[1] + cameraOffsetLat,
            longitude: airplane.position[0] + cameraOffsetLng
        )
        let targetLocation = CLLocationCoordinate2D(
            latitude: airplane.position[1],
            longitude: airplane.position[0]
        )

        let freeCameraOptions = map.freeCameraOptions
        freeCameraOptions.location = cameraLocation
        freeCameraOptions.altitude = cameraAltitude
        freeCameraOptions.lookAtPoint(forLocation: targetLocation, altitude: airplane.altitude)

        map.freeCameraOptions = freeCameraOptions

        print("Camera: location=(\(cameraLocation.latitude), \(cameraLocation.longitude)), altitude=\(cameraAltitude), bearing=\(map.cameraState.bearing), pitch=\(map.cameraState.pitch), zoom=\(map.cameraState.zoom)")
    }

    private func updateFeatureState(map: MapboxMap) {
        let featureState: [String: Any] = [
            "z-elevation": airplane.altitude,
            "front-gear-rotation": [0.0, 0.0, airplane.frontGearRotation],
            "rear-gear-rotation": [0.0, 0.0, airplane.rearGearRotation],
            "propeller-rotation": [
                0.0,
                0.0,
                -(airplane.animTimeS.truncatingRemainder(dividingBy: 0.5)) * 2.0 * 360.0
            ],
            "propeller-rotation-blur": [
                0.0,
                0.0,
                (airplane.animTimeS.truncatingRemainder(dividingBy: 0.1)) * 10.0 * 360.0
            ],
            "light-emission": airplane.lightPhase,
            "light-emission-strobe": airplane.lightPhaseStrobe,
            "light-emission-taxi": airplane.lightTaxiPhase
        ]

        map.setFeatureState(
            sourceId: sourceId,
            sourceLayerId: nil,
            featureId: planeModelKey,
            state: featureState, callback: { _ in }
        )
    }

    private func loadFlightRoute(completion: @escaping (FlightRoute) -> Void) {
        URLSession.shared.dataTask(with: URL(string: Constants.flightPathJsonUri)!) { data, _, error in
            guard let data = data, error == nil else { return }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let features = json?["features"] as? [[String: Any]],
                      let firstFeature = features.first,
                      let geometry = firstFeature["geometry"] as? [String: Any],
                      let coordinates = geometry["coordinates"] as? [[Double]],
                      let properties = firstFeature["properties"] as? [String: Any],
                      let elevation = properties["elevation"] as? [Double] else { return }

                let route = FlightRoute(coordinates: coordinates, elevation: elevation)
                DispatchQueue.main.async {
                    completion(route)
                }
            } catch {
                print("Error parsing flight route: \(error)")
            }
        }.resume()
    }

    static func clamp(_ value: Double) -> Double {
        max(0.0, min(value, 1.0))
    }

    static func mix(_ a: Double, _ b: Double, _ t: Double) -> Double {
        let f = clamp(t)
        return a * (1 - f) + b * f
    }
}

// MARK: - Data Models

private struct Airplane {
    var position: [Double] = [-122.37204647633236, 37.619836883832306]
    var altitude: Double = 0.0
    var bearing: Double = -60.0
    var pitch: Double = 0.0
    var roll: Double = 0.0
    var rearGearRotation: Double = 0.0
    var frontGearRotation: Double = 0.0
    var lightPhase: Double = 0.0
    var lightPhaseStrobe: Double = 0.0
    var lightTaxiPhase: Double = 0.0
    var animTimeS: Double = 0.0

    func update(target: RoutePoint, dtimeMs: Double) -> Airplane {
        let newAnimTimeS = animTimeS + dtimeMs / 1000.0
        return Airplane(
            position: [
                Animated3DModelSourceExample.mix(position[0], target.position[0], dtimeMs * 0.05),
                Animated3DModelSourceExample.mix(position[1], target.position[1], dtimeMs * 0.05)
            ],
            altitude: Animated3DModelSourceExample.mix(altitude, target.altitude, dtimeMs * 0.05),
            bearing: Animated3DModelSourceExample.mix(bearing, target.bearing, dtimeMs * 0.01),
            pitch: Animated3DModelSourceExample.mix(pitch, target.pitch, dtimeMs * 0.01),
            roll: (Animated3DModelSourceExample.mix(0.0, sin(newAnimTimeS * .pi * 0.2) * 0.1, (altitude - 50.0) / 100.0)) * 180.0 / .pi, rearGearRotation: Animated3DModelSourceExample.mix(0.0, -90.0, altitude / 50.0), frontGearRotation: Animated3DModelSourceExample.mix(0.0, 90.0, altitude / 50.0),
            lightPhase: animSinPhaseFromTime(newAnimTimeS, 2.0) * 0.25 + 0.75,
            lightPhaseStrobe: animSinPhaseFromTime(newAnimTimeS, 1.0),
            lightTaxiPhase: Animated3DModelSourceExample.mix(1.0, 0.0, altitude / 100.0),
            animTimeS: newAnimTimeS
        )
    }

    private func animSinPhaseFromTime(_ animTimeS: Double, _ phaseLen: Double) -> Double {
        return sin(((animTimeS.truncatingRemainder(dividingBy: phaseLen)) / phaseLen) * .pi * 2.0) * 0.5 + 0.5
    }
}

private struct RoutePoint {
    let position: [Double]
    let altitude: Double
    let bearing: Double
    let pitch: Double
}

private struct FlightRoute {
    let coordinates: [[Double]]
    let elevation: [Double]
    let distances: [Double]
    let maxElevation: Double

    var totalLength: Double {
        distances.last ?? 0.0
    }

    init(coordinates: [[Double]], elevation: [Double]) {
        self.coordinates = coordinates
        self.elevation = elevation

        var distances: [Double] = [0.0]
        var maxElevation = elevation[0]

        for i in 1..<coordinates.count {
            let p1 = coordinates[i - 1]
            let p2 = coordinates[i]

            // Simple distance calculation (not accurate for long distances but sufficient for this demo)
            let dlat = p2[1] - p1[1]
            let dlng = p2[0] - p1[0]
            let segmentDistance = sqrt(dlat * dlat + dlng * dlng) * 111000.0 // Rough conversion to meters

            distances.append(distances[i - 1] + segmentDistance)
            maxElevation = max(maxElevation, elevation[i])
        }

        self.distances = distances
        self.maxElevation = maxElevation
    }

    func sample(distance: Double) -> RoutePoint? {
        guard !distances.isEmpty else { return nil }

        var segmentIndex = distances.firstIndex { $0 >= distance } ?? 0
        segmentIndex = max(0, segmentIndex - 1)
        segmentIndex = min(coordinates.count - 2, segmentIndex)

        let p1 = coordinates[segmentIndex]
        let p2 = coordinates[segmentIndex + 1]
        let segmentLength = distances[segmentIndex + 1] - distances[segmentIndex]
        let segmentRatio = (distance - distances[segmentIndex]) / segmentLength

        let e1 = elevation[segmentIndex]
        let e2 = elevation[segmentIndex + 1]
        let altitude = e1 + (e2 - e1) * segmentRatio

        let bearing = atan2(p2[0] - p1[0], p2[1] - p1[1]) * 180.0 / .pi
        let pitch = atan2(e2 - e1, segmentLength) * 180.0 / .pi

        return RoutePoint(
            position: [
                p1[0] + (p2[0] - p1[0]) * segmentRatio,
                p1[1] + (p2[1] - p1[1]) * segmentRatio
            ],
            altitude: altitude,
            bearing: bearing,
            pitch: pitch
        )
    }
}

// MARK: - DisplayLink Helper

private class DisplayLink {
    private var displayLink: CADisplayLink?
    private var callback: (Double) -> Void
    private var lastTimestamp: CFTimeInterval = 0

    private class WeakProxy {
        weak var target: DisplayLink?

        init(target: DisplayLink) {
            self.target = target
        }

        @objc func frame(displayLink: CADisplayLink) {
            target?.frame(displayLink: displayLink)
        }
    }

    init(callback: @escaping (Double) -> Void) {
        self.callback = callback
        let proxy = WeakProxy(target: self)
        self.displayLink = CADisplayLink(target: proxy, selector: #selector(WeakProxy.frame(displayLink:)))
        self.displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func frame(displayLink: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = displayLink.timestamp
        }

        let deltaTime = displayLink.timestamp - lastTimestamp
        lastTimestamp = displayLink.timestamp

        callback(deltaTime)
    }

    deinit {
        displayLink?.invalidate()
    }
}

// MARK: - Constants

private enum Constants {
    static let flightPathJsonUri = "https://docs.mapbox.com/mapbox-gl-js/assets/flightpath.json"
    static let airplaneModelUri = "https://docs.mapbox.com/mapbox-gl-js/assets/airplane.glb"
    static let animationDuration: TimeInterval = 50.0
    static let flightTravelAltitudeMin: Double = 200.0
    static let flightTravelAltitudeMax: Double = 3000.0

    static let materialOverrideNames = [
        "propeller_blur",
        "lights_position_white",
        "lights_position_white_volume",
        "lights_position_red",
        "lights_position_red_volume",
        "lights_position_green",
        "lights_position_green_volume",
        "lights_anti_collision_red",
        "lights_anti_collision_red_volume",
        "lights_taxi_white",
        "lights_taxi_white_volume"
    ]

    static let nodeOverrideNames = [
        "front_gear",
        "rear_gears",
        "propeller_left_inner",
        "propeller_left_outer",
        "propeller_right_inner",
        "propeller_right_outer",
        "propeller_left_inner_blur",
        "propeller_left_outer_blur",
        "propeller_right_inner_blur",
        "propeller_right_outer_blur"
    ]
}
