//
//  EmptyPageStackView.swift
//  Aidoku (iOS)
//
//  Created by Skitty on 8/12/22.
//

import UIKit

class EmptyPageStackView: UIStackView {

    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }

    var text: String? {
        get { textLabel.text }
        set { textLabel.text = newValue }
    }

    var buttonText: String? {
        get { button.title(for: .normal) }
        set { button.setTitle(newValue, for: .normal) }
    }

    var showsButton: Bool {
        get { !button.isHidden }
        set { button.isHidden = !newValue }
    }

    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private let button = UIButton(type: .roundedRect)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        axis = .vertical
        alignment = .center
        distribution = .equalSpacing
        spacing = 5

        titleLabel.font = .systemFont(ofSize: 25, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        addArrangedSubview(titleLabel)

        textLabel.font = .systemFont(ofSize: 15)
        textLabel.textColor = .secondaryLabel
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        addArrangedSubview(textLabel)

        button.isHidden = true
        addArrangedSubview(button)
    }

    func addButtonTarget(_ target: Any?, action: Selector, for event: UIControl.Event = .touchUpInside) {
        button.addTarget(target, action: action, for: event)
    }
}
