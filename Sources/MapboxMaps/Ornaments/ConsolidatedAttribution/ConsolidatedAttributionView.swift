import UIKit

/// Reuses UIKit's touch tracking (drag-out, cancel, etc.) for the highlight overlay.
private final class HighlightingButton: UIButton {
    var onHighlightChange: ((Bool) -> Void)?

    /// Apple's minimum recommended touch target.
    static let minTouchTarget: CGFloat = 44

    /// Takes touches in a target grown to `minTouchTarget`, centered on the button.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: -max(0, Self.minTouchTarget - bounds.width) / 2,
                       dy: -max(0, Self.minTouchTarget - bounds.height) / 2)
            .contains(point)
    }

    override var isHighlighted: Bool {
        didSet {
            guard oldValue != isHighlighted else { return }
            onHighlightChange?(isHighlighted)
        }
    }
}

private extension UILayoutPriority {
    /// Below `.required` to avoid an unsatisfiable layout against the pill's max width.
    static let logoCompressionResistance = UILayoutPriority(999)
}

// MARK: - ConsolidatedAttributionView

/// Pill with the Mapbox logo, the copyright text and, while expanded, a chevron.
///
/// The view width animates between the collapsed width and the content width, and
/// `clipsToBounds` hides the rest.
final class ConsolidatedAttributionView: UIView {

    private enum Metrics {
        static let height: CGFloat = 28
        static let horizontalInset: CGFloat = 4
        static let spacing: CGFloat = 4
        /// The pin glyph has built-in padding, so zero looks balanced.
        static let iconWordmarkSpacing: CGFloat = 0
        static let chevronTrailingInset: CGFloat = 6
        static let collapsedWordmarkTrailingInset: CGFloat = 7
        static let textFontSize: CGFloat = 10
        static let highlightFadeIn: TimeInterval = 0.08
        static let highlightFadeOut: TimeInterval = 0.2
        /// Dims content on press, like UIKit controls do.
        static let highlightedContentAlpha: CGFloat = 0.7
    }

    let model: ConsolidatedAttributionModel

    /// Background and the only tap target. A real control gives hit testing and VoiceOver.
    private let bodyButton = HighlightingButton(type: .custom)
    private let highlightView = UIView()
    private let contentStack = UIStackView()
    private let iconView = LogoIconView()
    private let wordmarkView = LogoWordmarkView()
    private let textLabel = UILabel()
    /// In `contentStack`, not pinned to the trailing edge, so on collapse it is clipped with
    /// the text instead of sliding over it.
    private let chevronView = ChevronView()

    private var expandedTrailingConstraint: NSLayoutConstraint!
    private var collapsedTrailingConstraint: NSLayoutConstraint!
    private var iconOnlyTrailingConstraint: NSLayoutConstraint!

