import UIKit
import CoreLocation

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

public class MapboxScaleBarOrnamentView: UIView {

    public typealias Row = (distance: CLLocationDistance, numberOfBars: UInt)

    // MARK: - Properties

    public var metersPerPoint: CLLocationDistance = 1 {
        didSet {
            guard metersPerPoint != oldValue else {
                return
            }

            updateVisibility()
            needsRecalculateSize = true
            invalidateIntrinsicContentSize()
        }
    }

    lazy private var labelViews: [UIView] = {
        var labels: [UIView] = []
        for _ in 0..<4 {
            let view = UIView()
            view.clipsToBounds = false
            view.contentMode = .center
            view.isHidden = true

            labels.append(view)
            addSubview(view)
        }
        return labels
    }()

    private var _bars: [UIView]?
    private var bars: [UIView] {
        if _bars == nil {
            var bars: [UIView] = []
            for _ in 0..<row.numberOfBars {
                let bar = UIView()
                self.containerView.addSubview(bar)
                bars.append(bar)
            }
            _bars = bars
        }
        return _bars!
    }

    lazy private var containerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = Constants.primaryColor
        view.layer.borderColor = Constants.primaryColor.cgColor
        view.layer.borderWidth = Constants.borderWidth / UIScreen.main.scale
        view.layer.cornerRadius = Constants.barHeight / 2.0
        view.layer.masksToBounds = true

        addSubview(view)

        return view
    }()

    private let formatter = DistanceFormatter()

    private var row: Row = (0, 0) {
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
    private var size = CGSize()
    private var needsRecalculateSize = false
    private var shouldLayoutBars = false

    private var unitsPerPoint: Double {
        return isMetricLocale ? metersPerPoint : metersPerPoint * Constants.feetPerMeter
    }

    private var maximumWidth: CGFloat {
        guard let bounds = superview?.bounds else {
            return 0
        }
        return floor(bounds.width / 2)
    }

    private var isMetricLocale: Bool {
        return Locale(identifier: Bundle.main.preferredLocalizations.first!).usesMetricSystem
    }

    public override var intrinsicContentSize: CGSize {
        // Size is calculated elsewhere - since 'intrinsicContentSize' is part of the
        // constraint system, this should be done in 'updateConstraints'
        guard size.width >= 0 else {
            return CGSize()
        }
        return size
    }

    // MARK: - Initialization

    override public init(frame: CGRect) {
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
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false

        addZeroLabel()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resetLabelImageCache),
                                               name: NSLocale.currentLocaleDidChangeNotification,
                                               object: nil)
    }

    // MARK: - Layout

    // The primary job of 'updateConstraints' here is to recalculate the
    // 'intrinsicContentSize:', 'metersPerPoint' and the maximum width determine the
    // current 'row', which in turn determines the "actualWidth". To obtain the full
    // width of the scale bar, we also need to include some space for the "last"
    // label
    public override func updateConstraints() {
        guard !isHidden && needsRecalculateSize else {
            super.updateConstraints()
            return
        }

        // TODO: Improve this (and the side-effects)
        row = preferredRow()

        assert(row.numberOfBars > 0, "Wrong number of bars in ScaleBar ornament")

        let totalBarWidth = actualWidth()

        guard totalBarWidth > 0.0 else {
            super.updateConstraints()
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
        super.updateConstraints() // This calls intrinsicContentSize
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        guard needsRecalculateSize else {
            return
        }

        needsRecalculateSize = false

        let totalBarWidth = actualWidth()
        guard size.width > 0 && totalBarWidth > 0 else {
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
        let barOffset = isRightToLeft ? halfLabelWidth : 0.0

        containerView.frame = CGRect(x: barOffset,
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
            let xPostion = barWidth * CGFloat($0.offset)
            $0.element.backgroundColor = ($0.offset % 2 == 0) ? Constants.primaryColor : Constants.secondaryColor
            $0.element.frame = CGRect(x: xPostion, y: 0, width: barWidth, height: Constants.barHeight)
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

    @objc
    private func resetLabelImageCache() {
        labelImageCache.removeAll()
        addZeroLabel()
    }

    private func cachedLabelImage(for distance: CLLocationDistance) -> UIImage {
        if let image = labelImageCache[distance] {
            return image
        } else {
            let text = formatter.string(fromDistance: distance)
            let image = renderImageFor(text: text)
            labelImageCache[distance] = image
            return image
        }
    }

    private func updateLabels() {
        var multiplier = row.distance / Double(row.numberOfBars)

        if !isMetricLocale {
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

    // MARK: - Convenince Methods

    private func usesRightToLeftLayout() -> Bool {
        return UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
    }

    private func preferredRow() -> Row {
        let maximumDistance: CLLocationDistance = Double(maximumWidth) * unitsPerPoint
        let table = isMetricLocale ? Constants.metricTable : Constants.imperialTable
        let rowIndex = table.firstIndex {
            return $0.distance > maximumDistance
        } ?? 0

        guard rowIndex > 0 else {
            return table.first!
        }

        return table[rowIndex - 1]
    }

    private func updateVisibility() {
        let maximumDistance: CLLocationDistance = Double(maximumWidth) * unitsPerPoint
        let allowedDistance = isMetricLocale ?
                              Constants.metricTable.last!.distance : Constants.imperialTable.last!.distance
        let alpha: CGFloat = maximumDistance > allowedDistance ? 0 : 1

        if alpha != self.alpha {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .beginFromCurrentState,
                           animations: {
                            self.alpha = alpha
            },
                           completion: nil)
        }
    }
}
