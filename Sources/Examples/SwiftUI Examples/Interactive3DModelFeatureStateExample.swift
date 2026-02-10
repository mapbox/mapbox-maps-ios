import MapboxMaps
import SwiftUI
import Combine

/// Showcase interactive 3D model with feature-state driven updates.
/// Demonstrates using expressions and feature state to control model materials and nodes.
struct Interactive3DModelFeatureStateExample: View {
    @StateObject private var viewModel = VehicleViewModel()
    @State private var settingsHeight: CGFloat = 0

    private let sourceId = "3d-model-source"
    private let carModelKey = "car"

    var body: some View {
        MapReader { mapProxy in
            Map(
                initialViewport: .camera(
                    center: CLLocationCoordinate2D(latitude: 40.7155, longitude: -74.0132),
                    zoom: 19.4,
                    bearing: 35,
                    pitch: 60
                )
            ) {
                AmbientLight(id: "environment")
                    .intensity(0.4)

                DirectionalLight(id: "sun_light")
                    .castShadows(true)

                // Add model source with material and node override names
                ModelSource(id: sourceId)
                    .models([createCarModel()])

                // Add model layer with feature-state driven expressions
                ModelLayer(id: "3d-model-layer", source: sourceId)
                    .modelScale(x: 10, y: 10, z: 10)
                    .modelType(.locationIndicator)
                    .modelColor(
                        Exp(.match) {
                            Exp(.get) { "part" }
                            "lights_brakes"
                            Exp(.featureState) { "brake-light-color" }
                            "lights-brakes_reverse"
                            Exp(.featureState) { "brake-light-color" }
                            "lights_brakes_volume"
                            Exp(.featureState) { "brake-light-color" }
                            "lights-brakes_reverse_volume"
                            Exp(.featureState) { "brake-light-color" }
                            Exp(.featureState) { "vehicle-color" }
                        }
                    )
                    .modelColorMixIntensity(
                        Exp(.match) {
                            Exp(.get) { "part" }
                            "body"
                            1.0
                            "lights_brakes"
                            Exp(.featureState) { "brake-light-emission" }
                            "lights-brakes_reverse"
                            Exp(.featureState) { "brake-light-emission" }
                            "lights_brakes_volume"
                            Exp(.featureState) { "brake-light-emission" }
                            "lights-brakes_reverse_volume"
                            Exp(.featureState) { "brake-light-emission" }
                            0.0
                        }
                    )
                    .modelEmissiveStrength(
                        Exp(.match) {
                            Exp(.get) { "part" }
                            "lights_brakes"
                            Exp(.featureState) { "brake-light-emission" }
                            "lights_brakes_volume"
                            Exp(.featureState) { "brake-light-emission" }
                            "lights-brakes_reverse"
                            Exp(.featureState) { "brake-light-emission" }
                            "lights-brakes_reverse_volume"
                            Exp(.featureState) { "brake-light-emission" }
                            0.0
                        }
                    )
                    .modelOpacity(
                        Exp(.match) {
                            Exp(.get) { "part" }
                            "lights_brakes_volume"
                            Exp(.featureState) { "brake-light-emission" }
                            "lights-brakes_reverse_volume"
                            Exp(.featureState) { "brake-light-emission" }
                            1.0
                        }
                    )
                    .modelRotation(
                        Exp(.match) {
                            Exp(.get) { "part" }
                            "doors_front-left"
                            Exp(.featureState) { "doors-front-left" }
                            "doors_front-right"
                            Exp(.featureState) { "doors-front-right" }
                            "hood"
                            Exp(.featureState) { "hood" }
                            "trunk"
                            Exp(.featureState) { "trunk" }
                            [0.0, 0.0, 0.0]
                        }
                    )
            }
            .mapStyle(.standard(show3dObjects: false))
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                settingsPanel
                    .onChangeOfSize { settingsHeight = $0.height }
            }
            // Granular feature state updates - each property updates independently
            .onChange(of: viewModel.vehicleColor) { _ in
                updateVehicleColor(mapProxy: mapProxy)
            }
            .onChange(of: viewModel.brakeLights) { _ in
                updateBrakeLights(mapProxy: mapProxy)
            }
            .onChange(of: viewModel.doorsFrontLeft) { _ in
                updateLeftDoor(mapProxy: mapProxy)
            }
            .onChange(of: viewModel.doorsFrontRight) { _ in
                updateRightDoor(mapProxy: mapProxy)
            }
            .onChange(of: viewModel.hood) { _ in
                updateHood(mapProxy: mapProxy)
            }
            .onChange(of: viewModel.trunk) { _ in
                updateTrunk(mapProxy: mapProxy)
            }
        }
    }

    @ViewBuilder
    private var settingsPanel: some View {
        VStack(spacing: 10) {
            Text("Car Controls")
                .font(.headline)

            // Color picker row
            HStack {
                Text("Vehicle color")
                Spacer()
                Image(systemName: "paintpalette")
                ColorPicker("", selection: $viewModel.vehicleColor)
                    .labelsHidden()
            }

            // Trunk
            HStack(spacing: 12) {
                Text("Trunk")
                    .frame(width: 80, alignment: .leading)
                Slider(value: $viewModel.trunk, in: 0...1)
                Image(systemName: "car.side.rear.open")
            }

            // Hood
            HStack(spacing: 12) {
                Text("Hood")
                    .frame(width: 80, alignment: .leading)
                Slider(value: $viewModel.hood, in: 0...1)
                Image(systemName: "car.side.front.open")
            }

            // Front left door
            HStack(spacing: 12) {
                Text("Left door")
                    .frame(width: 80, alignment: .leading)
                Slider(value: $viewModel.doorsFrontLeft, in: 0...1)
                Image(systemName: "car.top.door.front.left.open")
            }

            // Front right door
            HStack(spacing: 12) {
                Text("Right door")
                    .frame(width: 80, alignment: .leading)
                Slider(value: $viewModel.doorsFrontRight, in: 0...1)
                Image(systemName: "car.top.door.front.right.open")
            }

            // Brake lights
            HStack(spacing: 12) {
                Text("Brake lights")
                    .frame(width: 80, alignment: .leading)
                Slider(value: $viewModel.brakeLights, in: 0...1)
                Image(systemName: "exclamationmark.brakesignal")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding()
    }

    private func createCarModel() -> Model {
        Model(
            id: carModelKey,
            uri: URL(string: "https://docs.mapbox.com/mapbox-gl-js/assets/ego_car.glb")!,
            position: [-74.0132, 40.7155],
            orientation: [0, 0, 0]
        )
        .materialOverrideNames([
            "body",
            "lights_brakes",
            "lights-brakes_reverse",
            "lights_brakes_volume",
            "lights-brakes_reverse_volume"
        ])
        .nodeOverrideNames([
            "doors_front-left",
            "doors_front-right",
            "hood",
            "trunk"
        ])
    }

    private func updateVehicleColor(mapProxy: MapProxy) {
        mapProxy.map?.setFeatureState(
            sourceId: sourceId,
            sourceLayerId: nil,
            featureId: carModelKey,
            state: ["vehicle-color": StyleColor(viewModel.vehicleColor).rawValue]
        ) { _ in }
    }

    private func updateBrakeLights(mapProxy: MapProxy) {
        mapProxy.map?.setFeatureState(
            sourceId: sourceId,
            sourceLayerId: nil,
            featureId: carModelKey,
            state: ["brake-light-emission": viewModel.brakeLights]
        ) { _ in }
    }

    private func updateLeftDoor(mapProxy: MapProxy) {
        let doorOpeningDegMax = 80.0

        mapProxy.map?.setFeatureState(
            sourceId: sourceId,
            sourceLayerId: nil,
            featureId: carModelKey,
            state: [
                "doors-front-left": [
                    0.0,
                    mix(viewModel.doorsFrontLeft, 0.0, -doorOpeningDegMax),
                    0.0
                ]
            ]
        ) { _ in }
    }

    private func updateRightDoor(mapProxy: MapProxy) {
        let doorOpeningDegMax = 80.0

        mapProxy.map?.setFeatureState(
            sourceId: sourceId,
            sourceLayerId: nil,
            featureId: carModelKey,
            state: [
                "doors-front-right": [
                    0.0,
                    mix(viewModel.doorsFrontRight, 0.0, doorOpeningDegMax),
                    0.0
                ]
            ]
        ) { _ in }
    }

    private func updateHood(mapProxy: MapProxy) {
        mapProxy.map?.setFeatureState(
            sourceId: sourceId,
            sourceLayerId: nil,
            featureId: carModelKey,
            state: [
                "hood": [
                    mix(viewModel.hood, 0.0, 45.0),
                    0.0,
                    0.0
                ]
            ]
        ) { _ in }
    }

    private func updateTrunk(mapProxy: MapProxy) {
        mapProxy.map?.setFeatureState(
            sourceId: sourceId,
            sourceLayerId: nil,
            featureId: carModelKey,
            state: [
                "trunk": [
                    mix(viewModel.trunk, 0.0, -60.0),
                    0.0,
                    0.0
                ]
            ]
        ) { _ in }
    }

    // Helper function to mix values (linear interpolation)
    private func mix(_ t: Double, _ a: Double, _ b: Double) -> Double {
        return b * t - a * (t - 1)
    }
}

private final class VehicleViewModel: ObservableObject {
    @Published var doorsFrontLeft: Double = 0.5
    @Published var doorsFrontRight: Double = 0.0
    @Published var trunk: Double = 0.0
    @Published var hood: Double = 0.0
    @Published var brakeLights: Double = 0.0
    @Published var vehicleColor: Color = .white
}
