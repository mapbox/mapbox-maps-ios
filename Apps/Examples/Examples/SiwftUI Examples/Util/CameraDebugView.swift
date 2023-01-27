import SwiftUI
import MapboxMapsSwiftUI

@available(iOS 14.0, *)
struct CameraDebugView: View {
    @Binding var camera: CameraState

    var body: some View {
        VStack(alignment: .leading) {
            let latlon = String(format: "%.4f, %.4f", camera.center.latitude, camera.center.longitude)
            Text("\(latlon)")
            VStack(alignment: .leading) {
                Text("zoom: \(String(format: "%.2f", camera.zoom))")
                Text("bearing: \(String(format: "%.2f", camera.bearing))")
                Text("pitch: \(String(format: "%.2f", camera.pitch))")
            }.foregroundColor(.gray)
        }
        .font(.footnote.safeMonospaced())
        .padding(5)
        .background(
            RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
                .fill(.background)
                .shadow(radius: 1.4, y: 0.7)
        )
        .padding(5)
    }
}

@available(iOS 14.0, *)
struct CameraDebugViewModifier: ViewModifier {
    var alignment: Alignment
    @Binding var camera: CameraState
    func body(content: Content) -> some View {
        content.safeOverlay(alignment: alignment) {
            CameraDebugView(camera: $camera)
        }
    }
}

@available(iOS 14.0, *)
extension View {
    func cameraDebugOverlay(
        alignment: Alignment = .bottomTrailing,
        camera: Binding<CameraState>) -> some View {
            modifier(CameraDebugViewModifier(alignment: alignment, camera: camera.projectedValue))
    }
}

@available(iOS 14.0, *)
struct CameraDebugView_Preview: PreviewProvider {
    static var previews: some View {
            CameraDebugView(camera: .constant(CameraState(
                center: .london,
                padding: .zero,
                zoom: 12,
                bearing: -0.76890,
                pitch: 32.77)))


    }
}

@available(iOS 14.0, *)
extension Font {
    fileprivate func safeMonospaced() -> Font {
        if #available(iOS 15, *) {
            return self.monospaced()
        } else {
            return self.monospacedDigit()
        }
    }
}


