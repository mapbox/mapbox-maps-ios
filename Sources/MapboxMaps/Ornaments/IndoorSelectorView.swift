import UIKit
@_spi(Experimental) import MapboxCoreMaps

final class IndoorSelectorView: UIView {
    private let model: IndoorSelectorModelProtocol
    private let containerView = UIView()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: Constants.flowLayout)
    private lazy var buildingButton = makeButton(.building)
    private lazy var topArrowButton = makeButton(.up)
    private lazy var bottomArrowButton = makeButton(.down)

    init(model: IndoorSelectorModelProtocol) {
        self.model = model
        super.init(frame: .zero)
        configureView()
        bindModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        guard !model.floors.isEmpty else { return .zero }
        let listHeight = min(CGFloat(model.floors.count), CGFloat(Constants.maxVisibleFloors)) * Constants.itemSize
        return CGSize(width: Constants.itemSize, height: listHeight + Constants.itemSize)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
}

// MARK: - Setup
private extension IndoorSelectorView {
    func configureView() {
        isUserInteractionEnabled = true
        isExclusiveTouch = true
        layer.opacity = model.isHidden ? 0 : 1

        containerView.backgroundColor = .systemBackground
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
        collectionView.bounces = false
        collectionView.decelerationRate = .fast
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)

        addSubview(containerView)
        containerView.addSubview(collectionView)
        for button in [buildingButton, topArrowButton, bottomArrowButton] {
            containerView.addSubview(button)
            containerView.bringSubviewToFront(button)
        }
    }

    func bindModel() {
        model.onFloorsUpdated = { [weak self] in
            guard let self else { return }
            layer.opacity = model.isHidden ? 0 : 1
            invalidateIntrinsicContentSize()
            collectionView.reloadData()
            setNeedsLayout()
        }
        model.onFloorSelected = { [weak self] in
            self?.collectionView.reloadData()
        }
        model.onVisibilityChanged = { [weak self] in
            self?.updateOpacity()
        }
    }

    private func makeButton(_ type: ButtonType) -> UIButton {
        let button = UIButton()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)

        switch type {
        case .up:
            button.setImage(UIImage(systemName: "chevron.up", withConfiguration: symbolConfig), for: .normal)
            button.addTarget(self, action: #selector(scrollUpTapped), for: .touchUpInside)
            button.layer.maskedCorners = []
        case .down:
            button.setImage(UIImage(systemName: "chevron.down", withConfiguration: symbolConfig), for: .normal)
            button.addTarget(self, action: #selector(scrollDownTapped), for: .touchUpInside)
            button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        case .building:
            button.setImage(UIImage(systemName: "building.2.fill", withConfiguration: symbolConfig), for: .normal)
            button.addTarget(self, action: #selector(buildingButtonTapped), for: .touchUpInside)
            button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }

        button.backgroundColor = .systemBackground
        button.tintColor = .label
        button.layer.cornerRadius = Constants.cornerRadius
        button.layer.masksToBounds = true
        return button
    }
}

// MARK: - Layout
private extension IndoorSelectorView {
    func updateLayout() {
        buildingButton.isHidden = model.floors.isEmpty
        guard !model.floors.isEmpty else { return }
        let listHeight = min(CGFloat(model.floors.count), CGFloat(Constants.maxVisibleFloors)) * Constants.itemSize
        let totalHeight = listHeight + Constants.itemSize
        let size = CGSize(width: Constants.itemSize, height: totalHeight)

        bounds.size = size
        containerView.frame = CGRect(origin: .zero, size: size)
        buildingButton.frame = CGRect(x: 0, y: 0, width: Constants.itemSize, height: Constants.itemSize)
        collectionView.frame = CGRect(x: 0, y: Constants.itemSize, width: Constants.itemSize, height: listHeight)
        collectionView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        if model.floors.count > Constants.maxVisibleFloors {
            topArrowButton.frame = CGRect(x: 0, y: Constants.itemSize, width: Constants.itemSize, height: Constants.itemSize)
            bottomArrowButton.frame = CGRect(x: 0, y: totalHeight - Constants.itemSize, width: Constants.itemSize, height: Constants.itemSize)
        }

        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: Constants.cornerRadius).cgPath
        updateArrowVisibility()
    }

    func updateArrowVisibility() {
        guard model.floors.count > Constants.maxVisibleFloors else {
            topArrowButton.isHidden = true
            bottomArrowButton.isHidden = true
            return
        }

        collectionView.layoutIfNeeded()
        let contentOffset = collectionView.contentOffset.y
        let maxOffset = collectionView.contentSize.height - collectionView.bounds.height

        guard maxOffset > 0 else {
            topArrowButton.isHidden = true
            bottomArrowButton.isHidden = true
            return
        }

        topArrowButton.isHidden = contentOffset <= 0
        bottomArrowButton.isHidden = contentOffset >= maxOffset
    }

    func updateOpacity() {
        let newOpacity: Float = model.isHidden ? 0 : 1
        guard layer.opacity != newOpacity else { return }
        layer.opacity = newOpacity
        if !isHidden {
            invalidateIntrinsicContentSize()
            collectionView.reloadData()
            setNeedsLayout()
        }
    }
}

