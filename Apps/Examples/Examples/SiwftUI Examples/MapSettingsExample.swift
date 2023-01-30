import SwiftUI
@_spi(Experimental) import MapboxMapsSwiftUI

struct Settings {
    var styleURI: StyleURI = .streets
    var orientation: NorthOrientation = .upwards
    var gestureOptions: GestureOptions = .init()
    var cameraBounds: CameraBoundsOptions = .init()
}

@available(iOS 14.0, *)
struct MapSettingsExample : View {
    @State private var camera = CameraState(center: .berlin, zoom: 12)

    @State private var settingsOpened = false
    @State private var settings = Settings()

    var body: some View {
        Map(camera: $camera, initialOptions: initialOptions)
            .cameraBounds(settings.cameraBounds)
            .styleURI(settings.styleURI)
            .gestureOptions(settings.gestureOptions)
            .edgesIgnoringSafeArea(.all)
            // Force full map reinitialization on every orientation change
            .id(settings.orientation)
            .sheet(isPresented: $settingsOpened) {
                SettingsView(settings: $settings)
                    .defaultDetents()
            }
            .cameraDebugOverlay(alignment: .topTrailing, camera: $camera)
            .toolbar {
                Button("Settings") {
                    settingsOpened.toggle()
                }
            }
    }

    func initialOptions() -> MapInitOptions {
        MapInitOptions(mapOptions: MapOptions(orientation: settings.orientation))
    }
}

@available(iOS 14.0, *)
struct SettingsView : View {
    @Binding var settings: Settings
    var body: some View {
        Form {
            Section {
                Picker(selection: $settings.styleURI, label: Text("Map Style")) {
                    Text("Streets").tag(StyleURI.streets)
                    Text("Outdoors").tag(StyleURI.outdoors)
                    Text("Dark").tag(StyleURI.dark)
                    Text("Light").tag(StyleURI.light)
                    Text("Satellite").tag(StyleURI.satellite)
                    Text("Satellite Streets").tag(StyleURI.satelliteStreets)
                    Text("Custom").tag(StyleURI.customStyle)
                }
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
            }.pickerStyle(.menu)
            Section {
                Toggle("Pan", isOn: $settings.gestureOptions.panEnabled)
                Toggle("Pinch", isOn: $settings.gestureOptions.pinchEnabled)
                Toggle("Rotate", isOn: $settings.gestureOptions.rotateEnabled)
            } header: {
                Text("Gestures")
            }
        }
    }
}

@available(iOS 14.0, *)
struct MapSettingsExample_Preveiw: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MapSettingsExample()
        }
    }
}
