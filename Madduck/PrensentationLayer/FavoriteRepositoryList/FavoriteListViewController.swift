//
//  FavoriteListViewController.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import UIKit

class FavoriteListViewController: UIViewController {

    private let tableView: UITableView = UITableView(frame: .zero)
    private let viewModel: FavoriteListViewModel

    required init(title: String, viewModel: FavoriteListViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
        self.title = title

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitle()
        setupTableView()
        loadRepositories()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.fetchFavoriteRepositories()
        handleLoadRepositoriesSuccessfulResponse()
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

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: RepositoryTableViewCell.reuseIdentifier)

        tableView.tableFooterView = UIView()
    }

    // MARK: - Service methods
    private func loadRepositories() {
        view.isUserInteractionEnabled = false

        viewModel.getFavoriteList { [weak self] error in
            self?.view.isUserInteractionEnabled = true

            if let error = error {
                self?.handleServiceFailures(withError: error)
            } else {
                self?.handleLoadRepositoriesSuccessfulResponse()
            }
        }
    }

    private func handleServiceFailures(withError error: Error) {
        // TODO: Add alert view
    }

    private func handleLoadRepositoriesSuccessfulResponse() {
        tableView.reloadData()
    }

}

// MARK: - UITableView Conformance
extension FavoriteListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryTableViewCell.reuseIdentifier) as? RepositoryTableViewCell else {
            return UITableViewCell()
        }

        cell.set(name: viewModel.getRepositoryName(at: indexPath))
        cell.set(forkCount: viewModel.getRepositoryForkCount(at: indexPath) ?? 0)
        cell.set(starCount: viewModel.getRepositoryStarCount(at: indexPath) ?? 0)
        cell.set(watcherCount: viewModel.getRepositoryWatcherCount(at: indexPath) ?? 0)
        cell.set(language: viewModel.getRepositoryLanguage(at: indexPath) ?? "")
        cell.set(favoriteStatus: true)
        cell.delegate = self

        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectRepositoryForDisplayingDetails(at: indexPath)

        guard let selectedRepo = viewModel.selectedRepository else {
            return
        }

        let detailVC = DetailViewController(title: "Detail".localized, viewModel: DetailViewModel(repository: selectedRepo))
        navigationController?.pushViewController(detailVC, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }

}

// MARK: - RepositoryTableViewCellDelegate Conformance
extension FavoriteListViewController: RepositoryTableViewCellDelegate {
    func cell(_ cell: UITableViewCell, favoriteButtonDidTap isSelected: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        if !isSelected {
            tableView.beginUpdates()
            viewModel.deleteLocallyFavorite(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }
}