    init(model: ConsolidatedAttributionModel) {
        self.model = model
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        backgroundColor = .clear

        setUpSubviews()
        applyAppearance()
        applyState(animated: false)

        model.onStateChange = { [weak self] animated in
            self?.applyState(animated: animated)
        }
        model.onAppearanceChange = { [weak self] in
            self?.applyAppearance()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setUpSubviews() {
        bodyButton.translatesAutoresizingMaskIntoConstraints = false
        bodyButton.clipsToBounds = true
        bodyButton.accessibilityLabel = NSLocalizedString(
            "CONSOLIDATED_ATTR_ICON_A11Y_LABEL",
            tableName: Ornaments.localizableTableName,
            bundle: .mapboxMaps,
            value: "Mapbox",
            comment: "Consolidated attribution icon accessibility label")
        bodyButton.accessibilityHint = NSLocalizedString(
            "CONSOLIDATED_ATTR_ICON_A11Y_HINT",
            tableName: Ornaments.localizableTableName,
            bundle: .mapboxMaps,
            value: "Shows map credits and settings",
            comment: "Consolidated attribution icon accessibility hint")
        bodyButton.addTarget(self, action: #selector(bodyTapped), for: .touchUpInside)
        bodyButton.onHighlightChange = { [weak self] highlighted in
            self?.setHighlighted(highlighted)
        }
        addSubview(bodyButton)

        highlightView.translatesAutoresizingMaskIntoConstraints = false
        highlightView.isUserInteractionEnabled = false
        highlightView.alpha = 0
        // The button clips to the capsule, so the overlay takes its shape.
        bodyButton.addSubview(highlightView)

        textLabel.font = .systemFont(ofSize: Metrics.textFontSize)
        textLabel.numberOfLines = 1
        textLabel.lineBreakMode = .byTruncatingTail
        textLabel.isAccessibilityElement = false

        // On a narrow map only the text should truncate. Keep the label at the default
        // priority: lowering it shrinks the text to nothing.
        iconView.setContentCompressionResistancePriority(.logoCompressionResistance, for: .horizontal)
        wordmarkView.setContentCompressionResistancePriority(.logoCompressionResistance, for: .horizontal)
        chevronView.setContentCompressionResistancePriority(.logoCompressionResistance, for: .horizontal)

        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = Metrics.spacing
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.isUserInteractionEnabled = false
        [iconView, wordmarkView, textLabel, chevronView]
            .forEach(contentStack.addArrangedSubview)
        contentStack.setCustomSpacing(Metrics.iconWordmarkSpacing, after: iconView)
        addSubview(contentStack)

        setUpConstraints()
    }

    private func setUpConstraints() {
        expandedTrailingConstraint = trailingAnchor.constraint(
            equalTo: contentStack.trailingAnchor, constant: Metrics.chevronTrailingInset)
        collapsedTrailingConstraint = trailingAnchor.constraint(
            equalTo: wordmarkView.trailingAnchor, constant: Metrics.collapsedWordmarkTrailingInset)
        iconOnlyTrailingConstraint = trailingAnchor.constraint(
            equalTo: iconView.trailingAnchor, constant: Metrics.horizontalInset)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Metrics.height),

            bodyButton.topAnchor.constraint(equalTo: topAnchor),
            bodyButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            bodyButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            bodyButton.trailingAnchor.constraint(equalTo: trailingAnchor),

            highlightView.topAnchor.constraint(equalTo: bodyButton.topAnchor),
            highlightView.bottomAnchor.constraint(equalTo: bodyButton.bottomAnchor),
            highlightView.leadingAnchor.constraint(equalTo: bodyButton.leadingAnchor),
            highlightView.trailingAnchor.constraint(equalTo: bodyButton.trailingAnchor),

            // Leading edge only, so the stack keeps its width while the view width animates.
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.horizontalInset),
            contentStack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    // MARK: - Appearance

    private var renderOptions: ConsolidatedAttributionOptions {
        model.options ?? ConsolidatedAttributionOptions()
    }

    private func applyAppearance() {
        bodyButton.backgroundColor = ConsolidatedAttributionPalette.pill(
            renderOptions.material, tint: renderOptions.tintColor)
        iconView.pinColor = ConsolidatedAttributionPalette.content
        iconView.starColor = ConsolidatedAttributionPalette.detail
        wordmarkView.letterColor = ConsolidatedAttributionPalette.content
        wordmarkView.detailColor = ConsolidatedAttributionPalette.detail
        textLabel.textColor = ConsolidatedAttributionPalette.content
        chevronView.shapeColor = ConsolidatedAttributionPalette.content
        chevronView.outlineColor = ConsolidatedAttributionPalette.detail
        highlightView.backgroundColor = ConsolidatedAttributionPalette.highlight
    }

    /// The logo views draw colors in `draw(_:)`, which UIKit doesn't redo on a style change.
    @available(iOS, deprecated: 17.0, message: "Kept for the iOS 14 deployment target.")
    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previous) else { return }
        iconView.setNeedsDisplay()
        wordmarkView.setNeedsDisplay()
        chevronView.setNeedsDisplay()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bodyButton.layer.cornerRadius = bounds.height / 2
    }

    // MARK: - State

    private func updateContent() {
        textLabel.text = model.attributionText
        textLabel.isHidden = model.attributionText.isEmpty
    }

    private func applyState(animated: Bool) {
        updateContent()

        let expanded = model.isExpanded
        let iconOnly = renderOptions.collapsedStyle == .iconOnly
        NSLayoutConstraint.deactivate([expandedTrailingConstraint, collapsedTrailingConstraint, iconOnlyTrailingConstraint])
        if expanded {
            expandedTrailingConstraint.isActive = true
        } else if iconOnly {
            iconOnlyTrailingConstraint.isActive = true
        } else {
            collapsedTrailingConstraint.isActive = true
        }

        // The superview sets our frame, and our constraint changes don't mark it for layout.
        superview?.setNeedsLayout()

        let targetAlpha: CGFloat = expanded ? 1 : 0
        // The wordmark starts at the icon edge, so clipping alone would show its first letters.
        let wordmarkAlpha: CGFloat = expanded || !iconOnly ? 1 : 0
        let animations = {
            self.textLabel.alpha = targetAlpha
            self.wordmarkView.alpha = wordmarkAlpha
            self.superview?.layoutIfNeeded()
        }
        // A view that was never laid out has nothing to animate from.
        guard animated, !bounds.isEmpty else {
            UIView.performWithoutAnimation {
                chevronView.alpha = targetAlpha
                animations()
            }
            return
        }
        UIView.animate(withDuration: Self.animationDuration,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState],
                       animations: animations)
        // The edge reaches the chevron first on collapse, so a shorter fade ends before the
        // clip cuts it off mid-fade.
        UIView.animate(withDuration: Self.chevronFadeDuration,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState],
                       animations: { self.chevronView.alpha = targetAlpha })
    }

    // MARK: - Interaction

    /// Lets touches around the pill reach `bodyButton`, whose touch target is larger.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bodyButton.point(inside: convert(point, to: bodyButton), with: event)
    }

    @objc private func bodyTapped() {
        model.handleTap()
    }

    private func setHighlighted(_ highlighted: Bool) {
        UIView.animate(
            withDuration: highlighted ? Metrics.highlightFadeIn : Metrics.highlightFadeOut,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: {
                self.highlightView.alpha = highlighted ? 1 : 0
                self.contentStack.alpha = highlighted ? Metrics.highlightedContentAlpha : 1
            })
    }

    private static let animationDuration: TimeInterval = 0.4
    private static let chevronFadeDuration = animationDuration * 0.4
}
