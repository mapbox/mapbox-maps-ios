import SwiftUI
import MapboxMapsSwiftUI


@available(iOS 14.0, *)
struct CameraDebugView: View {
    var camera: CameraState

    var body: some View {
        VStack(alignment: .leading) {
            let latlon = String(format: "%.4f, %.4f", camera.center.latitude, camera.center.longitude)
            Text("\(latlon)")
            VStack(alignment: .leading) {
                Text("zoom: \(String(format: "%.2f", camera.zoom))")
                if camera.bearing != 0 {
                    Text("bearing: \(String(format: "%.2f", camera.bearing))")
                }
                if camera.pitch != 0 {
                    Text("pitch: \(String(format: "%.2f", camera.pitch))")
                }
            }.foregroundColor(.gray)
        }
        .foregroundColor(.primary)
        .font(.safeMonospaced)
    }
}

@available(iOS 14.0, *)
struct CameraDebugViewModifier: ViewModifier {
    var alignment: Alignment
    var camera: CameraState
    func body(content: Content) -> some View {
        content.safeOverlay(alignment: alignment) {
            CameraDebugView(camera: camera)
                .floating()
        }
    }
}

@available(iOS 14.0, *)
extension View {
    func cameraDebugOverlay(
        alignment: Alignment = .bottomTrailing,
        camera: CameraState) -> some  View {
            modifier(CameraDebugViewModifier(alignment: alignment, camera: camera))
    }
}

@available(iOS 14.0, *)
struct CameraDebugView_Preview: PreviewProvider {
    struct PreviewView: View {
        @State var camera = CameraState(
            center: .london,
            padding: .zero,
            zoom: 12,
            bearing: -0.76890,
            pitch: 32.77)
        var body: some View {
            CameraDebugView(camera: camera)
        }
    }
    static var previews: some View {
            PreviewView()
    }
}