// MARK: - Actions
private extension IndoorSelectorView {
    @objc func buildingButtonTapped() {
        guard !buildingButton.isSelected else { return }
        buildingButton.isSelected = true
        updateBuildingButtonStyle()
        model.clearFloor()
    }

    @objc func scrollUpTapped() { scrollByOneItem(direction: .up) }
    @objc func scrollDownTapped() { scrollByOneItem(direction: .down) }

    func updateBuildingButtonStyle() {
        buildingButton.backgroundColor = buildingButton.isSelected ? UIColor(white: 0.30, alpha: 1.0) : .clear
        buildingButton.tintColor = buildingButton.isSelected ? .white : .label
        collectionView.reloadData()
    }

    private func scrollByOneItem(direction: ScrollDirection) {
        guard collectionView.isScrollEnabled else { return }

        // Stop any ongoing deceleration to avoid inertia interfering with the programmatic scroll
        collectionView.setContentOffset(collectionView.contentOffset, animated: false)
        let maxOffset = collectionView.contentSize.height - collectionView.bounds.height

        // Snap to nearest item boundary, clamped to valid range
        let snappedOffset = round(collectionView.contentOffset.y / Constants.itemSize) * Constants.itemSize
        let currentIndex = round(max(0, min(maxOffset, snappedOffset)) / Constants.itemSize)

        let targetIndex = switch direction {
        case .up: max(0, currentIndex - 1)
        case .down: min(floor(maxOffset / Constants.itemSize), currentIndex + 1)
        }

        // Disable scroll during animation to prevent user interference
        collectionView.isScrollEnabled = false
        UIView.animate(withDuration: 0.1) {
            self.collectionView.contentOffset = CGPoint(x: 0, y: targetIndex * Constants.itemSize)
        } completion: { _ in
            self.collectionView.isScrollEnabled = true
            self.updateArrowVisibility()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension IndoorSelectorView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model.floors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable:next force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
        let floor = model.floors[indexPath.item]
        cell.configure(title: floor.name, isSelected: !buildingButton.isSelected && floor.id == model.selectedFloorId)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension IndoorSelectorView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if buildingButton.isSelected {
            buildingButton.isSelected = false
            updateBuildingButtonStyle()
        }
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
        targetContentOffset.pointee.y = round(targetContentOffset.pointee.y / Constants.itemSize) * Constants.itemSize
    }
}

// MARK: - Constants
extension IndoorSelectorView {
    private enum Constants {
        static let itemSize: CGFloat = 44
        static let cornerRadius: CGFloat = 8
        static let shadowOpacity: Float = 0.2
        static let shadowOffset = CGSize(width: 0, height: 2)
        static let maxVisibleFloors = 4

        static let flowLayout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.itemSize = CGSize(width: itemSize, height: itemSize)
            return layout
        }()
    }

    private enum ButtonType { case up, down, building }
    private enum ScrollDirection { case up, down }
}
