import Foundation
import MapboxCommon

final class MockSettingsService: SettingsServiceInterface {

    struct SetParams {
        let key: String
        let value: Any
    }
    let setStub = Stub<SetParams, Result<Void, SettingsServiceError>>(defaultReturnValue: .success(()))
    func set<T>(key: String, value: T) -> Result<Void, SettingsServiceError> {
        setStub.call(with: .init(key: key, value: value))
    }

    struct GetParams {
        let key: String
        let type: Any
    }
    let getStub = Stub<GetParams, Result<Any, SettingsServiceError>>(defaultReturnValue: .success(()))
    func get<T>(key: String, type: T.Type) -> Result<T, SettingsServiceError> {
        // swiftlint:disable:next force_cast
        getStub.call(with: .init(key: key, type: type)).map { $0 as! T }
    }

    struct GetDefaultParams {
        let key: String
        let type: Any
        let defaultValue: Any
    }
    let getDefaultStub = Stub<GetDefaultParams, Result<Any, SettingsServiceError>>(defaultReturnValue: .success(()))
    func get<T>(key: String, type: T.Type, defaultValue: T) -> Result<T, SettingsServiceError> {
        // swiftlint:disable:next force_cast
        getDefaultStub.call(with: .init(key: key, type: type, defaultValue: defaultValue)).map { $0 as! T }
    }

    let eraseStub = Stub<String, Result<Void, SettingsServiceError>>(defaultReturnValue: .success(()))
    func erase(key: String) -> Result<Void, SettingsServiceError> {
        return eraseStub.call(with: key)
    }

    let hasStub = Stub<String, Result<Bool, SettingsServiceError>>(defaultReturnValue: .success(false))
    func has(key: String) -> Result<Bool, MapboxCommon.SettingsServiceError> {
        return hasStub.call(with: key)
    }
}
