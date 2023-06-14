import Foundation
@_implementationOnly import MapboxCommon_Private

internal protocol StyleSourceManagerProtocol: AnyObject {
    static func sourcePropertyDefaultValue(for sourceType: String, property: String) -> StylePropertyValue

    var allSourceIdentifiers: [SourceInfo] { get }
    func source<T>(withId id: String, type: T.Type) throws -> T where T: Source
    func source(withId id: String) throws -> Source
    func addSource(_ source: Source, dataId: String?) throws
    func updateGeoJSONSource(withId id: String, data: GeoJSONSourceData, dataId: String?)
    func addSource(withId id: String, properties: [String: Any]) throws
    func removeSource(withId id: String) throws
    func sourceExists(withId id: String) -> Bool
    func sourceProperty(for sourceId: String, property: String) -> StylePropertyValue
    func sourceProperties(for sourceId: String) throws -> [String: Any]
    func setSourceProperty(for sourceId: String, property: String, value: Any) throws
    func setSourceProperties(for sourceId: String, properties: [String: Any]) throws
}

internal final class StyleSourceManager: StyleSourceManagerProtocol {
    private typealias SourceId = String

    internal static func sourcePropertyDefaultValue(for sourceType: String, property: String) -> StylePropertyValue {
        return MapboxCoreMaps.StyleManager.getStyleSourcePropertyDefaultValue(forSourceType: sourceType, property: property)
    }

    private let styleManager: StyleManagerProtocol
    private let mainQueue: DispatchQueueProtocol
    private let backgroundQueue: DispatchQueueProtocol
    private var workItems = [SourceId: AnyCancelable]()

    internal var allSourceIdentifiers: [SourceInfo] {
        return styleManager.getStyleSources().map { info in
            SourceInfo(id: info.id, type: SourceType(stringLiteral: info.type))
        }
    }

    deinit {
        workItems.values.forEach { $0.cancel() }
    }

    internal init(
        styleManager: StyleManagerProtocol,
        mainQueue: DispatchQueueProtocol = DispatchQueue.main,
        backgroundQueue: DispatchQueueProtocol = DispatchQueue(label: "GeoJSON parsing queue", qos: .userInitiated)
    ) {
        self.styleManager = styleManager
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
    }

    // MARK: - Typed API

    internal func source<T: Source>(withId id: String, type: T.Type) throws -> T {
        let sourceProps = try sourceProperties(for: id)
        return try type.init(jsonObject: sourceProps)
    }

    internal func source(withId id: String) throws -> Source {
        // Get the source properties for a given identifier
        let sourceProps = try sourceProperties(for: id)

        guard let typeString = sourceProps["type"] as? String,
              let type = SourceType(rawValue: typeString).sourceType else {
            throw TypeConversionError.invalidObject
        }

        return try type.init(jsonObject: sourceProps)
    }

    internal func addSource(_ source: Source, dataId: String? = nil) throws {
        if let geoJSONSource = source as? GeoJSONSource {
            try addGeoJSONSource(geoJSONSource, dataId: dataId)
        } else {
            try addSourceInternal(source)
        }
    }

    private func addSourceInternal(_ source: Source) throws {
        let sourceDictionary = try source.jsonObject(userInfo: [.nonVolatilePropertiesOnly: true])
        try addSource(withId: source.id, properties: sourceDictionary)

        // volatile properties have to be set after the source has been added to the style
        let volatileProperties = try source.jsonObject(userInfo: [.volatilePropertiesOnly: true])

        try setSourceProperties(for: source.id, properties: volatileProperties)
    }

    // MARK: - Untyped API

    internal func addSource(withId id: String, properties: [String: Any]) throws {
        try handleExpected {
            return styleManager.addStyleSource(forSourceId: id, properties: properties.removingId())
        }
    }

    internal func removeSource(withId id: String) throws {
        try handleExpected {
            return styleManager.removeStyleSource(forSourceId: id)
        }

        workItems.removeValue(forKey: id)?.cancel()
    }

    internal func sourceExists(withId id: String) -> Bool {
        return styleManager.styleSourceExists(forSourceId: id)
    }

    internal func sourceProperty(for sourceId: String, property: String) -> StylePropertyValue {
        return styleManager.getStyleSourceProperty(forSourceId: sourceId, property: property)
    }

    internal func sourceProperties(for sourceId: String) throws -> [String: Any] {
        let expected = styleManager.getStyleSourceProperties(forSourceId: sourceId)
        if expected.isError() {
            throw StyleError(message: expected.error as String)
        }
        guard var dict = expected.value as? [String: Any] else {
            throw TypeConversionError.unexpectedType
        }
        dict["id"] = sourceId
        return dict
    }

    internal func setSourceProperty(for sourceId: String, property: String, value: Any) throws {
        try handleExpected {
            return styleManager.setStyleSourcePropertyForSourceId(sourceId, property: property, value: value)
        }
    }

    internal func setSourceProperties(for sourceId: String, properties: [String: Any]) throws {
        try handleExpected {
            return styleManager.setStyleSourcePropertiesForSourceId(sourceId, properties: properties.removingId())
        }
    }

    private func setStyleGeoJSONSourceDataForSourceId(_ id: String, dataId: String? = nil, data: MapboxCoreMaps.GeoJSONSourceData) throws {
        try handleExpected { () -> Expected<NSNull, NSString> in
            return styleManager.__setStyleGeoJSONSourceDataForSourceId(id,
                                                                       dataId: dataId ?? "",
                                                                       data: data)
        }
    }

    // MARK: - Async GeoJSON source data parsing

    private func addGeoJSONSource(_ source: GeoJSONSource, dataId: String? = nil) throws {
        // GeoJSON source is being added in two steps:
        // 1. Add source metadata with empty data on main queue
        // 2. Apply the data value on background worker queue

        var emptySource = source
        // Can't pass nil here, Core requires at least empty data for source to be added.
        emptySource.data = .string("")
        try addSourceInternal(emptySource)

        guard let data = source.data else { return }
        if case GeoJSONSourceData.string("") = data { return }

        updateGeoJSONSource(withId: source.id, data: data, dataId: dataId)
    }

    func updateGeoJSONSource(withId id: String, data: GeoJSONSourceData, dataId: String?) {
        workItems.removeValue(forKey: id)?.cancel()

        // This implementation favors the first submitted task and the last, in case of many work items queuing up -
        // the item that started execution will disregard cancellation, queued up items in the middle will get cancelled,
        // and the last item will be left waiting in the queue.
        let item = DispatchWorkItem { [weak self] in
            if self == nil { return } // not capturing self here as conversion below can take some time
            let data = data.coreData
            do {
                try self?.setStyleGeoJSONSourceDataForSourceId(id, dataId: dataId, data: data)
            } catch {
                Log.error(forMessage: "Failed to set data for source with id: \(id), error: \(error)")
            }
        }

        workItems[id] = AnyCancelable(item.cancel)
        backgroundQueue.async(execute: item)
    }
}

private extension Dictionary where Key == String {
    func removingId() -> Self {
        guard keys.contains("id") else {
            return self
        }
        var copy = self
        copy.removeValue(forKey: "id")
        return copy
    }
}
