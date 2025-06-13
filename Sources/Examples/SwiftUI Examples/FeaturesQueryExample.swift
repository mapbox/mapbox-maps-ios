import SwiftUI
import MapboxMaps

/// This example shows how to use `MapReader` in order to access underlying `MapboxMap` API in SwiftUI.
struct FeaturesQueryExample: View {
    @StateObject private var model = Model()
    var body: some View {
        GeometryReader { geometry in
            MapReader { proxy in
                Map(viewport: $model.viewport) {
                    // Annotations that shows tap location.
                    if let queryResult = model.queryResult {
                        CircleAnnotation(centerCoordinate: queryResult.coordinate)
                            .circleColor(.red)
                            .circleRadius(8)
                    }

                    TapInteraction { context in
                        model.mapTapped(context, map: proxy.map, bottomInset: geometry.size.height * 0.33)
                        return false
                    }
                }
                .mapStyle(.streets) // In the Streets style you can access the layers
                .ignoresSafeArea()
                .sheet(item: $model.queryResult, onDismiss: {
                    model.dismiss()
                }, content: {
                    ResultView(result: $0)
                        .defaultDetents()
                })
            }
        }
    }
}

private class Model: ObservableObject {
    struct Location: Identifiable {
        var id = UUID()
        var coordinate: CLLocationCoordinate2D
    }
    @Published
    var queryResult: QueryResult?

    @Published
    var viewport: Viewport = .styleDefault

    private var cancellable: Cancelable?

    func mapTapped(_ context: InteractionContext, map: MapboxMap?, bottomInset: CGFloat) {
        cancellable?.cancel()
        guard let map = map else {
            return
        }
        cancellable = map.queryRenderedFeatures(with: context.point) { [self] result in
            cancellable = nil
            guard let queryResult = try? QueryResult(
                features: result.get(),
                coordinate: context.coordinate) else {return}
            self.queryResult = queryResult

            withViewportAnimation(.easeOut(duration: 0.5)) {
                viewport = .camera(center: context.coordinate)
                    .padding(.bottom, bottomInset)
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

struct FeaturesQueryExample_Preview: PreviewProvider {
    static var previews: some View {
        FeaturesQueryExample()
    }
}

extension JSONObject {
    var prettyPrinted: String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: turfRawValue, options: .prettyPrinted)
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
            return JSONObject(turfRawValue: jsonObject)
        } catch {
            return nil
        }
    }
}
