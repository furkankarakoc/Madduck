//
//  SortScreenViewController.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import UIKit

protocol SortScreenViewControllerDelegate: AnyObject {
    func sortScreen(_ sender: UIViewController, requestedSorting for: SortCase, isInverted: Bool)
}

final class SortScreenViewController: UIViewController {

    private let viewModel: SortScreenViewModel

    weak var delegate: SortScreenViewControllerDelegate?

    required init(viewModel: SortScreenViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var pickerView: UIPickerView = UIPickerView()

    override func loadView() {
        view = UIView()

        setupView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    private func setupView() {

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Invert: ".localized

        let switchButton = UISwitch()
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        switchButton.addTarget(self, action: #selector(switchButtonDidTap(_:)), for: .valueChanged)

        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = self
        pickerView.dataSource = self

        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sort".localized, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 8.0
        button.clipsToBounds = true
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(sortButtonDidTap(_:)), for: .touchUpInside)

        view.addSubview(label)
        view.addSubview(switchButton)
        view.addSubview(pickerView)
        view.addSubview(button)
        NSLayoutConstraint.activate([
            switchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            switchButton.topAnchor.constraint(equalTo: view.topAnchor),

            label.trailingAnchor.constraint(equalTo: switchButton.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: switchButton.centerYAnchor),

            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pickerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30.0),
            pickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            button.heightAnchor.constraint(equalToConstant: 35.0),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc private func switchButtonDidTap(_ sender: UISwitch) {
        viewModel.setSortingInvertedState(sender.isOn)
    }

    @objc private func sortButtonDidTap(_ sender: UIButton) {
        delegate?.sortScreen(self, requestedSorting: viewModel.selectedCase, isInverted: viewModel.isSortingInverted)

        if let halfmodalVC = self.parent as? HalfScreenModalViewController {
            halfmodalVC.handleCloseAction()
        }
    }

}

extension SortScreenViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.numberOfRows
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.getSortingCase(at: IndexPath(row: row, section: component)).description
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.setSelectedSortCase(at: IndexPath(row: row, section: component))
    }
}
