import UIKit
import MetricKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MXMetricManager.shared.add(self)
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        MXMetricManager.shared.remove(self)
    }
}

extension AppDelegate: MXMetricManagerSubscriber {
    func didReceive(_ payloads: [MXMetricPayload]) {

        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: payloads, requiringSecureCoding: true)

            // Save to disk
            var cacheDirectoryURL = try FileManager.default.url(for: .applicationSupportDirectory,
                                                                in: .userDomainMask,
                                                                appropriateFor: nil,
                                                                create: true)

            cacheDirectoryURL = cacheDirectoryURL.appendingPathComponent("MXMetricPayloads")

            try FileManager.default.createDirectory(at: cacheDirectoryURL,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)

            // Append file name
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yMMdd-HHmm"
            cacheDirectoryURL.appendPathComponent(dateFormatter.string(from: Date()))
            try data.write(to: cacheDirectoryURL)

            print("Wrote metric data to \(cacheDirectoryURL)")

        } catch let error {
            print("Payload error: \(error)")
        }
    }
}
