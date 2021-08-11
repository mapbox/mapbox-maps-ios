import GameController


public class GameController: NSObject {

    // Camera TODO
    deinit {
        print("here")
    }
    var virtualController: GCVirtualController?

    public var leftThumbstickHandler: ((_ x: Float, _ y: Float) -> Void)?
    public var rightThumbstickHandler: ((_ x: Float, _ y: Float) -> Void)?
    public var buttonAHandler: (() -> Void)?
    public var buttonBHandler: (() -> Void)?


    var gamePadCurrent: GCController?
    internal var gamePadLeft: GCControllerDirectionPad?
    internal var gamePadRight: GCControllerDirectionPad?
    private var buttonA: GCControllerButtonInput?
    private var buttonB: GCControllerButtonInput?


    public func setupGameController() {
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.handleControllerDidConnect),
                name: NSNotification.Name.GCControllerDidBecomeCurrent,
                object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleControllerDidDisconnect),
            name: NSNotification.Name.GCControllerDidStopBeingCurrent,
            object: nil)

        let virtualConfiguration = GCVirtualController.Configuration()
        virtualConfiguration.elements = [GCInputLeftThumbstick,
                                         GCInputRightThumbstick,
                                         GCInputButtonA,
                                         GCInputButtonB]

        virtualController = GCVirtualController(configuration: virtualConfiguration)

        // Connect to the virtual controller if no physical controllers are available.
        if GCController.controllers().isEmpty {
            virtualController?.connect(replyHandler: { error in
                if let error = error {
                    print("connect error = \(error)")
                }
            })
        }

        guard let controller = GCController.controllers().first else {
            return
        }

        registerGameController(controller)
    }

    func registerGameController(_ gameController: GCController) {

        if let gamepad = gameController.extendedGamepad {
            gamePadLeft = gamepad.leftThumbstick
            gamePadRight = gamepad.rightThumbstick
            buttonA = gamepad.buttonA
            buttonB = gamepad.buttonB
        }

        gamePadLeft?.valueChangedHandler = { [weak self] (thing, x, y) in
            self?.leftThumbstickHandler?(x, y)
        }

        gamePadRight?.valueChangedHandler = { [weak self] (thing, x, y) in
            self?.rightThumbstickHandler?(x, y)
        }

        buttonA?.valueChangedHandler = { [weak self] (_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
            if pressed {
                self?.buttonAHandler?()
            }
        }

        buttonB?.valueChangedHandler = { [weak self] (_ button: GCControllerButtonInput, _ value: Float, _ pressed: Bool) -> Void in
            if pressed {
                self?.buttonBHandler?()
            }
        }

        gamePadCurrent = gameController
    }

    func unregisterGameController() {
        gamePadLeft = nil
        gamePadRight = nil
        gamePadCurrent = nil
    }

    @objc
    func handleControllerDidConnect(_ notification: Notification) {
        guard let gameController = notification.object as? GCController else {
            return
        }
        unregisterGameController()

        if gameController != virtualController?.controller {
            virtualController?.disconnect()
        }

        registerGameController(gameController)
    }

    @objc
    func handleControllerDidDisconnect(_ notification: Notification) {
        unregisterGameController()

        guard let gameController = notification.object as? GCController else {
            return
        }

        if GCController.controllers().isEmpty {
            virtualController?.connect()
        }
    }
}
