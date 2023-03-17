//
//  FavoriteListViewModel.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import UIKit
import CoreData

// MARK: - FavoriteListViewModel
final class FavoriteListViewModel {

    // MARK: - Properties
    private var repositoryList: [Repository]
    private var filteredList: [Repository]
    private var favoriteIDList: [Int]
    private(set) var selectedRepository: Repository?

    // MARK: - Lifecycle
    init(favoriteList: [Int]) {
        self.repositoryList = []
        self.filteredList = []
        self.favoriteIDList = favoriteList
    }

    var title: String {
        return "My Favorites".localized
    }

    var repositoryListIsEmpty: Bool {
        return repositoryList.isEmpty
    }

    func getFavoriteList(completion: @escaping (Error?) -> ()) {
        if repositoryListIsEmpty {
            NetworkManager.shared.getRepositoryList { [weak self] (result: Result<[Repository], Error>) in
                guard let self = self else {
                    return
                }
                switch result {
                case .failure(let error):
                    completion(error)
                case .success(let repositories):
                    self.repositoryList = repositories
                    self.filteredList = repositories.filter({ self.favoriteIDList.contains($0.id ?? 0) })
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
            self.filteredList = self.repositoryList.filter({ self.favoriteIDList.contains($0.id ?? 0) })
        } catch let error{
            print("Item can't be created: \(error.localizedDescription)")

        }
    }

    func deleteLocallyFavorite(at indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let ID = filteredList[indexPath.row].id
        favoriteIDList = favoriteIDList.filter({ $0 != ID })
        filteredList.remove(at: indexPath.row)
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
            
        } catch let error {
            print("Item can't be deleted: \(error.localizedDescription)")
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

    func selectRepositoryForDisplayingDetails(at indexPath: IndexPath) {
        selectedRepository = filteredList[indexPath.row]
    }
   
}
