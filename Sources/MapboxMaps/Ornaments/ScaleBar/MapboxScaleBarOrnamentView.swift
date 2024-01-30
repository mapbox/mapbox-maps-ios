import UIKit
import CoreLocation

//swiftlint:disable:next type_body_length
internal class MapboxScaleBarOrnamentView: UIView {

    internal typealias Row = (distance: CLLocationDistance, numberOfBars: UInt)

    // MARK: - Properties

    // This view should have size and positioning that matches the root scale bar.
    // It contains the `dynamicContainerView` in order to avoid triggering `layoutSubviews`
    // on the map view.
    internal var staticContainerView = UIView()

    internal var metersPerPoint: CLLocationDistance = 1 {
        didSet {
            guard metersPerPoint != oldValue else {
                return
            }

            updateVisibility()
            needsRecalculateSize = true
            updateScaleBar()
        }
    }

    lazy internal var labelViews: [UIView] = {
        var labels: [UIView] = []
        for _ in 0..<4 {
            let view = UIView()
            view.clipsToBounds = false
            view.contentMode = .center
            view.isHidden = true

            labels.append(view)
            staticContainerView.addSubview(view)
        }
        return labels
    }()

    private var _bars: [UIView]?
    internal var bars: [UIView] {
        if _bars == nil {
            var bars: [UIView] = []
            for _ in 0..<row.numberOfBars {
                let bar = UIView()
                self.dynamicContainerView.addSubview(bar)
                bars.append(bar)
            }
            _bars = bars
        }
        return _bars!
    }

    var isOnRight = false
    var size = CGSize()
    // This container view's size and position can change based on the size
    // of its contents. It is contained within the `staticContainerView`.
    lazy internal var dynamicContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.primaryColor
        view.layer.borderColor = Constants.primaryColor.cgColor
        view.layer.borderWidth = Constants.borderWidth / max(traitCollection.displayScale, 1.0) // displayScale can be zero
        view.layer.cornerRadius = Constants.barHeight / 2.0
        view.layer.masksToBounds = true

