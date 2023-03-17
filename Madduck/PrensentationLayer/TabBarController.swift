//
//  TabBarController.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import UIKit
import CoreData

final class TabBarController: UITabBarController, UITabBarControllerDelegate {

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupTabbar()

    }

    // MARK: Methods
    private func setupTabbar() {

        let favoriteRepoIDs = getFavoriteReposFromLocale()

        var tabs: [UIViewController] = []

        // Repository List Tab
        let repoListVC = setupTab(title: "Repositories".localized,
                                  image: UIImage(named: "icon.stack") ?? UIImage(),
                                  selectedImage: UIImage(named: "icon.stack.fill") ?? UIImage())
        repoListVC.viewControllers = [RepositoryListViewController(title: "All Repositories".localized,
                                                                   viewModel: RepositoryListViewModel(repositoryList: [],
                                                                                                      favoriteList: favoriteRepoIDs))]
        tabs.append(repoListVC)

        // Favorite Repositories Tab
        let favListVC = setupTab(title: "My Favorites".localized,
                                  image: UIImage(named: "icon.heart") ?? UIImage(),
                                  selectedImage: UIImage(named: "icon.heart.fill") ?? UIImage())

        favListVC.viewControllers = [FavoriteListViewController(title: "My Favorites".localized,
                                                                viewModel: FavoriteListViewModel(favoriteList: favoriteRepoIDs))]
        tabs.append(favListVC)

        // Search Repository Tab
        let searchVC = setupTab(title: "Search Repo",
                                image: UIImage(named: "icon.magnifier") ?? UIImage(),
                                selectedImage: UIImage(named: "icon.magnifier.fill") ?? UIImage())

        searchVC.viewControllers = [SearchViewController(viewModel: SearchViewModel())]
        tabs.append(searchVC)

        self.viewControllers = tabs

    }

    private func setupTab(title: String, image: UIImage, selectedImage: UIImage) -> UINavigationController {
        let navigationVC = UINavigationController()
        navigationVC.tabBarItem.title = title
        navigationVC.tabBarItem.image = image
        navigationVC.tabBarItem.selectedImage = selectedImage
        navigationVC.navigationBar.prefersLargeTitles = false

        return navigationVC
    }

    private func getFavoriteReposFromLocale() -> [Int] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }

        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteRepo")

        do {
            let fetchResults = try context.fetch(fetchRequest)

            let favorites = fetchResults
                .compactMap({ $0 as? NSManagedObject })
                .compactMap({ ($0.value(forKey: "id") as? String)?.integerValue })

            return favorites
        } catch let error{
            print("Item can't be created: \(error.localizedDescription)")
            return []
        }
    }

}
