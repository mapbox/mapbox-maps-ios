import SwiftUI
import MapboxMaps

struct ViewportInFixedFrameExample: View {
    var body: some View {
        Map(
            initialViewport: .overview(
                geometry: Geometry.lineString(LineString(routeCoordinates)),
                geometryPadding: EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            )
        ) {
            PolylineAnnotation(lineString: LineString(routeCoordinates))
                .lineBorderColor(UIColor(red: 62, green: 66, blue: 181, alpha: 0))
                .lineBorderWidth(8)
                .lineColor(.blue)
                .lineWidth(3)
        }
        .frame(width: 300, height: 300)
    }

    private let routeCoordinates: [CLLocationCoordinate2D] = [
        .init(latitude: 61.493343399275375, longitude: 21.79401104323395),
        .init(latitude: 61.369485877583685, longitude: 21.6497937188623),
        .init(latitude: 61.20121331932606, longitude: 21.723373986398713),
        .init(latitude: 61.15722935505474, longitude: 21.579156662028026),
        .init(latitude: 61.1174491345069, longitude: 21.517349237298163),
        .init(latitude: 61.03916342463762, longitude: 21.532065290804866),
        .init(latitude: 60.922086661997184, longitude: 21.611531979743546),
        .init(latitude: 60.82754056454698, longitude: 21.82049993954618),
        .init(latitude: 60.662131116075585, longitude: 22.02063826724438),
        .init(latitude: 60.543665503992116, longitude: 22.129538402396946),
        .init(latitude: 60.461061119997595, longitude: 22.206061880634536),
        .init(latitude: 60.4538050749446, longitude: 22.270812516066485)
    ]
}
