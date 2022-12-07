import Foundation

internal protocol StyleSourceManagerProtocol: AnyObject {
    static func sourcePropertyDefaultValue(for sourceType: String, property: String) -> StylePropertyValue

    var allSourceIdentifiers: [SourceInfo] { get }
    func source<T>(withId id: String, type: T.Type) throws -> T where T: Source
    func source(withId id: String) throws -> Source
    func addSource(_ source: Source, id: String) throws
    func updateGeoJSONSource(withId id: String, geoJSON: GeoJSONObject) throws
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
        return StyleManager.getStyleSourcePropertyDefaultValue(forSourceType: sourceType, property: property)
    }

    private let styleManager: StyleManagerProtocol
    private let mainQueue: DispatchQueueProtocol
    private let backgroundQueue: DispatchQueueProtocol
    private var workItems = [SourceId: Cancelable]()
    private let commonSettings: SettingsServiceInterface

    internal var allSourceIdentifiers: [SourceInfo] {
        return styleManager.getStyleSources().compactMap { info in
            guard let sourceType = SourceType(rawValue: info.type) else {
                Log.error(forMessage: "Failed to create SourceType from \(info.type)", category: "Example")
                return nil
            }
            return SourceInfo(id: info.id, type: sourceType)
        }
    }

    deinit {
        workItems.values.forEach { $0.cancel() }
    }

    internal init(
        styleManager: StyleManagerProtocol,
        mainQueue: DispatchQueueProtocol = DispatchQueue.main,
        backgroundQueue: DispatchQueueProtocol = DispatchQueue(label: "GeoJSON parsing queue", qos: .userInitiated),
        commonSettings: SettingsServiceInterface = SettingsServiceFactory.getInstance(storageType: .nonPersistent)
    ) {
        self.styleManager = styleManager
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        self.commonSettings = commonSettings
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
              let type = SourceType(rawValue: typeString) else {
            throw TypeConversionError.invalidObject
        }
        return try type.sourceType.init(jsonObject: sourceProps)
    }

    internal func addSource(_ source: Source, id: String) throws {
        if let geoJSONSource = source as? GeoJSONSource {
            try addGeoJSONSource(geoJSONSource, id: id)
        } else {
            try addSourceInternal(source, id: id)
        }
    }

    private func addSourceInternal(_ source: Source, id: String) throws {
        let sourceDictionary = try source.jsonObject(userInfo: [.nonVolatilePropertiesOnly: true])
        try addSource(withId: id, properties: sourceDictionary)

        // volatile properties have to be set after the source has been added to the style
        let volatileProperties = try source.jsonObject(userInfo: [.volatilePropertiesOnly: true])

        try setSourceProperties(for: id, properties: volatileProperties)
    }

    internal func updateGeoJSONSource(withId id: String, geoJSON: GeoJSONObject) throws {
        guard let sourceInfo = allSourceIdentifiers.first(where: { $0.id == id }),
              sourceInfo.type == .geoJson else {
            throw StyleError(message: "Source with id '\(id)' is not found or not a GeoJSONSource.")
        }

        if commonSettings.shouldUseDirectGeoJSONUpdate {
            directlyApplyGeoJSON(data: geoJSON.sourceData, sourceId: id)
        } else {
            applyGeoJSONData(data: geoJSON.sourceData, sourceId: id)
        }
    }

    // MARK: - Untyped API

    internal func addSource(withId id: String, properties: [String: Any]) throws {
        try handleExpected {
            return styleManager.addStyleSource(forSourceId: id, properties: properties)
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
        return try handleExpected {
            return styleManager.getStyleSourceProperties(forSourceId: sourceId)
        }
    }

    internal func setSourceProperty(for sourceId: String, property: String, value: Any) throws {
        try handleExpected {
            return styleManager.setStyleSourcePropertyForSourceId(sourceId, property: property, value: value)
        }
    }

    internal func setSourceProperties(for sourceId: String, properties: [String: Any]) throws {
        try handleExpected {
            return styleManager.setStyleSourcePropertiesForSourceId(sourceId, properties: properties)
        }
    }

    private func setStyleGeoJSONSourceDataForSourceId(_ id: String, data: MapboxCoreMaps.GeoJSONSourceData) throws {
        try handleExpected {
            return styleManager.__setStyleGeoJSONSourceDataForSourceId(id, data: data)
        }
    }

    // MARK: - Async GeoJSON source data parsing

    private func addGeoJSONSource(_ source: GeoJSONSource, id: String) throws {
        let data = source.data

        var emptySource = source
        if emptySource.data != nil {
            emptySource.data = .empty
        }

        try addSourceInternal(emptySource, id: id)

        guard let data = data else { return }
        if case GeoJSONSourceData.empty = data { return }

        if commonSettings.shouldUseDirectGeoJSONUpdate {
            directlyApplyGeoJSON(data: data, sourceId: id)
        } else {
            applyGeoJSONData(data: data, sourceId: id)
        }
    }

    private func directlyApplyGeoJSON(data: GeoJSONSourceData, sourceId id: String) {
        workItems.removeValue(forKey: id)?.cancel()

        // This implementation favors the first submitted task and the last, in case of many work items queuing up -
        // the item that started execution will disregard cancellation, queued up items in the middle will get cancelled,
        // and the last item will be left waiting in the queue.
        let item = DispatchWorkItem { [weak self] in
            if self == nil { return } // not capturing self here as conversion below can take some time

            let data = data.coreData
            do {
                try self?.setStyleGeoJSONSourceDataForSourceId(id, data: data)
            } catch {
                Log.error(forMessage: "Failed to set data for source with id: \(id), error: \(error)")
            }
        }

        workItems[id] = item
        backgroundQueue.async(execute: item)
    }

    private func applyGeoJSONData(data: GeoJSONSourceData, sourceId id: String) {
        workItems.removeValue(forKey: id)?.cancel()

        // This implementation favors the first submitted task and the last, in case of many work items queuing up -
        // the item that started execution will disregard cancellation, queued up items in the middle will get cancelled,
        // and the last item will be left waiting in the queue.
        let item = DispatchWorkItem { [weak self] in
            if self == nil { return } // not capturing self here as toString conversion below can take time

            let json = try! data.stringValue()

            self?.mainQueue.async { [weak self] in
                do {
                    try self?.setSourceProperty(for: id, property: "data", value: json)
                } catch {
                    Log.error(forMessage: "Failed to set data for source with id: \(id), error: \(error)")
                }
            }
        }

        workItems[id] = item
        backgroundQueue.async(execute: item)
    }
}

private extension SettingsServiceInterface {
    var shouldUseDirectGeoJSONUpdate: Bool {
        do {
            return try get(key: "geojson_allow_direct_setter", type: Bool.self).get()
        } catch {
            return false
        }
    }
}
