//
//  SearchViewModel.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import UIKit
import CoreData

// MARK: - SearchViewModel
final class SearchViewModel {

    // MARK: - Properties
    private var repositoryList: [Repository]
    private(set) var selectedRepository: Repository?
    private var key: String?
    private let networkManager: NetworkManager
    
    // MARK: - Lifecycle
    init() {
        self.repositoryList = []
        self.networkManager = NetworkManager.shared
    }

    var title: String {
        return "Search Repo".localized
    }

    func getRepositories(by name: String, completion: @escaping (Error?) -> ()) {
        networkManager.getRepositoryDetail(name: name) { [weak self] (result: Result<Repository, Error>) in
            switch result {
            case .failure(let error):
                completion(error)

            case .success(let repository):
                self?.repositoryList = [repository]
                completion(nil)
            }
        }

    }

    func addFavoriteList(at indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let ID = repositoryList[indexPath.row].id
        let context = appDelegate.persistentContainer.viewContext
        do {
            let favRepo = FavoriteRepo(context: context)
            favRepo.id = ID.stringValue

            try context.save()

        } catch let error{
            print("Item can't be created: \(error.localizedDescription)")
        }
    }

    func removeFromFavoriteList(at indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let ID = repositoryList[indexPath.row].id
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

    // MARK: - TableView Methods
    var numberOfRows: Int {
        return repositoryList.count
    }

    func index(of repository: Repository) -> Int? {
        return repositoryList.firstIndex(of: repository)
    }

    func getRepositoryName(at indexPath: IndexPath) -> String {
        return repositoryList[indexPath.row].name
    }

    func getRepositoryStarCount(at indexPath: IndexPath) -> Int? {
        return repositoryList[indexPath.row].stargazersCount
    }

    func getRepositoryForkCount(at indexPath: IndexPath) -> Int? {
        return repositoryList[indexPath.row].forksCount
    }

    func getRepositoryWatcherCount(at indexPath: IndexPath) -> Int? {
        return repositoryList[indexPath.row].watchersCount
    }

    func getRepositoryLanguage(at indexPath: IndexPath) -> String? {
        return repositoryList[indexPath.row].language
    }

    func getRepositoryFavoriteStatus(at indexPath: IndexPath) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }

        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteRepo")

        do {
            let fetchResults = try context.fetch(fetchRequest)

            let favorites = fetchResults
                .compactMap({ $0 as? NSManagedObject })
                .compactMap({ ($0.value(forKey: "id") as? String)?.integerValue })


            return favorites.contains(where: { $0 == repositoryList[indexPath.row].id })
        } catch let error {
            print(error.localizedDescription)
            return false
        }

    }

    func selectRepositoryForDisplayingDetails(at indexPath: IndexPath) {
        selectedRepository = repositoryList[indexPath.row]
    }

}
