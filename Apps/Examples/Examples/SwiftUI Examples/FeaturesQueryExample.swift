import SwiftUI
@_spi(Experimental) import MapboxMaps

/// This example shows how to use `MapReader` in order to access underlying `MapboxMap` API in SwiftUI.
@available(iOS 14.0, *)
struct FeaturesQueryExample: View {
    @StateObject private var model = Model()
    var body: some View {
        GeometryReader { geometry in
            MapReader { proxy in
                Map(viewport: $model.viewport) {
                    // Annotations that shows tap location.
                    if let queryResult = model.queryResult {
                        ViewAnnotation(queryResult.coordinate) {
                            Circle()
                                .fill(.red)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .styleURI(.streets) // In standard style the layers are opaque
                .onMapTapGesture { point in
                    model.mapTapped(at: point, map: proxy.map, bottomInset: geometry.size.height * 0.33)
                }
                .ignoresSafeArea()
                .sheet(item: $model.queryResult, onDismiss: {
                    model.dismiss()
                }) {
                    ResultView(result: $0)
                        .defaultDetents()
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

    @Published
    var viewport: Viewport = .styleDefault

    private var cancellable: Cancelable? = nil

    func mapTapped(at point: CGPoint, map: MapboxMap?, bottomInset: CGFloat) {
        cancellable?.cancel()
        guard let map = map else {
            return
        }
        cancellable = map.queryRenderedFeatures(with: point) { [self] result in
            cancellable = nil
            let coordinate = map.coordinate(for: point)
            guard let queryResult = try? QueryResult(
                features: result.get(),
                coordinate: coordinate) else {return}
            self.queryResult = queryResult

            withViewportAnimation(.easeOut(duration: 0.5)) {
                viewport = .camera(center: coordinate)
                    .inset(edges: .bottom, length: bottomInset, ignoringSafeArea: true)
            }
        }
    }

    func dismiss() {
        queryResult = nil
        withViewportAnimation(.easeOut(duration: 0.2)) {
            viewport = .camera() // Reset the inset
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
