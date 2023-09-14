import UIKit
@_spi(Experimental) import MapboxMaps

final class Lights3DExample: UIViewController, ExampleProtocol {
    private var mapView: MapView!
    let directionalLightId = "directional-light"
    let ambientLightId = "ambient-light"

    private var cancelables = Set<AnyCancelable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MapView(frame: view.bounds)
        setDefaultCamera()
        view.addSubview(mapView)

        mapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            self?.setupExample()
            self?.finish()
        }.store(in: &cancelables)

        navigationItem.rightBarButtonItem = sunAnimationButton()
    }

    func sunAnimationButton() -> UIBarButtonItem {
        if #available(iOS 13, *) {
            return UIBarButtonItem(image: UIImage(systemName: "sunrise"), style: .plain, target: self, action: #selector(startSunAnimation))
        } else {
            return UIBarButtonItem(title: "Sun", style: .plain, target: self, action: #selector(startSunAnimation))
        }
    }

    func setupExample() {
        add3DLights()
    }

    func add3DLights(azimuth: Double = 210, polarAngle: Double = 30, ambientColor: UIColor = .white) {
        do {
            var directionalLight = DirectionalLight(id: directionalLightId)
            directionalLight.intensity = .constant(0.5)
            directionalLight.direction = .constant([azimuth, polarAngle])
            directionalLight.directionTransition = StyleTransition(duration: 0, delay: 0)
            directionalLight.castShadows = .constant(true)
            directionalLight.shadowIntensity = .constant(1)

            var ambientLight = AmbientLight(id: ambientLightId)
            ambientLight.color = .constant(.init(ambientColor))
            ambientLight.intensity = .constant(0.5)

            try mapView.mapboxMap.setLights(ambient: ambientLight, directional: directionalLight)

            var atmosphere = Atmosphere()
            atmosphere.range = .constant([0, 12])
            atmosphere.horizonBlend = .constant(0.1)
            atmosphere.starIntensity = .constant(0.2)
            atmosphere.color = .constant(StyleColor(red: 240, green: 196, blue: 152, alpha: 1)!)
            atmosphere.highColor = .constant(StyleColor(red: 221, green: 209, blue: 197, alpha: 1)!)
            atmosphere.spaceColor = .constant(StyleColor(red: 153, green: 180, blue: 197, alpha: 1)!)

            try mapView.mapboxMap.setAtmosphere(atmosphere)
        } catch {
            print("Failed to set 3D light due to:", error)
        }
    }

    func updateSunLight(animationProgress: Double) {
        // Calculate azimuth and polar angle based on animation progress
        let azimuth = 180.0 - (360.0 * animationProgress)
        let polarAngle = 45.0 * sin(animationProgress * Double.pi)

        do {
            let lightIntensity = generateLightIntensityValue(progress: animationProgress)
            try mapView.mapboxMap.setLightProperty(
                for: directionalLightId,
                property: "direction",
                value: [azimuth, polarAngle]
            )
            try mapView.mapboxMap.setLightProperty(
                for: directionalLightId,
                property: "intensity",
                value: lightIntensity
            )

            let color = StyleColor(generateSunColor(progress: animationProgress))
            try mapView.mapboxMap.setLightProperty(for: ambientLightId, property: "color", value: color.rawValue)
            try mapView.mapboxMap.setLightProperty(for: ambientLightId, property: "intensity", value: lightIntensity)
        } catch {
            print("Failed to update sun light due to:", error)
        }
    }

    func setDefaultCamera() {
        let cameraOptions = CameraOptions(center: CLLocationCoordinate2D(latitude: 40.713589095634475,
                                                                         longitude: -74.00370030835559),
                                          zoom: 16.868,
                                          bearing: 60.54,
                                          pitch: 60)
        mapView.mapboxMap.setCamera(to: cameraOptions)
    }

    var animationProgress = 0.0 {
        didSet {
            updateSunLight(animationProgress: animationProgress)
        }
    }

    var animation: AnimationData?

    class AnimationData {
        let animationStart: CFTimeInterval
        let animationEnd: CFTimeInterval
        let displayLink: CADisplayLink

        init(start: CFTimeInterval = CACurrentMediaTime(), duration: CFTimeInterval, displayLink: CADisplayLink) {
            self.animationStart = start
            self.animationEnd = start + duration
            self.displayLink = displayLink

            displayLink.add(to: .main, forMode: .default)
        }

        func animationProgress(for time: CFTimeInterval) -> Double {
            guard time < animationEnd else { return 1 }
            let duration = time - animationStart
            guard duration > 0 else { return 0 }

            let expectedDuration = animationEnd - animationStart

            return duration / expectedDuration
        }

        deinit {
            displayLink.remove(from: .main, forMode: .default)
        }
    }

    @objc func startSunAnimation() {
        let duration: TimeInterval = 8

        let displayLink = CADisplayLink(target: self, selector: #selector(tickAnimation(displayLink:)))
        animation = AnimationData(duration: duration, displayLink: displayLink)
    }

    @objc func tickAnimation(displayLink: CADisplayLink) {
        guard let animation = animation else { return assertionFailure("DisplayLink should not trigger without animation") }

        animationProgress = animation.animationProgress(for: displayLink.targetTimestamp)
        if animationProgress >= 1 {
            self.animation = nil
        }
    }

    func generateSunColor(progress: Double) -> UIColor {
        let yellowSunColor = UIColor(red: 255/255, green: 242/255, blue: 0/255, alpha: 1)
        let orangeSunColor = UIColor(red: 255/255, green: 180/255, blue: 0/255, alpha: 1)
        let darkOrangeSunColor = UIColor(red: 204/255, green: 51/255, blue: 0/255, alpha: 1)

        switch progress {
        case 0..<0.2:
            return interpolateColor(from: .white,
                                    to: yellowSunColor,
                                    with: (progress) / 0.2)
        case 0.2..<0.4:
            return interpolateColor(from: yellowSunColor,
                                    to: .white,
                                    with: (progress - 0.2) / 0.2)
        case 0.4..<0.7:
            return .white
        case 0.7..<0.85:
            return interpolateColor(from: .white,
                                    to: orangeSunColor,
                                    with: (progress - 0.7) / 0.15)
        case 0.85...1.0:
            return interpolateColor(from: orangeSunColor,
                                    to: darkOrangeSunColor,
                                    with: (progress - 0.85) / 0.15)
        default:
            return .purple
        }
    }

    func generateLightIntensityValue(progress: Double, acceptableValues: ClosedRange<Double> = 0.1...0.5) -> Double {
        let intervalWidth = acceptableValues.upperBound - acceptableValues.lowerBound

        if progress <= 0.5 {
            return acceptableValues.lowerBound + intervalWidth * (2 * progress)
        } else {
            return acceptableValues.upperBound - (progress - 0.5) * (2 * intervalWidth)
        }
    }

    func interpolateColor(from startColor: UIColor, to endColor: UIColor, with interpolationFactor: Double) -> UIColor {
        var startRed: CGFloat = 0
        var startGreen: CGFloat = 0
        var startBlue: CGFloat = 0
        var startAlpha: CGFloat = 0
        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)

        var endRed: CGFloat = 0
        var endGreen: CGFloat = 0
        var endBlue: CGFloat = 0
        var endAlpha: CGFloat = 0
        endColor.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)

        let interpolatedRed = startRed + CGFloat(interpolationFactor) * (endRed - startRed)
        let interpolatedGreen = startGreen + CGFloat(interpolationFactor) * (endGreen - startGreen)
        let interpolatedBlue = startBlue + CGFloat(interpolationFactor) * (endBlue - startBlue)
        let interpolatedAlpha = startAlpha + CGFloat(interpolationFactor) * (endAlpha - startAlpha)

        return UIColor(red:   min(max(0, interpolatedRed), 1),
                       green: min(max(0, interpolatedGreen), 1),
                       blue:  min(max(0, interpolatedBlue), 1),
                       alpha: min(max(0, interpolatedAlpha), 1))
    }
}

