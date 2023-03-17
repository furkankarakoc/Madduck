//
//  FilterScreenViewController.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import UIKit

protocol FilterScreenViewControllerDelegate: AnyObject {
    func filterScreen(_ sender: UIViewController, requestedFiltration for: [String])
}

final class FilterScreenViewController: BaseViewController {

    private let viewModel: FilterScreenViewModel

    weak var delegate: FilterScreenViewControllerDelegate?

    required init(viewModel: FilterScreenViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var tableView: UITableView = UITableView(frame: .zero)

    override func loadView() {
        view = UIView()

        setupView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    private func setupView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension

        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 35.0, right: 0.0)
        tableView.register(FilterTableViewCell.self, forCellReuseIdentifier: FilterTableViewCell.reuseIdentifier)

        view.addSubview(tableView)

        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Apply Filters".localized, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(applyButtonDidTap(_:)), for: .touchUpInside)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            button.heightAnchor.constraint(equalToConstant: 35),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])



    }

    @objc private func applyButtonDidTap(_ sender: UIButton) {
        delegate?.filterScreen(self.parent ?? self, requestedFiltration: viewModel.selectedFilterCases)
        if let halfmodalVC = self.parent as? HalfScreenModalViewController {
            halfmodalVC.handleCloseAction()
        }
    }
}


// MARK: - UITableView Conformance
extension FilterScreenViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterTableViewCell.reuseIdentifier) as? FilterTableViewCell else {
            return UITableViewCell()
        }

        cell.delegate = self
        cell.set(language: viewModel.getCase(at: indexPath))
        cell.set(selectionStatus: viewModel.getItemSelectionState(at: indexPath))

        return cell
    }

}

extension FilterScreenViewController: FilterTableViewCellDelegate {
    func cell(_ cell: UITableViewCell, checkButtonDidTap: UIButton) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        let itemIsSelected = viewModel.getItemSelectionState(at: indexPath)

        if itemIsSelected {
            viewModel.removeFromSelectedList(at: indexPath)
        } else {
            viewModel.addSelectedList(at: indexPath)
        }
    }

}

fileprivate protocol FilterTableViewCellDelegate: AnyObject {
    func cell(_ cell: UITableViewCell, checkButtonDidTap: UIButton)
}

fileprivate final class FilterTableViewCell: UITableViewCell {
    static let reuseIdentifier: String = String(describing: FilterTableViewCell.self)

    private(set) var checkButton: UIButton = UIButton()
    private(set) var languageLabel: UILabel = UILabel()

    weak var delegate: FilterTableViewCellDelegate?

    var caseIsSelected: Bool = false {
        didSet {
            if caseIsSelected {
                checkButton.tintColor = .red
            } else {
                checkButton.tintColor = .white
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {

        caseIsSelected = false

        let image = UIImage(named: "icon.heart.fill")?.withRenderingMode(.alwaysTemplate)
        checkButton.setImage(image, for: .normal)
        checkButton.addTarget(self, action: #selector(checkButtonDidTap(_:)), for: .touchUpInside)
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        checkButton.contentMode = .scaleAspectFit

        NSLayoutConstraint.activate([checkButton.widthAnchor.constraint(equalToConstant: 20)])

        languageLabel.text = ""

        let stack = UIStackView(arrangedSubviews: [checkButton, languageLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
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

    @objc private func checkButtonDidTap(_ sender: UIButton) {
        caseIsSelected.toggle()
        delegate?.cell(self, checkButtonDidTap: sender)
    }

    func set(selectionStatus value: Bool) {
        caseIsSelected = value
    }

    func set(language value: String) {
        languageLabel.text = value
    }

}
