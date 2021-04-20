import UIKit

internal class FlyToAnimator: NSObject, CameraAnimatorProtocol {
    
    internal weak var delegate: CameraAnimatorDelegate?
    
    internal var owner: AnimationOwner
    
    internal var flyToInterpolator: FlyToInterpolator?
    
    internal var animationDuration: TimeInterval?
    
    internal private(set) var state: UIViewAnimatingState = .inactive
    
    internal var startTime: Date?
    
    internal var endTime: Date?
    
    internal var finalCameraOptions: CameraOptions?
    
    internal init(delegate: CameraAnimatorDelegate,
                  owner: AnimationOwner = .custom(id: "fly-to")) {
        
        self.delegate = delegate
        self.owner = owner
    }
    
    deinit {
        flyToInterpolator = nil
        stopAnimation()
    }
    
    internal func makeFlyToInterpolator(from initalCamera: CameraOptions, to finalCamera: CameraOptions, duration: TimeInterval? = nil, screenFullSize: CGSize) {
        
        guard let flyTo = FlyToInterpolator(from: initalCamera,
                                                        to: finalCamera,
                                                        size: screenFullSize) else {
            assertionFailure("FlyToInterpolator could not be created.")
            return
        }
        
        
        
        var time = duration ?? -1.0

        // If there was no duration specified, or a negative argument, use a default
        if time < 0.0 {
            time = flyTo.duration()
        }
        
        animationDuration = time
        flyToInterpolator = flyTo
        finalCameraOptions = finalCamera
    }
    
    func stopAnimation() {
        print("Stop animation called!")
        state = .stopped
        flyToInterpolator = nil
    }
    
    func startAnimation() {
        
        guard flyToInterpolator != nil, let animationDuration = animationDuration else {
            fatalError("FlyToInterpolator not created")
        }
        
        state = .active
        startTime = Date()
        endTime = startTime?.addingTimeInterval(animationDuration)
    }
    
    func addCompletion() {
        
    }
    
    func update() {
        
        guard state == .active,
              let startTime = startTime,
              let endTime = endTime,
              let animationDuration = animationDuration,
              let flyTo = flyToInterpolator else {
            return
        }
        
        
        let currentTime = Date()
        
        guard currentTime <= endTime else {
            flyToInterpolator = nil
            state = .stopped
            
            return
        }
        
        let fractionComplete = currentTime.timeIntervalSince(startTime) / animationDuration
        
        let cameraOptions = CameraOptions(center: flyTo.coordinate(at: fractionComplete),
                                          zoom: CGFloat(flyTo.zoom(at: fractionComplete)),
                                          bearing: flyTo.bearing(at: fractionComplete),
                                          pitch: CGFloat(flyTo.pitch(at: fractionComplete)))
        
        delegate?.jumpTo(camera: cameraOptions)
        
    }
}
