//
//  RepositoryTableHeaderView.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import UIKit

protocol RepositoryTableHeaderViewDelegate: AnyObject {
    func filterButtonDidTap()
    func sortButtonDidTap()
}

final class RepositoryTableHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier: String = String(describing: RepositoryTableHeaderView.self)

    weak var delegate: RepositoryTableHeaderViewDelegate?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: RepositoryTableHeaderView.reuseIdentifier)
        setup()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        let tintColor = UIColor.white

        let filterButton = UIButton()
        filterButton.setInsets(imageTitlePadding: 4.0)
        filterButton.setTitle("Filter".localized, for: .normal)
        filterButton.setTitleColor(tintColor, for: .normal)
        let filterImage = UIImage(named: "icon.filter")?.withRenderingMode(.alwaysTemplate)
        filterButton.setImage(filterImage, for: .normal)
        filterButton.tintColor = tintColor
        filterButton.addTarget(self, action: #selector(filterButtonDidTap(_:)), for: .touchUpInside)

        let sortButton = UIButton()
        sortButton.setInsets(imageTitlePadding: 4.0)
        sortButton.setTitle("Sort".localized, for: .normal)
        sortButton.setTitleColor(tintColor, for: .normal)
        let sortImage = UIImage(named: "icon.sort")?.withRenderingMode(.alwaysTemplate)
        sortButton.setImage(sortImage, for: .normal)
        sortButton.addTarget(self, action: #selector(sortButtonDidTap(_:)), for: .touchUpInside)
        sortButton.tintColor = tintColor

        let seperator = UIView()
        seperator.backgroundColor = .white
        seperator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            seperator.widthAnchor.constraint(equalToConstant: 2.0)
        ])

        let stack = UIStackView(arrangedSubviews: [filterButton, seperator, sortButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillProportionally
        stack.spacing = 4.0

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

    }

    @objc private func filterButtonDidTap(_ sender: UIButton) {
        print(#line)
        delegate?.filterButtonDidTap()
    }

    @objc private func sortButtonDidTap(_ sender: UIButton) {
        print(#line)
        delegate?.sortButtonDidTap()
    }
}
