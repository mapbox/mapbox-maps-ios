import SwiftUI
@_spi(Experimental) import MapboxMapsSwiftUI

/// This example shows how to use `MapReader` in order to access underlying `MapboxMap` API in SwiftUI.
@available(iOS 14.0, *)
struct FeaturesQueryExample: View {
    @StateObject private var model = Model()
    var body: some View {
        MapReader { proxy in
            Map(mapInitOptions: nil) {
                // Annotations that shows tap location.
                if let queryResult = model.queryResult {
                    ViewAnnotation(queryResult.coordinate) {
                        Circle()
                            .fill(.red)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .onMapTapGesture { point in
                model.mapTapped(at: point, map: proxy.map)
            }
            .ignoresSafeArea()
            .sheet(item: $model.queryResult, onDismiss: { model.queryResult = nil }) {
                ResultView(result: $0)
                    .defaultDetents()
            }
            .onChange(of: model.queryResult?.coordinate) { coordinate in
                if let coordinate = coordinate, let camera = proxy.camera {
                    let options = CameraOptions(center: coordinate)
                    camera.ease(to: options, duration: 0.5, curve: .easeOut)
                }
            }
        }
    }
}

@available(iOS 14.0, *)
private class Model: ObservableObject {
    struct Location: Identifiable {
        var id = UUID()
        var coordinate: CLLocationCoordinate2D
    }
    @Published
    var queryResult: QueryResult? = nil

    private var cancellable: Cancelable? = nil

    func mapTapped(at point: CGPoint, map: MapboxMap?) {
        cancellable?.cancel()
        guard let map = map else {
            return
        }
        cancellable = map.queryRenderedFeatures(with: point) { [self] result in
            cancellable = nil
            queryResult = try? QueryResult(
                features: result.get(),
                coordinate: map.coordinate(for: point))
        }
    }
}

@available(iOS 14.0, *)
struct QueryResult: Identifiable {
    struct Feature: Identifiable {
        var id = UUID()
        var props: String

        init(feature: QueriedRenderedFeature) {
            let feature = feature.queriedFeature
            var json = JSONObject()
            json["source"] = .string(feature.source)
            if let sourceLayer = feature.sourceLayer {
                json["source_layer"] = .string(sourceLayer)
            }
            if let featureJson = feature.feature.asJsonObject {
                json["feature"] = .object(featureJson)
            }

            props = json.prettyPrinted ?? ""
        }
    }
    var id = UUID()
    var coordinate: CLLocationCoordinate2D
    var features: [Feature]

    init(features: [QueriedRenderedFeature], coordinate: CLLocationCoordinate2D) {
        self.features = features.map {
            Feature(feature: $0)
        }
        self.coordinate = coordinate
    }
}

@available(iOS 14.0, *)
struct ResultView: View {
    let result: QueryResult
    var body: some View {
        if result.features.isEmpty {
            Text("Nothing found 😔")
        } else {
            List {
                Section {
                    ForEach(result.features) {
                        Text($0.props).font(.safeMonospaced)
                    }
                } header: {
                    Text("Rendered Features at \(result.coordinate.latitude), \(result.coordinate.longitude)")
                }
            }
        }
    }
}

@available(iOS 14.0, *)
struct FeaturesQueryExample_Preview: PreviewProvider {
    static var previews: some View {
        FeaturesQueryExample()
    }
}


extension JSONObject {
    var prettyPrinted: String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: rawValue, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}

extension Feature {
    var asJsonObject: JSONObject? {
        do {
            let jsonData = try JSONEncoder().encode(self)
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
            guard var jsonObject = jsonObject as? [String: Any?] else { return nil }
            if jsonObject.keys.contains("geometry") {
                // can be too long for example
                jsonObject["geometry"] = ["..."]
            }
            return JSONObject(rawValue: jsonObject)
        } catch {
            return nil
        }
    }
}
