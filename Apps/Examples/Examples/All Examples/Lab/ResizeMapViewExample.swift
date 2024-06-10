import Foundation
import UIKit
import MapboxMaps
import MapKit
import os

final class ResizeMapViewExample: UIViewController, ExampleProtocol {
    private let mapsStackView = UIStackView(frame: .zero)
    private let mapsContentView: UIView = UIView(frame: .zero)
    private var mapboxMapView: MapView!

    var cancellables: Set<AnyCancelable> = []

    var fullSizeConstraints: [NSLayoutConstraint] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        mapboxMapView = MapView(frame: view.bounds)

        mapsStackView.backgroundColor = .red
        mapsContentView.addSubview(mapsStackView)
        view.addSubview(mapsContentView)

        navigationController?.setToolbarHidden(false, animated: false)

        mapsStackView.addArrangedSubview(mapboxMapView)

        mapsStackView.distribution = .fillEqually

        mapboxMapView.mapboxMap.onMapLoaded.observeNext { [weak self] _ in
            self?.mapStyleDidLoad()
        }.store(in: &cancellables)

        setupDefaultCamera()
        applyAutolayout()
    }

    func mapStyleDidLoad() {
        os_log(.info, "MapView did load")

        updateToolbarItems()

        // The below line is used for internal testing purposes only.
        finish()
    }

    func updateToolbarItems(animated: Bool = true) {
         setToolbarItems([
            UIBarButtonItem(title: "Start", style: .done, target: self, action: #selector(startAnimation)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Delay start", style: .plain, target: self, action: #selector(startFrameAnimationsNow_PropertyAnimator)),
            UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(startBackFrameAnimationsNow_PropertyAnimator)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Manual", style: .plain, target: self, action: #selector(resizeWithoutAnimation)),
        ], animated: animated)
    }

    enum AnimationDirection {
        case expanding
        case shrinking

        mutating func toggle() {
            switch self {
            case .expanding:
                self = .shrinking
            case .shrinking:
                self = .expanding
            }
        }
    }

    func animateResizing(direction: AnimationDirection) {
        switch direction {
        case .expanding:
            NSLayoutConstraint.activate(fullSizeConstraints)
        case .shrinking:
            NSLayoutConstraint.deactivate(fullSizeConstraints)
        }
        view.layoutIfNeeded()
    }

    // MARK: - UIView.animate
    @objc func startAnimation() {
        os_log(.default, "Shrinking animation with UIView.animate")
        UIView.animate(withDuration: 2, delay: 0) {
            self.animateResizing(direction: .shrinking)
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                os_log(.default, "Expanding animation with UIView.animate")
                UIView.animate(withDuration: 2, delay: 0) {
                    self.animateResizing(direction: .expanding)
                }
            }
        }
    }

    // MARK: UIViewPropertyAnimator
    @objc
    func startFrameAnimationsNow_PropertyAnimator() {
        os_log(.info, "Shrinking animation with UIViewPropertyAnimator")
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 2, delay: 1) {
            self.animateResizing(direction: .shrinking)
        }
    }

    @objc
    func startBackFrameAnimationsNow_PropertyAnimator() {
        os_log(.info, "Expanding animation with UIViewPropertyAnimator")
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 2, delay: 1) {
            self.animateResizing(direction: .expanding)
        }
    }

    // MARK: Without animation
    var lastManualResizingDirection: AnimationDirection = .expanding {
        didSet {
            animateResizing(direction: lastManualResizingDirection)
        }
    }

    @objc
    func resizeWithoutAnimation() {
        os_log(.default, "%@ without animation", lastManualResizingDirection == .shrinking ? "Shrinking" : "Expanding")

        lastManualResizingDirection.toggle()
    }

    // MARK: -

    func setupDefaultCamera() {
        let london = (coordinates: CLLocationCoordinate2D(latitude: 51.4724912, longitude: -0.0334334), zoom: 12.0, span: 4800.0)

        mapboxMapView.mapboxMap.setCamera(to: CameraOptions(center: london.coordinates, zoom: london.zoom))
    }

    func applyAutolayout() {
        for view in [mapsStackView, mapboxMapView, mapsContentView] {
            view?.translatesAutoresizingMaskIntoConstraints = false
        }

        let fullHeightConstraint = mapsStackView.heightAnchor.constraint(equalTo: mapsContentView.heightAnchor, multiplier: 1)
        fullHeightConstraint.identifier = "Full height container"
        let partialHeightConstraint = mapsStackView.heightAnchor.constraint(equalTo: mapsContentView.heightAnchor, multiplier: 0.5)
        partialHeightConstraint.identifier = "Partial height container"
        partialHeightConstraint.priority = .defaultLow

        let fullWidthConstraint = mapsStackView.widthAnchor.constraint(equalTo: mapsContentView.widthAnchor, multiplier: 1)
        let partialWidthConstraint = mapsStackView.widthAnchor.constraint(equalTo: mapsContentView.widthAnchor, multiplier: 0.5)
        partialWidthConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            fullWidthConstraint,
            partialWidthConstraint,
            mapsStackView.centerXAnchor.constraint(equalTo: mapsContentView.centerXAnchor),

            fullHeightConstraint,
            partialHeightConstraint,
            mapsStackView.bottomAnchor.constraint(equalTo: mapsContentView.bottomAnchor),

            mapsContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapsContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapsContentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapsContentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        fullSizeConstraints.append(fullWidthConstraint)
        fullSizeConstraints.append(fullHeightConstraint)
    }
}
