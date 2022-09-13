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
    func source<T>(withId id: String, type: T.Type) throws -> T where T: Source {
        // swiftlint:disable:next force_cast
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
    func addSource(withId id: String, properties: [String: Any]) throws {
        addSourceUntypedStub.call(with: AddSourceUntypedParams(id: id, properties: properties))
    }

    let removeSourceStub = Stub<String, Void>()
    func removeSource(withId id: String) throws {
        removeSourceStub.call(with: id)
    }

    let sourceExistsStub = Stub<String, Bool>(defaultReturnValue: false)
    func sourceExists(withId id: String) -> Bool {
        return sourceExistsStub.call(with: id)
    }

    struct SourcePropertyForParams {
        let sourceId: String
        let property: String
    }
    let sourcePropertyForStub = Stub<SourcePropertyForParams, StylePropertyValue>(
        defaultReturnValue: StylePropertyValue(value: "foo", kind: .undefined)
    )
    func sourceProperty(for sourceId: String, property: String) -> StylePropertyValue {
        return sourcePropertyForStub.call(with: SourcePropertyForParams(sourceId: sourceId, property: property))
    }

    let sourcePropertiesForStub = Stub<String, [String: Any]>(defaultReturnValue: [:])
    func sourceProperties(for sourceId: String) throws -> [String: Any] {
        return sourcePropertiesForStub.call(with: sourceId)
    }

    struct SetSourcePropertyForParams {
        let sourceId: String
        let property: String
        let value: Any
    }

    let setSourcePropertyForParamsStub = Stub<SetSourcePropertyForParams, Void>()
    func setSourceProperty(for sourceId: String, property: String, value: Any) throws {
        setSourcePropertyForParamsStub.call(
            with: SetSourcePropertyForParams(sourceId: sourceId, property: property, value: value)
        )
    }

    struct SetSourcePropertiesForParams {
        let sourceId: String
        let properties: [String: Any]
    }

    let setSourcePropertiesForParamsStub = Stub<SetSourcePropertiesForParams, Void>()
    func setSourceProperties(for sourceId: String, properties: [String: Any]) throws {
        setSourcePropertiesForParamsStub.call(
            with: SetSourcePropertiesForParams(sourceId: sourceId, properties: properties)
        )
    }
}
