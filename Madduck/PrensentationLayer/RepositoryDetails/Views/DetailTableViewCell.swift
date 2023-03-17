//
//  DetailTableViewCell.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import UIKit

final class DetailTableViewCell: UITableViewCell {

    static let reuseIdentifier: String = String(describing: DetailTableViewCell.self)

    private(set) var titleLabel: UILabel = UILabel(frame: .zero)
    private(set) var valueLabel: UILabel = UILabel(frame: .zero)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {

        titleLabel.text = ""
        titleLabel.numberOfLines = 1
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        valueLabel.text = ""
        valueLabel.numberOfLines = 0
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .leading
        stack.distribution = .fill
        stack.spacing = 8.0

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func set(title: String) {
        titleLabel.text = "\(title): "
    }

    func set(value: String?) {
        valueLabel.text = value
    }

}
