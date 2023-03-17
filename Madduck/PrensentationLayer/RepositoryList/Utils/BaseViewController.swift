//
//  BaseViewController.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func addChild(_ childController: UIViewController) {
        super.addChild(childController)
        childController.view.frame = self.view.frame
        view.addSubview(childController.view)
        childController.didMove(toParent: self)
    }

    override func removeFromParent() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        super.removeFromParent()

    }


}
