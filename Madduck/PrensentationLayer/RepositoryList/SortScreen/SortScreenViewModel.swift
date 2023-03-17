//
//  SortScreenViewModel.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import Foundation

// MARK: - SortScreenViewModelDelegate
protocol SortScreenViewModelDelegate: AnyObject {

}

// MARK: - SortScreenViewModel
final class SortScreenViewModel {

    // MARK: - Properties
    weak var delegate: SortScreenViewModelDelegate?

    private let title: String
    private let sortingCases: [SortCase]
    private(set) var selectedCase: SortCase
    private(set) var isSortingInverted: Bool = false

    // MARK: - Lifecycle
    init(with sortingCases: [SortCase] = SortCase.allCases) {
        self.title = "Sorting".localized
        self.sortingCases = sortingCases
        self.selectedCase = sortingCases.first ?? .size
    }

    // MARK: - TableView Methods
    var numberOfRows: Int {
        return sortingCases.count
    }

    func index(of item: SortCase) -> Int? {
        return sortingCases.firstIndex(of: item)
    }

    func getTitle() -> String {
        return title
    }

    func setSelectedSortCase(at indexPath: IndexPath) {
        selectedCase = getSortingCase(at: indexPath)
    }
    
    func getSortingCase(at indexPath: IndexPath) -> SortCase {
        return sortingCases[indexPath.row]
    }

    func setSortingInvertedState(_ isInverted: Bool) {
        isSortingInverted = isInverted
    }

}
