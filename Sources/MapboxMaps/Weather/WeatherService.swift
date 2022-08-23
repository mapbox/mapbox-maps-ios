import Foundation
import CoreLocation
import QuartzCore
import Turf

internal protocol WeatherServiceProtocol: AnyObject {
    var delegate: WeatherServiceDelegate? { get set }
}

internal protocol WeatherServiceDelegate: AnyObject {
    func weatherService(_ weatherService: WeatherService, didUpdateForecast forecast: WeatherForecast)
}

internal struct WeatherForecast {
    var precipitationProbability: Double?
    var temperature: Double?
    var windSpeed: Double?
}

final public class WeatherService: WeatherServiceProtocol {
    public static let service = WeatherService()

    private static let updateInterval: CFTimeInterval = 30 * 60 // 30 minutes
    private static let updateDistance: CLLocationDistance = 10 * 1000 // 10 km

    weak var delegate: WeatherServiceDelegate?

    private var timer: Timer! {
        didSet { timer.tolerance = timer.timeInterval * 0.1 }
    }
    private var latestLocation: Location?
    private var lastUpdateTimestamp: CFTimeInterval?
    private var task: URLSessionDataTask?

    init() {
        start()
    }

    public func start() {
        timer = Timer.scheduledTimer(withTimeInterval: Self.updateInterval, repeats: true, block: { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.updateWeatherFromTimerIfNeeded()
        })
        timer.fire()
    }

    internal func stop() {

    }

    private func endpointURL(for coordinates: CLLocationCoordinate2D) -> URL {
        let endpoint =
        "https://api.mapbox.com/weatherdata/v1/conditions/\(coordinates.longitude)/\(coordinates.latitude).geojson?access_token=pk.eyJ1IjoicHJhdGlreWFkYXYiLCJhIjoiY2sxd3FlMTdvMDFiNjNtbzNkMXRmbjFmaiJ9.LmtWDsU0_LuuZfWnlBe4gA&units=imperial&interval=current&variables=temperature&_provider=tomorrow"
        return URL(string: endpoint)!
    }

    private func enoughTimeHasPassedSinceLastUpdate() -> Bool {
        guard let lastUpdateTimestamp = lastUpdateTimestamp else {
            return true
        }

        let passedTime = CACurrentMediaTime() - lastUpdateTimestamp
        return passedTime >= Self.updateInterval
    }

    private func locationDiffersEnough(from: Location?, to: Location) -> Bool {
        guard let from = from else {
            return true
        }

        let distanceTravelled = from.coordinate.distance(to: to.coordinate)
        return distanceTravelled >= Self.updateDistance
    }

    private func updateWeatherFromTimerIfNeeded() {
        guard let latestLocation = latestLocation, enoughTimeHasPassedSinceLastUpdate() else {
            return
        }

        triggerWeatherAPIRequestIfNeeded(for: latestLocation)
    }

    private func updateWeatherFromLocationIfNeeded(_ newLocation: Location) {
        guard locationDiffersEnough(from: latestLocation, to: newLocation) else {
            return
        }

        triggerWeatherAPIRequestIfNeeded(for: newLocation)
    }

    private func triggerWeatherAPIRequestIfNeeded(for location: Location) {
        guard task == nil else {
            return
        }

        task = URLSession.shared.dataTask(with: endpointURL(for: location.coordinate), completionHandler: { [weak self] data, _, error in
            defer {
                self?.task = nil
            }
            guard let self = self,
                let data = data,
                  error == nil else {
                // TODO: handle the error
                self?.task = nil
                return
            }

            let json = try? JSONSerialization.jsonObject(with: data)
            let properties = ((json as? [String: Any])?["features"] as? [[String: Any]])?.first?["properties"]
            let fields = (((properties as? [String: Any])?["conditions"] as? [[String: Any]])?.first?["fields"] as? [Any])?.first
            let dict = fields as? [String: Any] ?? [:]


            var forecast = WeatherForecast()
            forecast.temperature = dict["value"] as? Double

            DispatchQueue.main.async {
                self.delegate?.weatherService(self, didUpdateForecast: forecast)
            }
        })
        task?.resume()
    }
}

extension WeatherService: LocationConsumer {
    public func locationUpdate(newLocation: Location) {
        updateWeatherFromLocationIfNeeded(newLocation)
        latestLocation = newLocation
    }
}
