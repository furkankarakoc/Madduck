//
//  SearchViewController.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import UIKit

final class SearchViewController: BaseViewController {

    private let viewModel: SearchViewModel
    private let searchController: UISearchController = UISearchController(searchResultsController: nil)
    private let tableView: UITableView = UITableView(frame: .zero)

    required init(viewModel: SearchViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        setupView()

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitle()

        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
    }

    private func setupTitle() {
        title = viewModel.title
    }

    private func setupView() {
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

    }

    private func handleServiceFailures(withError error: Error) {
        // TODO: Add alert view
    }

    private func handleLoadRepositoriesSuccessfulResponse() {
        tableView.reloadData()
    }

}

// MARK: - UITableView Conformance
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
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
        cell.set(favoriteStatus: viewModel.getRepositoryFavoriteStatus(at: indexPath))
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

// MARK: - RepositoryTableViewCell Conformance
extension SearchViewController: RepositoryTableViewCellDelegate {
    func cell(_ cell: UITableViewCell, favoriteButtonDidTap isSelected: Bool) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        if isSelected {
            viewModel.addFavoriteList(at: indexPath)
        } else {
            viewModel.removeFromFavoriteList(at: indexPath)
        }
    }
}

// MARK: - UISearchBar Conformance
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchBar)
        perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.75)
    }

    @objc private func reload(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.trimmingCharacters(in: .whitespaces) != "" else {
            print("nothing to search")
            return
        }

        viewModel.getRepositories(by: query) { [weak self] error in
            
            if let error = error {
                self?.handleServiceFailures(withError: error)
            } else {
                self?.handleLoadRepositoriesSuccessfulResponse()
            }
        }

    }

}
