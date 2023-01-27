import SwiftUI
@_spi(Experimental) import MapboxMapsSwiftUI

@available(iOS 14.0, *)
struct FeaturesQueryExample: View {
    @State private var camera = CameraState(center: .newYork, zoom: 10)

    @State private var queryResult: QueryResult? = nil

    var body: some View {
            MapboxView(camera: $camera)
                .styleURI(.streets)
                .onMapTapGesture(action: { _, res in
                    queryResult = try? QueryResult(features: res.get())
                })
        .edgesIgnoringSafeArea(.all)
        .sheet(item: $queryResult, onDismiss: { queryResult = nil }) { res in
            ResultView(result: res)
                .defaultDetents()
        }
    }
}


@available(iOS 14.0, *)
struct QueryResult: Identifiable {
    struct Feature: Identifiable {
        var id = UUID()
        var sourceId: String
        var sourceLayer: String?
        var name: String?
        var category: String?

        init(feature: QueriedFeature) {
            sourceId = feature.source
            sourceLayer = feature.sourceLayer
            let properties = feature.feature.properties
            name = properties?["name_en"]?.flatMap(\.asString) ?? properties?["name"]?.flatMap(\.asString)
            category = properties?["category_en"]?.flatMap(\.asString) ?? properties?["category"]?.flatMap(\.asString)

        }
    }
    var id = UUID()
    var features: [Feature]

    init(features: [QueriedFeature]) {
        self.features = features.map {
            Feature(feature: $0)
        }
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
                    ForEach(result.features) { f in
                        VStack(alignment: .leading) {
                            FeatureView(f: f)
                        }
                    }
                } header: {
                    Text("Features")
                }
            }
        }
    }
}

@available(iOS 14.0, *)
struct FeatureView: View {
    var f: QueryResult.Feature
    var body: some View {
        f.name.map { Text($0) }
        f.category.map {
            Text($0)
            .font(.callout)
            .foregroundColor(.purple)
        }
        VStack(alignment: .leading) {
            Text("sourceId: \(f.sourceId)")
            f.sourceLayer.map { Text("sourceLayer: \($0)")}

        }
        .font(.footnote)
        .foregroundColor(.secondary)
    }
}

@available(iOS 14.0, *)
extension JSONValue {
    fileprivate var asString: String? {
        switch self {
        case let .string(s):
            return s
        default:
            return nil
        }
    }
}

@available(iOS 14.0, *)
struct FeaturesQueryExample_Preview: PreviewProvider {
    static var previews: some View {
        FeaturesQueryExample()
    }
}
