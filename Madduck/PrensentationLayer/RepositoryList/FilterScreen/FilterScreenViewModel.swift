//
//  FilterScreenViewModel.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import Foundation

struct RepositoryFiltration {
    let title: String
    let cases: [String]
}

// MARK: - FilterScreenViewModelDelegate
protocol FilterScreenViewModelDelegate: AnyObject {
    func viewStateDidChange()
}

// MARK: - FilterScreenViewModel
final class FilterScreenViewModel {

    // MARK: - Properties
    weak var delegate: FilterScreenViewModelDelegate?

    private let title: String
    private var cases: [String]
    private(set) var selectedFilterCases: [String]

    // MARK: - Public API
    init(with filterCase: RepositoryFiltration, selectedFilters: [String] = []) {
        self.title = filterCase.title
        self.cases = filterCase.cases
        self.selectedFilterCases = selectedFilters
    }

    var caseListIsEmpty: Bool {
        return selectedFilterCases.isEmpty
    }

    func addSelectedList(at indexPath: IndexPath) {
        selectedFilterCases.append(cases[indexPath.row])
    }

    func removeFromSelectedList(at indexPath: IndexPath) {
        selectedFilterCases = selectedFilterCases.filter({ $0 != cases[indexPath.row] })
    }

    func getItemSelectionState(at indexPath: IndexPath) -> Bool {
        return selectedFilterCases.contains(where: { $0 == cases[indexPath.row] })
    }

    // MARK: - TableView Methods
    var numberOfRows: Int {
        return cases.count
    }

    func didAddRepositoryFavorite(at: IndexPath) {
       // TODO: Add favorite flow
    }

    func index(of item: String) -> Int? {
        return cases.firstIndex(of: item)
    }

    func getTitle() -> String {
        return title
    }

    func getCase(at indexPath: IndexPath) -> String {
        return cases[indexPath.row]
    }

}
