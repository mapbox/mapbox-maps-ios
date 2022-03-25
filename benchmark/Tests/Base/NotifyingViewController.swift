import UIKit

final class NotifyingViewController: UIViewController {

    private var viewDidAppearBlock: (()->())?

    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearBlock?()
        viewDidAppearBlock = nil
    }

    public func whenVisible(_ block: @escaping ()->()) {
        self.viewDidAppearBlock = block
    }
}

