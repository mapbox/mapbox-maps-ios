import UIKit

/// UIKit examples opened from Search are pushed by SwiftUI, so their navigationItem is ignored by the
/// visible navigation bar. This container mirrors it onto the hosting controller's, which the bar reads.
final class NavigationItemBridgeController: UIViewController {
    private let child: UIViewController
    private var observations: [NSKeyValueObservation] = []

    init(child: UIViewController) {
        self.child = child
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(child)
        child.view.frame = view.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(child.view)
        child.didMove(toParent: self)

        // Examples may set bar buttons after appearing (e.g. in onMapLoaded), so track changes.
        let item = child.navigationItem
        let resync: (UINavigationItem, Any) -> Void = { [weak self] _, _ in self?.syncNavigationItem() }
        observations = [
            item.observe(\.rightBarButtonItems, changeHandler: resync),
            item.observe(\.leftBarButtonItems, changeHandler: resync),
            item.observe(\.titleView, changeHandler: resync),
            item.observe(\.title, changeHandler: resync),
        ]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        syncNavigationItem()
    }

    private func syncNavigationItem() {
        // The bar reads the navigationItem of the controller sitting directly in the
        // UINavigationController — the SwiftUI hosting controller somewhere up the parent chain.
        var host: UIViewController = self
        while let parent = host.parent, !(parent is UINavigationController) { host = parent }
        guard host.parent is UINavigationController else { return }

        let source = child.navigationItem
        let target = host.navigationItem
        target.title = source.title ?? child.title
        target.titleView = source.titleView
        target.rightBarButtonItems = source.rightBarButtonItems
        target.leftBarButtonItems = source.leftBarButtonItems
        target.leftItemsSupplementBackButton = true
        target.largeTitleDisplayMode = source.largeTitleDisplayMode
    }
}
