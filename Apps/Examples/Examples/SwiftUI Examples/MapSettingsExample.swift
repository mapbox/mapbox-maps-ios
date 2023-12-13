import SwiftUI
@_spi(Experimental) import MapboxMaps

struct Settings {
    var mapStyle: MapStyle = .standard
    var orientation: NorthOrientation = .upwards
    var gestureOptions: GestureOptions = .init()
    var cameraBounds: CameraBoundsOptions = .init()
    var constrainMode: ConstrainMode = .heightOnly
    var ornamentSettings = OrnamentSettings()
    var debugOptions: MapViewDebugOptions = [.camera]

    struct OrnamentSettings {
        var isScaleBarVisible = true
        var isCompassVisible = true
    }
}

@available(iOS 14.0, *)
struct MapSettingsExample : View {
    @State private var settingsOpened = false
    @State private var settings = Settings()

    var body: some View {
        Map(initialViewport: .camera(center: .berlin, zoom: 12))
            .cameraBounds(settings.cameraBounds)
            .mapStyle(settings.mapStyle)
            .gestureOptions(settings.gestureOptions)
            .gestureHandlers(gestureHandlers)
            .northOrientation(settings.orientation)
            .constrainMode(settings.constrainMode)
            .ornamentOptions(OrnamentOptions(
                scaleBar: ScaleBarViewOptions(visibility: settings.ornamentSettings.isScaleBarVisible ? .visible : .hidden),
                compass: CompassViewOptions(visibility: settings.ornamentSettings.isCompassVisible ? .visible : .hidden)
            ))
            .debugOptions(settings.debugOptions)
            .ignoresSafeArea()
            .sheet(isPresented: $settingsOpened) {
                SettingsView(settings: $settings)
                    .defaultDetents()
            }
            .safeOverlay(alignment: .trailing, content: {
                MapStyleSelectorButton(mapStyle: $settings.mapStyle)
            })
            .toolbar {
                Button("Settings") {
                    settingsOpened.toggle()
                }
            }
    }

    var gestureHandlers: MapGestureHandlers {
        MapGestureHandlers(
            onBegin: { type in print("Gesture begin: \(type)") },
            onEnd: { type, willAnimate in print("Gesture end: \(type), will animate: \(willAnimate)") },
            onEndAnimation: { type in print("Gesture end animation: \(type)") })
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
            Section {
                let options = [
                    ("Camera", MapViewDebugOptions.camera),
                    ("Padding", .padding),
                    ("Tile Borders", .tileBorders),
                    ("Parse Status", .parseStatus),
                    ("Timestamps", .timestamps),
                    ("Collision", .collision),
                    ("Overdraw", .overdraw),
                    ("Stencil Clip", .stencilClip),
                    ("Depth Buffer", .depthBuffer),
                    ("Model Bounds", .modelBounds),
                    ("Light", .light)
                ]
                ForEach(options, id: \.0) { option in
                    Toggle(option.0, isOn: $settings.debugOptions.contains(option: option.1))
                }

            } header: {
                Text("Debug Options")
            }
        }
    }
}

@available(iOS 13.0, *)
private extension Binding where Value: OptionSet {
    func contains(option: Value.Element) -> Binding<Bool> {
        Binding<Bool> {
            self.wrappedValue.contains(option)
        }
        set: {
            if $0 {
                self.wrappedValue.insert(option)
            } else {
                self.wrappedValue.remove(option)
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
