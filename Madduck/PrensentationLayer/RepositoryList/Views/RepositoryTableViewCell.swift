//
//  RepositoryTableViewCell.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import UIKit

protocol RepositoryTableViewCellDelegate: AnyObject {
    func cell(_ cell: UITableViewCell, favoriteButtonDidTap isSelected: Bool)
}

final class RepositoryTableViewCell: UITableViewCell {
    static let reuseIdentifier: String = String(describing: RepositoryTableViewCell.self)

    private(set) var favoriteButton: UIButton = UIButton()
    private(set) var nameLabel: UILabel = UILabel(frame: .zero)
    private(set) var starCountLabel: UILabel = UILabel(frame: .zero)
    private(set) var forkCountLabel: UILabel = UILabel(frame: .zero)
    private(set) var languageLabel: UILabel = UILabel(frame: .zero)
    private(set) var watcherCountLabel: UILabel = UILabel(frame: .zero)

    var repositoryIsSelected: Bool = false {
        didSet {
            if repositoryIsSelected {
                favoriteButton.tintColor = .red
            } else {
                favoriteButton.tintColor = .white
            }
        }
    }

    weak var delegate: RepositoryTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {

        self.accessoryType = .disclosureIndicator

        repositoryIsSelected = false

        let image = UIImage(named: "icon.heart.fill")?.withRenderingMode(.alwaysTemplate)
        favoriteButton.setImage(image, for: .normal)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonDidTap(_:)), for: .touchUpInside)
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.contentMode = .scaleAspectFit

        NSLayoutConstraint.activate([favoriteButton.widthAnchor.constraint(equalToConstant: 20)])

        nameLabel.text = "Name".localized + ": "
        nameLabel.numberOfLines = 2

        starCountLabel.text = "Star".localized + ": "

        forkCountLabel.text = "Fork".localized + ": "

        watcherCountLabel.text = "Watch".localized + ": "

        languageLabel.text = "Language".localized + ": "

        let rightStack = UIStackView(arrangedSubviews: [nameLabel, starCountLabel, forkCountLabel, watcherCountLabel, languageLabel])
        rightStack.axis = .vertical
        rightStack.alignment = .leading
        rightStack.distribution = .fill
        rightStack.spacing = 4.0

        let stack = UIStackView(arrangedSubviews: [favoriteButton, rightStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .top
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

    @objc private func favoriteButtonDidTap(_ sender: UIButton) {
        repositoryIsSelected.toggle()
        delegate?.cell(self, favoriteButtonDidTap: repositoryIsSelected)
    }

    func set(favoriteStatus value: Bool) {
        repositoryIsSelected = value
    }

    func set(name value: String) {
        nameLabel.text = "Name".localized + ": \(value)"
    }

    func set(forkCount value: Int) {
        forkCountLabel.text = "Fork".localized + ":  \(value.stringValue)"
    }

    func set(starCount value: Int) {
        starCountLabel.text = "Star".localized + ": \(value.stringValue)"
    }

    func set(watcherCount value: Int) {
        watcherCountLabel.text = "Watch".localized + ": \(value.stringValue)"
    }

    func set(language value: String) {
        languageLabel.text = "Language".localized + ": \(value)"
    }
}
