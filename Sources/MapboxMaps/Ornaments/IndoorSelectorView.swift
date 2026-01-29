import UIKit
@_spi(Experimental) import MapboxCoreMaps

final class IndoorSelectorView: UIView {
    private let model: IndoorSelectorModelProtocol
    private let collectionView: UICollectionView
    private let containerView: UIView
    private var topArrowButton: UIButton!
    private var bottomArrowButton: UIButton!

    init(model: IndoorSelectorModelProtocol) {
        self.model = model
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: Constants.flowLayout)
        self.containerView = UIView()

        super.init(frame: .zero)

        self.model.onFloorsUpdated = { [weak self] in
            self?.updateVisibility()
            self?.invalidateIntrinsicContentSize()
            self?.collectionView.reloadData()
            self?.setNeedsLayout()
            self?.updateLayout()
        }

        self.model.onFloorSelected = { [weak self] in
            self?.collectionView.reloadData()
        }

        self.model.onVisibilityChanged = { [weak self] in
            self?.updateVisibility()
        }

        self.topArrowButton = makeButton(.up)
        self.bottomArrowButton = makeButton(.down)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let totalItemHeight = CGFloat(model.floors.count) * Constants.itemSize
        let maxHeight = CGFloat(Constants.maxVisibleFloors) * Constants.itemSize
        return CGSize(width: Constants.itemSize, height: min(totalItemHeight, maxHeight))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }

    private func updateLayout() {
        let shouldShowArrows = model.floors.count > Constants.maxVisibleFloors
        let totalItemsHeight = CGFloat(model.floors.count) * Constants.itemSize
        let maxHeight = CGFloat(Constants.maxVisibleFloors) * Constants.itemSize
        let height = min(totalItemsHeight, maxHeight)
        let size = CGSize(width: Constants.itemSize, height: min(totalItemsHeight, maxHeight))

        bounds.size = size
        containerView.frame = CGRect(origin: .zero, size: size)
        collectionView.frame = containerView.bounds
        topArrowButton.isHidden = !shouldShowArrows
        bottomArrowButton.isHidden = !shouldShowArrows

        if shouldShowArrows {
            topArrowButton.frame = CGRect(x: 0, y: 0, width: Constants.itemSize, height: Constants.itemSize)
            bottomArrowButton.frame = CGRect(x: 0, y: height - Constants.itemSize, width: Constants.itemSize, height: Constants.itemSize)
        }

        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: Constants.cornerRadius).cgPath
        updateArrowVisibility()
    }

    private func updateArrowVisibility() {
        let shouldShowArrows = model.floors.count > Constants.maxVisibleFloors
        topArrowButton.isHidden = !shouldShowArrows
        bottomArrowButton.isHidden = !shouldShowArrows

        guard shouldShowArrows else { return }
        collectionView.layoutIfNeeded()

        let contentOffset = collectionView.contentOffset.y
        let maxOffset = collectionView.contentSize.height - collectionView.bounds.height

        guard maxOffset > 0 else {
            topArrowButton.isHidden = true
            bottomArrowButton.isHidden = true
            return
        }

        topArrowButton.isHidden = contentOffset <= 0 // is scroll position at the top
        bottomArrowButton.isHidden = contentOffset >= maxOffset // is scroll position at the bottom
    }

    private func updateVisibility() {
        guard isHidden != model.isHidden else { return }
        isHidden = model.isHidden
        if !isHidden {
            invalidateIntrinsicContentSize()
            collectionView.reloadData()
            setNeedsLayout()
            updateLayout()
        }
    }

    @objc private func scrollUpTapped() { scrollByOneItem(direction: .up) }
    @objc private func scrollDownTapped() { scrollByOneItem(direction: .down) }

    private func scrollByOneItem(direction: ScrollDirection) {
        guard collectionView.isScrollEnabled else { return }

        // Stop any ongoing scroll animation or deceleration, to avoid inertia after manual scroll leading to incorrect final position
        collectionView.setContentOffset(collectionView.contentOffset, animated: false)
        let maxOffset = collectionView.contentSize.height - collectionView.bounds.height

        // Snap current position to nearest item boundary first
        let currentIndex = round(collectionView.contentOffset.y / Constants.itemSize)
        let snappedOffset = currentIndex * Constants.itemSize

        // Ensure we don't go beyond bounds when snapping
        // To avoid incorrect offset calculation when tapping the arrow button immediately after the scroll drag
        let clampedSnappedOffset = max(0, min(maxOffset, snappedOffset))
        let actualCurrentIndex = round(clampedSnappedOffset / Constants.itemSize)

        // Calculate target index to ensure we always land on item boundaries
        let targetIndex = switch direction {
        case .up:
            max(0, actualCurrentIndex - 1)
        case .down:
            min(floor(maxOffset / Constants.itemSize), actualCurrentIndex + 1)
        }

        // Disable scroll while animating to prevent user interaction interference with the programmatic scroll animation
        collectionView.isScrollEnabled = false

        // Don't use setContentOffset(animated:) as there it no way to control animation duration through this API
        UIView.animate(withDuration: 0.1, animations: {
            self.collectionView.contentOffset = CGPoint(x: 0, y: targetIndex * Constants.itemSize)
        }, completion: { _ in
            self.collectionView.isScrollEnabled = true
            self.updateArrowVisibility()
        })
    }
}

