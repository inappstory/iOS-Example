//
//  DotNavigationView.swift
//  InAppStoryExample
//
//  Created by StPashik on 23.09.2025.
//

import UIKit

public protocol DotNavigationViewDelegate: AnyObject {
    func dotNavigationView(_ view: DotNavigationView, didSelect index: Int)
}

public class DotNavigationView: UIView {
    public var count: Int {
        didSet { reloadDots() }
    }
    public var selectedIndex: Int = 0 {
        didSet { updateSelection() }
    }

    public var dotSize: CGFloat = 8 { didSet { reloadDots() } }
    public var spacing: CGFloat = 8 { didSet { reloadDots() } }

    public var activeScale: CGFloat = 1.4
    public var activeOpacity: CGFloat = 1.0
    public var inactiveOpacity: CGFloat = 0.45

    public var activeDotColor: UIColor = .label
    public var inactiveDotColor: UIColor = .secondaryLabel

    public weak var delegate: DotNavigationViewDelegate?
    public var onTap: ((Int) -> Void)?

    private var dotButtons: [UIButton] = []

    // MARK: - Init
    public init(count: Int = 0) {
        self.count = count
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        self.count = 0
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        reloadDots()
    }

    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutDots()
    }

    private func layoutDots() {
        let totalWidth = CGFloat(count) * dotSize + CGFloat(count - 1) * spacing
        var startX = (bounds.width - totalWidth) / 2
        let centerY = bounds.midY

        for (idx, button) in dotButtons.enumerated() {
            button.frame = CGRect(x: startX, y: centerY - dotSize/2, width: dotSize, height: dotSize)
            startX += dotSize + spacing
        }
    }

    // MARK: - Dots
    private func reloadDots() {
        dotButtons.forEach { $0.removeFromSuperview() }
        dotButtons = []

        for idx in 0..<count {
            let button = UIButton(type: .custom)
            button.tag = idx
            button.layer.cornerRadius = dotSize / 2
            button.addTarget(self, action: #selector(dotTapped(_:)), for: .touchUpInside)
            addSubview(button)
            dotButtons.append(button)
        }
        updateSelection()
        setNeedsLayout()
    }

    private func updateSelection() {
        for (idx, button) in dotButtons.enumerated() {
            let isActive = (idx == selectedIndex)
            button.backgroundColor = isActive ? activeDotColor : inactiveDotColor
            button.alpha = isActive ? activeOpacity : inactiveOpacity

            let scale = isActive ? activeScale : 1.0
            button.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

    // MARK: - Actions
    @objc private func dotTapped(_ sender: UIButton) {
        let idx = sender.tag
        guard idx != selectedIndex else { return }
        selectedIndex = idx
        delegate?.dotNavigationView(self, didSelect: idx)
        onTap?(idx)
    }
}
