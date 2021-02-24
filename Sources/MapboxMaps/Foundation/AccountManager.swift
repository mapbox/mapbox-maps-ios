import Foundation

public class AccountManager {
    public var accessToken: String?
    public let baseURL = "https://api.mapbox.com"

    public static let shared = AccountManager()

    private init() {
        if let accessToken = Bundle.main.infoDictionary?["MBXAccessToken"] as? String {
            self.accessToken = accessToken
        }
    }
}
