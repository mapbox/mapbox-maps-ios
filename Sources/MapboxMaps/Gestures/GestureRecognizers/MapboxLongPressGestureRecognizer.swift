import Foundation
import UIKit

// Custom long press gesture recognizer used for dragging annotations.
//Takes translation into account for began and changed states.
internal class MapboxLongPressGestureRecognizer: UILongPressGestureRecognizer {
    private var translationReference: CGPoint = .zero
    private var translation: CGPoint = .zero

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)

        addTarget(self, action: #selector(stateDidChange))
    }

    @objc private func stateDidChange() {
        switch state {
        case .began:
            translationReference = location(in: view)
        case .changed:
            let touchLocation = location(in: view)
            translation = CGPoint(
                x: translationReference.x - touchLocation.x,
                y: translationReference.y - touchLocation.y
            )
        default:
            break
        }
    }

    internal func translation(in view: UIView?) -> CGPoint {
        if self.view == view {
            return translation
        }

        return self.view?.convert(translation, to: view ?? self.view?.window) ?? .zero
    }

    internal func setTranslation(_ translation: CGPoint, in view: UIView?) {
        guard let newTranslation = self.view?.convert(translation, from: view) else {
            return
        }

        let touchLocation = location(in: self.view)

        self.translationReference = CGPoint(
            x: touchLocation.x + newTranslation.x,
            y: touchLocation.y + newTranslation.y
        )
        self.translation = newTranslation
    }
}
