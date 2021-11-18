/// Wraps a `UIView` instance when added to `ViewAnnotationManager`
public final class AnnotationView: UIView {

    private static var currentId = 0
    internal let id: String = {
        let id = String(currentId)
        currentId += 1
        return id
    }()
    internal let wrappedView: UIView
    internal var ignoreUserEvents: Bool = false

    // In case the user changes the visibility of the AnnotationView, we should update the options to remove it from the layout calculation
    public override var isHidden: Bool {
        didSet {
            guard !ignoreUserEvents else { return }
            guard let manager = annotationManager else { return }
            let options = manager.options(for: self)
            let visible = !isHidden
            if visible != options?.visible {
                try? manager.update(self, options: ViewAnnotationOptions(visible: visible))
            }
        }
    }
    private weak var annotationManager: ViewAnnotationManager?

    internal init(view: UIView, annotationManager: ViewAnnotationManager) {
        wrappedView = view
        self.annotationManager = annotationManager
        super.init(frame: .zero)

        // Disable constraints until the first size information is received
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(wrappedView)
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            wrappedView.topAnchor.constraint(equalTo: topAnchor),
            wrappedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            wrappedView.leftAnchor.constraint(equalTo: leftAnchor),
            wrappedView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }

    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func setInternalVisibility(isHidden: Bool) {
        ignoreUserEvents = true
        self.isHidden = isHidden
        ignoreUserEvents = false
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }

}