        return view
    }()

    private let formatter = DistanceFormatter()

    internal var row: Row = (0, 0) {
        didSet {
            guard row.distance != oldValue.distance else {
                return
            }
            shouldLayoutBars = true
        }
    }

    private var prototypeLabel: MapboxScaleBarLabel = {
        let label = MapboxScaleBarLabel()
        label.font = UIFont.systemFont(ofSize: 8, weight: .medium)
        label.clipsToBounds = false

        return label
    }()

    private var labelImageCache: [CLLocationDistance: UIImage] = [:]
    private var lastLabelWidth: CGFloat = Constants.scaleBarLabelWidthHint
    private var needsRecalculateSize = false
    private var shouldLayoutBars = false

    internal var unitsPerPoint: Double {
        return useMetricUnits ? metersPerPoint : metersPerPoint * Constants.feetPerMeter
    }

    internal var maximumWidth: CGFloat {
        guard let bounds = superview?.bounds else {
            return 0
        }
        return floor(bounds.width / 2)
    }

    internal var useMetricUnits: Bool = true {
        didSet {
            guard useMetricUnits != oldValue else {
                return
            }

            updateVisibility()
            needsRecalculateSize = true
            updateScaleBar()

            resetLabelImageCache()
        }
    }

    internal override var intrinsicContentSize: CGSize {
        // Size is calculated elsewhere - since 'intrinsicContentSize' is part of the
        // constraint system, this should be done in 'updateScaleBar'
        return size
    }

    // MARK: - Initialization

    override internal init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required internal init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func commonInit() {
        clipsToBounds = false

        staticContainerView.backgroundColor = .clear
        staticContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(staticContainerView)

        staticContainerView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        staticContainerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        staticContainerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        staticContainerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        staticContainerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        staticContainerView.addSubview(dynamicContainerView)

        addZeroLabel()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resetLabelImageCache),
                                               name: NSLocale.currentLocaleDidChangeNotification,
                                               object: nil)
    }

    override func didMoveToSuperview() {
        // Set the width anchor once the scale bar has superview.
        staticContainerView.widthAnchor.constraint(equalToConstant: maximumWidth).isActive = true
    }

    // MARK: - Layout

    // The primary job of 'updateScaleBar' here is to recalculate
    // 'metersPerPoint' and the maximum width determine the
    // current 'row', which in turn determines the "actualWidth". To obtain the full
    // width of the scale bar, we also need to include some space for the "last"
    // label
    internal func updateScaleBar() {
        guard !isHidden && needsRecalculateSize else {
            return
        }

        // TODO: Improve this (and the side-effects)
        row = preferredRow()

        assert(row.numberOfBars > 0, "Wrong number of bars in ScaleBar ornament")

        let totalBarWidth = actualWidth()

        guard totalBarWidth > 0.0 else {
            return
        }

        // Determine the "lastLabelWidth". This has changed to take a maximum of each
        // label, to ensure that the size does not change in LTR & RTL layouts, and
        // also to stop jiggling when the scale bar is on the right hand of the screen
        // This will most likely be a constant, as we take a max using a "hint" for
        // the initial value

        if shouldLayoutBars {
            updateLabels()
        }

        let halfLabelWidth = ceil(lastLabelWidth / 2)

        size = CGSize(width: totalBarWidth + halfLabelWidth, height: 16)
        setNeedsLayout()
    }

    internal override func layoutSubviews() {
        super.layoutSubviews()

        guard needsRecalculateSize else {
            return
        }

        needsRecalculateSize = false

        let totalBarWidth = actualWidth()
        guard totalBarWidth > 0 else {
            return
        }

        if shouldLayoutBars {
            shouldLayoutBars = false
            bars.forEach { $0.removeFromSuperview() }
            _bars = nil
        }

        // Re-layout the component bars and labels of the scale bar
        let barWidth = totalBarWidth / CGFloat(bars.count)
        let isRightToLeft = usesRightToLeftLayout()
        let halfLabelWidth = ceil(lastLabelWidth / 2)
        //
        let scaleBarOffsetForRight = staticContainerView.frame.width - totalBarWidth - halfLabelWidth
        let barOffset = isRightToLeft || isOnRight ? scaleBarOffsetForRight : 0.0

        dynamicContainerView.frame = CGRect(x: barOffset,
                                     y: intrinsicContentSize.height - Constants.barHeight,
                                     width: totalBarWidth,
                                     height: Constants.barHeight)
        layoutBars(with: barWidth)

        let yPosition = round((intrinsicContentSize.height - Constants.barHeight) / 2)
        let barDelta = isRightToLeft ? -barWidth : barWidth

        layoutLabels(with: barOffset, delta: barDelta, yPosition: yPosition)
    }

    private func layoutBars(with barWidth: CGFloat) {
        bars.enumerated().forEach {
            let xPosition = barWidth * CGFloat($0.offset)
            $0.element.backgroundColor = ($0.offset % 2 == 0) ? Constants.primaryColor : Constants.secondaryColor
            $0.element.frame = CGRect(x: xPosition, y: 0, width: barWidth, height: Constants.barHeight)
        }
    }

    private func layoutLabels(with barOffset: CGFloat, delta: CGFloat, yPosition: CGFloat) {
        var xPosition = barOffset
        if delta < 0 {
            xPosition -= delta * CGFloat(bars.count)
        }

        labelViews.forEach {
            // Label frames have 0 size - though the layer contents use "center" and do
            // not clip to bounds. This way we don't need to worry about positioning the
            // label. (Though you won't see the label in the view debugger)
            $0.frame = CGRect(x: xPosition, y: yPosition, width: 0, height: 0)
            xPosition += delta
        }
    }

    // MARK: - Dimensions

    // Determines the width of the bars NOT the size of the entire scale bar,
    // which includes space for (half) a label.
    // Uses the current set `row`
    private func actualWidth() -> CGFloat {
        guard unitsPerPoint != 0 else {
            return 0
        }

        let width = CGFloat(row.distance / unitsPerPoint)

        guard width > Constants.scaleBarMinimumBarWidth else {
            return 0
        }

        // Round, so that each bar section has an integer width
        return CGFloat(row.numberOfBars) * floor(width / CGFloat(row.numberOfBars))
    }

    // MARK: - Labels methods

    private func addZeroLabel() {
        labelImageCache[0] = renderImageFor(text: "0")
    }

    private func renderImageFor(text: String) -> UIImage {
        prototypeLabel.text = text
        prototypeLabel.setNeedsDisplay()
        prototypeLabel.sizeToFit()

        let renderer = UIGraphicsImageRenderer(size: prototypeLabel.bounds.size)
        let image = renderer.image { context in
            prototypeLabel.layer.render(in: context.cgContext)
        }
        return image
    }

    @objc private func resetLabelImageCache() {
        labelImageCache.removeAll()
        addZeroLabel()
    }

    private func cachedLabelImage(for distance: CLLocationDistance) -> UIImage {
        if let image = labelImageCache[distance] {
            return image
        } else {
            let text = formatter.string(fromDistance: distance, useMetricSystem: useMetricUnits)
            let image = renderImageFor(text: text)
            labelImageCache[distance] = image
            return image
        }
    }

    private func updateLabels() {
        var multiplier = row.distance / Double(row.numberOfBars)

        if !useMetricUnits {
            multiplier /= Constants.feetPerMeter
        }

        labelViews.enumerated().forEach {
            $0.element.isHidden = $0.offset > row.numberOfBars

            if !$0.element.isHidden {
                let barDistance = multiplier * Double($0.offset)
                let image = cachedLabelImage(for: barDistance)
                lastLabelWidth = max(lastLabelWidth, image.size.width)

                $0.element.layer.contents = image.cgImage
                $0.element.layer.contentsScale = image.scale
            }
        }
    }

    // MARK: - Convenience Methods

    private func usesRightToLeftLayout() -> Bool {
        return effectiveUserInterfaceLayoutDirection == .rightToLeft
    }

    /// Returns the closest ``Row`` to display for the given `maxDistance`.
    /// - If `maxDistance` is greater than the max row's distance in predefined list, this predefined row will be used.
    /// - If `maxDistance` is less than the min row's distance in predefined list, a row with `maxDistance` (rounded to 1 decimal) and 1 bar will be used.
    internal func preferredRow() -> Row {
        let (maxDistance, rows) = maxDistanceAndRows()

        guard maxDistance.value >= rows[0].distance else {
            // If the minimum pre-defined distance does not fit the maximum width,
            // then we fallback to use maxDistance (rounded down with 0.25 granularity) displayed with 1 bar.
            return ((maxDistance.value * 4).rounded(.down) / 4, 1)
        }

        var preferredRow: MapboxScaleBarOrnamentView.Row!
        for row in rows {
            if row.distance > maxDistance.value { break }
            preferredRow = row
        }

        return preferredRow ?? rows.last!
    }

    private func updateVisibility() {
        let (maxDistance, rows) = maxDistanceAndRows()
        let allowedDistance = rows.last!.distance

        let alpha: CGFloat = maxDistance.value >= allowedDistance ? 0 : 1

        if alpha != staticContainerView.alpha {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                options: .beginFromCurrentState,
                animations: { self.staticContainerView.alpha = alpha },
                completion: nil)
        }
    }

    private func maxDistanceAndRows() -> (maxDistance: Measurement<UnitLength>, rows: [Row]) {
        let distanceInMeters = Measurement(value: metersPerPoint * maximumWidth, unit: UnitLength.meters)
        if useMetricUnits {
            return (distanceInMeters, Constants.metricTable)
        } else {
            return (distanceInMeters.converted(to: .feet), Constants.imperialTable)
        }
    }
}
