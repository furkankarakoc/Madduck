//
//  DetailViewModel.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import Foundation

// MARK: - DetailViewModel
final class DetailViewModel {

    // MARK: - Properties
    private let repository: Repository

    private let detailSpots: [String: Any]

    // MARK: - Lifecycle
    init(repository: Repository) {
        self.repository = repository
        self.detailSpots = [
            "id" : repository.id.stringValue,
            "Name": repository.name,
            "Owner": repository.owner?.login,
            "Star" : repository.stargazersCount?.stringValue,
            "Watching": repository.watchersCount?.stringValue,
            "URL": repository.url
        ]
    }

    var title: String {
        return "Detail".localized
    }

    // MARK: - TableView Methods
    var numberOfRows: Int {
        return detailSpots.count
    }

    func getData(at indexPath: IndexPath) -> (title: String, value: String?) {
        let key = detailSpots.map({ String($0.key) })[indexPath.row]
        let val = detailSpots[key] as? String
        return (key, val)
    }

}
