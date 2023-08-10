import SwiftUI
@_spi(Experimental) import MapboxMaps

struct Settings {
    var mapStyle: MapStyle = .standard
    var orientation: NorthOrientation = .upwards
    var gestureOptions: GestureOptions = .init()
    var cameraBounds: CameraBoundsOptions = .init()
    var constrainMode: ConstrainMode = .heightOnly
    var ornamentSettings = OrnamentSettings()

    struct OrnamentSettings {
        var isScaleBarVisible = true
        var isCompassVisible = true
    }
}

@available(iOS 14.0, *)
struct MapSettingsExample : View {
    @State private var cameraState = CameraState(center: .berlin, padding: .zero, zoom: 12, bearing: 0, pitch: 0)
    @State private var settingsOpened = false
    @State private var settings = Settings()

    var body: some View {
        Map(initialViewport: .camera(center: .berlin, zoom: 12))
            .cameraBounds(settings.cameraBounds)
            .mapStyle(settings.mapStyle)
            .gestureOptions(settings.gestureOptions)
            .northOrientation(settings.orientation)
            .constrainMode(settings.constrainMode)
            .ornamentOptions(OrnamentOptions(
                scaleBar: ScaleBarViewOptions(visibility: settings.ornamentSettings.isScaleBarVisible ? .visible : .hidden),
                compass: CompassViewOptions(visibility: settings.ornamentSettings.isCompassVisible ? .visible : .hidden)
            ))
            .onCameraChanged { event in
                // NOTE: updating camera @State on every camera change is not recommended
                // because it will lead to body re-evaluation on every frame if user drags the map.
                // Here it is used for demonstration purposes.
                cameraState = event.cameraState
            }
            .ignoresSafeArea()
            .sheet(isPresented: $settingsOpened) {
                SettingsView(settings: $settings)
                    .defaultDetents()
            }
            .cameraDebugOverlay(alignment: .bottom, camera: cameraState)
            .safeOverlay(alignment: .trailing, content: {
                MapStyleSelectorButton(mapStyle: $settings.mapStyle)
            })
            .toolbar {
                Button("Settings") {
                    settingsOpened.toggle()
                }
            }
    }
}

@available(iOS 14.0, *)
struct SettingsView : View {
    @Binding var settings: Settings
    var body: some View {
        Form {
            Section {
                Picker(selection: $settings.cameraBounds, label: Text("Camera Bounds")) {
                    Text("World").tag(CameraBoundsOptions.world)
                    Text("Iceland").tag(CameraBoundsOptions.iceland)
                }
                HStack {
                    Text("Orientation")
                    Picker("orientation", selection: $settings.orientation) {
                        Text("Up").tag(NorthOrientation.upwards)
                        Text("Down").tag(NorthOrientation.downwards)
                        Text("Left").tag(NorthOrientation.rightwards)
                        Text("Right").tag(NorthOrientation.leftwards)
                    }
                    .pickerStyle(.segmented)
                }
                HStack {
                    Text("Constrain Mode")
                    Picker("constrain mode", selection: $settings.constrainMode) {
                        Text("Height").tag(ConstrainMode.heightOnly)
                        Text("Width+Height").tag(ConstrainMode.widthAndHeight)
                        Text("None").tag(ConstrainMode.none)
                    }
                    .pickerStyle(.segmented)
                }
            }.pickerStyle(.menu)
            Section {
                Toggle("Pan", isOn: $settings.gestureOptions.panEnabled)
                Toggle("Pinch", isOn: $settings.gestureOptions.pinchEnabled)
                Toggle("Rotate", isOn: $settings.gestureOptions.rotateEnabled)
            } header: {
                Text("Gestures")
            }
            Section {
                Toggle("Show Scale Bar", isOn: $settings.ornamentSettings.isScaleBarVisible)
                Toggle("Show Compass", isOn: $settings.ornamentSettings.isCompassVisible)
            } header: {
                Text("Ornaments")
            }
        }
    }
}

@available(iOS 15.0, *)
struct MapSettingsExample_Preveiw: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MapSettingsExample()
        }
    }
}
