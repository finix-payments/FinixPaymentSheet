//
//  AppNavigationViewController.swift
//  FinixPaymentSheet
//
//  Created by Jack Tihon on 7/15/23.
//

import UIKit

class AppNavigationViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let demoViewController = DemoViewController()
        pushViewController(demoViewController, animated: false)
    }
}
