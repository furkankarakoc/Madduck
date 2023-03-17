//
//  ViewController.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    let networkManager = NetworkManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        fetchItems()

    }

    func fetchItems() {
//        shoppingItems.removeAll()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteRepo")

        do {
            let fetchResults = try managedContext.fetch(fetchRequest)

            for item in fetchResults as! [NSManagedObject] {
                print(item.value(forKey: "id"))
                managedContext.delete(item)
//                shoppingItems.append(item.value(forKey: "item") as! String)

            }
//            shoppingTableView.reloadData()

            do {
                try managedContext.save()
            }
            catch {
                print("Item can't be created: \(error.localizedDescription)")
            }

        } catch let error{
            print(error.localizedDescription)
        }

    }


}

