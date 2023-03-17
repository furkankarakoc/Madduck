//
//  RepositoryListViewModel.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import UIKit
import CoreData

// MARK: - RepositoryListViewModel
final class RepositoryListViewModel {

    private var repositoryList: [Repository]
    private var filteredList: [Repository] = []
    private var favoriteIDList: [Int]
    private(set) var selectedRepository: Repository?

    // MARK: - Lifecycle
    init(repositoryList: [Repository], favoriteList: [Int]) {
        self.repositoryList = repositoryList
        self.favoriteIDList = favoriteList
    }

    var title: String {
        return "All Repositories".localized
    }

    var repositoryListIsEmpty: Bool {
        return filteredList.isEmpty
    }

    func getRepositoryList(completion: @escaping (Error?) -> ()) {
        if repositoryListIsEmpty {
            NetworkManager.shared.getRepositoryList { [weak self] (result: Result<[Repository], Error>) in
                switch result {
                case .failure(let error):
                    completion(error)

                case .success(let repositories):
                    self?.repositoryList = repositories
                    self?.filteredList = repositories
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }

    }

    func fetchFavoriteRepositories() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteRepo")

        do {
            let fetchResults = try context.fetch(fetchRequest)

            let favorites = fetchResults
                .compactMap({ $0 as? NSManagedObject })
                .compactMap({ ($0.value(forKey: "id") as? String)?.integerValue })

            self.favoriteIDList = favorites
        } catch let error{
            print("Item can't be created: \(error.localizedDescription)")

        }
    }

    func addFavoriteList(at indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let ID = filteredList[indexPath.row].id
        favoriteIDList.append(ID)

        let context = appDelegate.persistentContainer.viewContext
        do {
            let favRepo = FavoriteRepo(context: context)
            favRepo.id = ID.stringValue

            try context.save()

        } catch let error{
            print("Item can't create: \(error.localizedDescription)")
        }
    }

    func removeFromFavoriteList(at indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let ID = filteredList[indexPath.row].id

        favoriteIDList = favoriteIDList.filter({ $0 != ID })

        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteRepo")

        do {
            let fetchResults = try context.fetch(fetchRequest)

            for item in fetchResults
                .compactMap({ $0 as? NSManagedObject })
                .filter({ ($0.value(forKey: "id") as! String).integerValue == ID }) {
                context.delete(item)
            }

            try context.save()

        } catch let error{
            print("Item can't be deleted: \(error.localizedDescription)")
        }
    }

    // MARK: Filtering Handlers
    func getRepositoryFilterConfig() -> RepositoryFiltration {
        let title = "Language".localized
        let cases = Array(Set(repositoryList.compactMap({ $0.language })))
        return RepositoryFiltration(title: title, cases: cases)
    }

    func getCurrentRepositoryFilters() -> [String] {
        if filteredList.count == repositoryList.count {
            return []
        }
        return filteredList.compactMap({ $0.language })
    }

    func updatedFilteredRepositoryList(by cases: [String]) {
        if cases.isEmpty {
            filteredList = repositoryList
        } else {
            filteredList = repositoryList.filter({ cases.contains($0.language ?? "") })
        }

    }

    // MARK: Sorting Handlers
    func getSortingTitles() -> [SortCase] {
        return SortCase.allCases
    }

    #warning("Known possible issues. I've force unwrapped these.")
    func updateSortedRepository(by sortCase: SortCase, isInverted: Bool) {
        switch sortCase {
        case .size:
            if isInverted {
                filteredList = filteredList.sorted(by: \.size!, using: <)
            } else {
                filteredList = filteredList.sorted(by: \.size!, using: >)
            }
        case .forkCount:
            if isInverted {
                filteredList = filteredList.sorted(by: \.forksCount!, using: <)
            } else {
                filteredList = filteredList.sorted(by: \.forksCount!, using: >)
            }
        case .starCount:
            if isInverted {
                filteredList = filteredList.sorted(by: \.stargazersCount!, using: <)
            } else {
                filteredList = filteredList.sorted(by: \.stargazersCount!, using: >)
            }
        case .watcherCount:
            if isInverted {
                filteredList = filteredList.sorted(by: \.watchersCount!, using: <)
            } else {
                filteredList = filteredList.sorted(by: \.watchersCount!, using: >)
            }
        case .createdTime:
            if isInverted {
                filteredList = filteredList.sorted(by: \.createdTimestamp, using: >)
            } else {
                filteredList = filteredList.sorted(by: \.createdTimestamp, using: <)
            }
        case .updatedTime:
            if isInverted {
                filteredList = filteredList.sorted(by: \.updatedTimestamp, using: >)
            } else {
                filteredList = filteredList.sorted(by: \.updatedTimestamp, using: <)
            }
        case .alphabetically:
            if isInverted {
                filteredList = filteredList.sorted(by: \.name, using: >)
            } else {
                filteredList = filteredList.sorted(by: \.name, using: <)
            }
        }
    }

    // MARK: - TableView Methods
    var numberOfRows: Int {
        return filteredList.count
    }

    func index(of repository: Repository) -> Int? {
        return filteredList.firstIndex(of: repository)
    }

    func getRepositoryName(at indexPath: IndexPath) -> String {
        return filteredList[indexPath.row].name ?? ""
    }

    func getRepositoryStarCount(at indexPath: IndexPath) -> Int? {
        return filteredList[indexPath.row].stargazersCount
    }

    func getRepositoryForkCount(at indexPath: IndexPath) -> Int? {
        return filteredList[indexPath.row].forksCount
    }

    func getRepositoryWatcherCount(at indexPath: IndexPath) -> Int? {
        return filteredList[indexPath.row].watchersCount
    }

    func getRepositoryLanguage(at indexPath: IndexPath) -> String? {
        return filteredList[indexPath.row].language
    }

    func getRepositoryFavoriteStatus(at indexPath: IndexPath) -> Bool {
        let ID = filteredList[indexPath.row].id
        return favoriteIDList.contains(where: { $0 == ID })
    }

    func selectRepositoryForDisplayingDetails(at indexPath: IndexPath) {
        selectedRepository = filteredList[indexPath.row]
    }


}