// MARK: - UICollectionViewDataSource
extension IndoorSelectorView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { model.floors.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable:next force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
        let floor = model.floors[indexPath.item]
        cell.configure(title: floor.name, isSelected: floor.id == model.selectedFloorId)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension IndoorSelectorView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let floorId = model.floors[indexPath.item].id
        guard floorId != model.selectedFloorId else { return }
        model.selectFloor(floorId)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateArrowVisibility()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Only snap to grid for user-initiated drags, not programmatic scrolls
        guard collectionView.isScrollEnabled else { return }

        // Scroll to the nearest floor item
        let targetY = targetContentOffset.pointee.y
        let nearestFloorIndex = round(targetY / Constants.itemSize)
        let snappedY = nearestFloorIndex * Constants.itemSize
        targetContentOffset.pointee.y = snappedY
    }
}

extension IndoorSelectorView {
    private func setupView() {
        containerView.backgroundColor = UIColor.systemBackground.withAlphaComponent(1.0)
        containerView.layer.cornerRadius = Constants.cornerRadius
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = Constants.shadowOpacity
        containerView.layer.shadowRadius = Constants.cornerRadius
        containerView.layer.shadowOffset = Constants.shadowOffset
        containerView.layer.masksToBounds = false
        containerView.isUserInteractionEnabled = true
        containerView.isExclusiveTouch = true

        collectionView.backgroundColor = .clear
        collectionView.layer.cornerRadius = Constants.cornerRadius
        collectionView.layer.masksToBounds = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isUserInteractionEnabled = true
        collectionView.bounces = true
        collectionView.decelerationRate = .fast
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)

        isUserInteractionEnabled = true
        isExclusiveTouch = true
        isHidden = model.isHidden

        addSubview(containerView)
        containerView.addSubview(collectionView)
        [topArrowButton, bottomArrowButton].forEach { button in
            containerView.addSubview(button)
            containerView.bringSubviewToFront(button)
        }
    }

    private func makeButton(_ scrollDirection: ScrollDirection) -> UIButton {
        let button = UIButton(type: .system)
        let buttonConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let buttonAction = scrollDirection == .up ? #selector(scrollUpTapped) : #selector(scrollDownTapped)
        button.setImage(UIImage(systemName: "chevron.\(scrollDirection.rawValue)", withConfiguration: buttonConfig), for: .normal)
        button.tintColor = .label
        button.isHidden = false
        button.backgroundColor = UIColor.systemBackground.withAlphaComponent(1.0)
        button.addTarget(self, action: buttonAction, for: .touchUpInside)
        button.layer.maskedCorners = scrollDirection.cornerMask
        button.layer.cornerRadius = Constants.cornerRadius
        button.layer.masksToBounds = true
        return button
    }
}

extension IndoorSelectorView {
    private enum Constants {
        static let itemSize: CGFloat = 44
        static let cornerRadius: CGFloat = 8
        static let shadowOpacity: Float = 0.2
        static let shadowOffset = CGSize(width: 0, height: 2)
        static let maxVisibleFloors = 4

        static let flowLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.itemSize = CGSize(width: itemSize, height: itemSize)
            return layout
        }()
    }

    private enum ScrollDirection: String {
        case up, down

        var cornerMask: CACornerMask {
            self == .up
                ? [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                : [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
}
