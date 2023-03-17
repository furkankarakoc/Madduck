//
//  DetailViewController.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import UIKit

final class DetailViewController: BaseViewController {
    
    private let viewModel: DetailViewModel
    private let tableView: UITableView = UITableView(frame: .zero)

    required init(title: String, viewModel: DetailViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        setupTableView()

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitle()
        setupTableView()

    }

    private func setupTitle() {
        title = viewModel.title
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension

        tableView.allowsSelection = false

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(DetailTableViewCell.self, forCellReuseIdentifier: DetailTableViewCell.reuseIdentifier)
    }

}
// MARK: - UITableView Conformance
extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailTableViewCell.reuseIdentifier) as? DetailTableViewCell else {
            return UITableViewCell()
        }

        let data = viewModel.getData(at: indexPath)

        cell.set(title: data.title)
        cell.set(value: data.value)

        return cell

    }

}
