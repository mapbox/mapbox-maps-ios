import UIKit.UIGestureRecognizerSubclass

internal class TouchBeganGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .recognized
    }
}
