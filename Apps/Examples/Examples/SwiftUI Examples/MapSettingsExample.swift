import SwiftUI
@_spi(Experimental) import MapboxMapsSwiftUI

struct Settings {
    var styleURI: StyleURI = .streetsV12
    var orientation: NorthOrientation = .upwards
    var gestureOptions: GestureOptions = .init()
    var cameraBounds: CameraBoundsOptions = .init()
    var constrainMode: ConstrainMode = .heightOnly
}

@available(iOS 14.0, *)
struct MapSettingsExample : View {
    @State private var camera = CameraState(center: .berlin, zoom: 12)

    @State private var settingsOpened = false
    @State private var settings = Settings()

    var body: some View {
        Map(camera: $camera)
            .cameraBounds(settings.cameraBounds)
            .styleURI(settings.styleURI)
            .gestureOptions(settings.gestureOptions)
            .northOrientation(settings.orientation)
            .constrainMode(settings.constrainMode)
            .ignoresSafeArea()
            .sheet(isPresented: $settingsOpened) {
                SettingsView(settings: $settings)
                    .defaultDetents()
            }
            .cameraDebugOverlay(alignment: .bottom, camera: $camera)
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
                Picker(selection: $settings.styleURI, label: Text("Map Style")) {
                    Text("Streets v12").tag(StyleURI.streetsV12)
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
