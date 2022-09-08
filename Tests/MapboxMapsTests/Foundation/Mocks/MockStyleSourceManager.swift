import Foundation
@testable import MapboxMaps

final class MockStyleSourceManager: StyleSourceManagerProtocol {

    struct SourcePropertyDefaultValueParams {
        let sourceType: String
        let property: String
    }

    static var sourcePropertyDefaultValueStub = Stub<SourcePropertyDefaultValueParams, StylePropertyValue>(defaultReturnValue: StylePropertyValue(value: "foo", kind: .undefined))
    static func sourcePropertyDefaultValue(for sourceType: String, property: String) -> StylePropertyValue {
        return sourcePropertyDefaultValueStub.call(with: SourcePropertyDefaultValueParams(sourceType: sourceType, property: property))
    }

    @Stubbed var allSourceIdentifiers: [SourceInfo] = []

    struct SourceParams {
        let id: String
        let type: Source.Type
    }
    let typedSourceStub = Stub<SourceParams, Source>(defaultReturnValue: GeoJSONSource())
    func source<T>(withId id: String, type: T.Type) throws -> T where T : Source {
        return typedSourceStub.call(with: SourceParams(id: id, type: type)) as! T
    }

    let sourceStub = Stub<String, Source>(defaultReturnValue: GeoJSONSource())
    func source(withId id: String) throws -> Source {
        return sourceStub.call(with: id)
    }

    struct AddSourceParams {
        let source: Source
        let id: String
    }
    let addSourceStub = Stub<AddSourceParams, Void>()
    func addSource(_ source: Source, id: String) throws {
        addSourceStub.call(with: AddSourceParams(source: source, id: id))
    }

    struct UpdateGeoJSONSourceParams {
        let id: String
        let geoJSON: GeoJSONObject
    }

    let updateGeoJSONSourceStub = Stub<UpdateGeoJSONSourceParams, Void>()
    func updateGeoJSONSource(withId id: String, geoJSON: GeoJSONObject) throws {
        updateGeoJSONSourceStub.call(with: UpdateGeoJSONSourceParams(id: id, geoJSON: geoJSON))
    }

    struct AddSourceUntypedParams {
        let id: String
        let properties: [String: Any]
    }

    let addSourceUntypedStub = Stub<AddSourceUntypedParams, Void>()
    func addSource(withId id: String, properties: [String : Any]) throws {
        addSourceUntypedStub.call(with: AddSourceUntypedParams(id: id, properties: properties))
    }

    func removeSource(withId id: String) throws {
        <#code#>
    }

    func sourceExists(withId id: String) -> Bool {
        <#code#>
    }

    func sourceProperty(for sourceId: String, property: String) -> StylePropertyValue {
        <#code#>
    }

    func sourceProperties(for sourceId: String) throws -> [String : Any] {
        <#code#>
    }

    func setSourceProperty(for sourceId: String, property: String, value: Any) throws {
        <#code#>
    }

    func setSourceProperties(for sourceId: String, properties: [String : Any]) throws {
        <#code#>
    }

}
