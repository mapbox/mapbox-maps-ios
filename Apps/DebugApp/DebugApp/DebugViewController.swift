import UIKit
import MapboxMaps
import os

/**
 NOTE: This view controller should be used as a scratchpad
 while you develop new features. Changes to this file
 should not be committed.
 */

final class DebugViewController: UIViewController {

    var mapView: MapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(mapView, at: 0)

        let osLog = OSLog(subsystem: "Aaaa", category: "Performance Logging")
//
        let signpostID = OSSignpostID(log: osLog)

        mapView.mapboxMap.onNext(event: .mapIdle) { _ in
            let data = try! self.decodeGeoJSON(from: "lines")
            var source = GeoJSONSource()
            source.data = .featureCollection(data)

//            os_signpost(.begin, log: osLog, name: "GeoJSON->String", signpostID: signpostID)
//            source.data = .string(try! data.string())
//            os_signpost(.end, log: osLog, name: "GeoJSON->String", signpostID: signpostID)

//            let url = Bundle.main.url(forResource: "lines", withExtension: "geojson")!
//            source.data = .url(url)
            os_signpost(.begin, log: osLog, name: "Add source total", signpostID: signpostID)
            try! self.mapView.mapboxMap.style.addSource(source, id: "my-source")
            os_signpost(.end, log: osLog, name: "Add source total", signpostID: signpostID)
        }

        mapView.mapboxMap.onEvery(event: .sourceDataLoaded) { event in
            if event.payload.id == "my-source" {
                os_signpost(.event, log: osLog, name: "sourceDataLoaded", "sourceDataLoaded", "sourceDataLoaded")
            }
        }
    }

    private func decodeGeoJSON(from filePath: String) throws -> FeatureCollection {
        guard let path = Bundle.main.path(forResource: filePath, ofType: "geojson") else {
            preconditionFailure("File '\(filePath)' not found.")
        }

        let filePath = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: filePath)
        return try JSONDecoder().decode(FeatureCollection.self, from: data)
    }

}
